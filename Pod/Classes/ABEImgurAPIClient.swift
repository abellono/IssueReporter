//
//  ABEImgurAPIClient.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/8/16.
//
//

import Foundation
import CFNetwork

enum ABEImgurAPIClientError: Error {
    
    case missingAPIKeyError
    case missingURLKeyInJSON
    
    case urlError
    case malformedResponseURL
    
    case jsonError(underlyingError: NSError)
    case networkError(response: URLResponse)
    
    case error(error: Error)
    
    var message : String {
        switch self {
        case .missingAPIKeyError:
            return "No imgur api key was provided."
        case .missingURLKeyInJSON:
            return "The uploaded image link was not present in the returned json."
            
        case .urlError:
            return "There was an error constructing the request URL."
        case .malformedResponseURL:
            return "There was an error extracting the image link from the returned response."
            
        case let .jsonError(underlyingError):
            return "JSON Error, underlying error : \(underlyingError)"
        case let .networkError(response):
            
            if let response = response as? HTTPURLResponse {
                return  "Network error with status code \(response.statusCode) for response \(response)"
            } else {
                return "Network error for response \(response)"
            }
            
        case let .error(error):
            return "Error : \(error)"
        }
    }
}

final class ABEImgurAPIClient {
    
    public static var imgurAPIKey: String? = nil
    
    public static let shared = ABEImgurAPIClient()
    
    private init() { }
    
    func baseImageUploadRequest() throws -> URLRequest {
        
        guard let imgurAPIKey = ABEImgurAPIClient.imgurAPIKey else {
            throw ABEImgurAPIClientError.missingAPIKeyError
        }
        
        guard let url = URL(string: "https://api.imgur.com/3/upload") else {
            throw ABEImgurAPIClientError.urlError
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID \(imgurAPIKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    fileprivate func uploadRequestForImageData(imageData: Data) throws -> URLRequest {
        let parameters = ["image" : imageData.base64EncodedString(),
                          "type" : "base64"]
        
        var baseIssueRequest = try baseImageUploadRequest()
        let data = try JSONSerialization.data(withJSONObject: parameters)
        
        baseIssueRequest.httpBody = data
        baseIssueRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        return baseIssueRequest
    }
    
    public func upload(imageData: Data, dispatchQueue: DispatchQueue = DispatchQueue.main, errorHandler: @escaping (ABEImgurAPIClientError, Data) -> (), success: @escaping (String, Data) -> ()) throws {
        
        let request = try self.uploadRequestForImageData(imageData: imageData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let error = error {
                    throw ABEImgurAPIClientError.error(error: error)
                }
            
                if let response = response {
                
                    guard let data = data else { throw ABEImgurAPIClientError.networkError(response: response) }
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                
                    guard let linkString = json.value(forKeyPath: "data.link") as? String else { throw ABEImgurAPIClientError.missingURLKeyInJSON }
                    guard let url = URL(string: linkString) else { throw ABEImgurAPIClientError.malformedResponseURL }
                    
                    dispatchQueue.async {
                        success(linkString, imageData)
                    }
                }
            } catch let error as NSError {
                errorHandler(ABEImgurAPIClientError.jsonError(underlyingError: error), imageData)
            } catch {
                errorHandler(error as! ABEImgurAPIClientError, imageData)
            }
        }.resume()
    }
}
