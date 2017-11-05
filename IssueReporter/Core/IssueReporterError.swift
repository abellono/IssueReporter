//
//  IssueReporterError.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import CFNetwork

enum IssueReporterError: Error {
    
    static let domain = "IssueReporter.IssueReporterError"
    
    case missingInformation(name: String)
    case invalid(name: String)

    case invalidURL
    case malformedResponseURL
    case unparseableResponse
    
    case jsonError(underlyingError: Error)
    case network(response: HTTPURLResponse, detail: String?)
    
    case error(error: Error?)
    
    var message : String {
        switch self {
        case let .missingInformation(name):
            return "The \(name) was not provided. Consult the README.md for information on how to acquire it."
        case let .invalid(name):
            return "Your \(name) is invalid, please follow the instructions in README.md"
            
        case .invalidURL:
            return "There was an error constructing the request URL."
        case .malformedResponseURL:
            return "There was an error extracting the image link from the returned response."
        case .unparseableResponse:
            return "Unable to parse the response body or the data contained in the response."
            
        case let .jsonError(underlyingError):
            return "There was an error parsing the JSON response : \(underlyingError)"
        case let .network(response, detail):
            let detail = detail != nil ? " with detail : " + detail! : ""
            return  "Network error with status code \(response.statusCode)"  + detail
            
        case let .error(error):
            return error == nil ? "Error : \(String(describing: error))" : ""
        }
    }
    
    var localizedDescription: String {
        return message
    }
}

internal final class ABEImgurAPIClient {
    
    static var imgurAPIKey: String? = nil
    static let shared = ABEImgurAPIClient()
    
    private init() { }
    
    fileprivate func baseImageUploadRequest() throws -> URLRequest {
        
        guard let imgurAPIKey = ABEImgurAPIClient.imgurAPIKey else {
            throw IssueReporterError.missingInformation(name: "imgur api key")
        }
        
        guard let url = URL(string: "https://api.imgur.com/3/upload") else {
            throw IssueReporterError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID \(imgurAPIKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    fileprivate func uploadRequest(for imageData: Data) throws -> URLRequest {
        let parameters = ["image" : imageData.base64EncodedString(),
                          "type" : "base64"]
        
        var baseIssueRequest = try baseImageUploadRequest()
        let data = try JSONSerialization.data(withJSONObject: parameters)
        
        baseIssueRequest.httpBody = data
        baseIssueRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        return baseIssueRequest
    }
    
    func upload(imageData: Data, dispatchQueue: DispatchQueue = DispatchQueue.main, errorHandler: @escaping (IssueReporterError) -> (), success: @escaping (URL) -> ()) throws {
        
        let request = try self.uploadRequest(for: imageData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error {
                    throw IssueReporterError.error(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, let data = data else {
                    throw IssueReporterError.unparseableResponse
                }
                
                if response.statusCode == 403 {
                    throw IssueReporterError.invalid(name: "client id")
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                guard let linkString = json.value(forKeyPath: "data.link") as? String else {
                    throw IssueReporterError.network(response: response, detail: json.value(forKeyPath: "data.error") as? String)
                }
                
                guard let url = URL(string: linkString) else {
                    throw IssueReporterError.malformedResponseURL
                }
                
                dispatchQueue.async {
                    success(url)
                }
            } catch let error as NSError where error.domain != IssueReporterError.domain {

                // Catch error not from our domain and wrap them
                errorHandler(IssueReporterError.jsonError(underlyingError: error))
            } catch {
                
                // Catch and forward all other errors
                errorHandler(error as! IssueReporterError)
            }
        }.resume()
    }
}
