//
//  ABEImgurAPIClient.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/8/16.
//
//

import Foundation

enum ABEImgurAPIClientError: String, Error {
    
    case MissingAPIKeyError = "No imgur api key was provided."
    case JSONError = "There was an error converting the issue to JSON format."
    case Missing = "There was no data in the response body"
}

final class ABEImgurAPIClient {
    
    public static var imgurAPIKey: String? = nil
    
    public static let sharedInstance = ABEImgurAPIClient()
    
    private init() { }
    
    func baseImageUploadRequest() throws -> URLRequest {
        
        guard let imgurAPIKey = ABEImgurAPIClient.imgurAPIKey else {
            throw ABEImgurAPIClientError.MissingAPIKeyError
        }
        
        let path = "https://api.imgur.com/3/upload"
        let url = URL(string: path)!
        
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
    
    public func upload(imageData: Data, success: @escaping (String) -> ()) throws {
        
        let request = try self.uploadRequestForImageData(imageData: imageData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil { print("Error uploading image : \(error)") }
            
            guard let data = data else {
                print("no data")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary, let linkString = json.value(forKeyPath: "data.link") as? String, let url = URL(string: linkString) {
                DispatchQueue.main.async {
                    success(linkString)
                }
                
            }
        }.resume()
    }
}
