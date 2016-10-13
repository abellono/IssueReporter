//
//  ABEGithubAPIClient.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/6/16.
//
//

import UIKit

public enum GithubAPIClientError: String, Error {
    
    case MissingInformation = "Missing either the github token, repository name, or repository owner."
    case JSONError = "There was an error converting the issue to JSON format."
}

final class ABEGithubAPIClient {
    
    public static var githubToken: String? = nil
    public static var githubRepositoryName : String? = nil
    public static var githubRepositoryOwner : String? = nil
    
    public static let sharedInstance = ABEGithubAPIClient()
    
    private init() { }
    
    lazy var baseSaveIssueURLRequest: URLRequest? = {
        guard let githubToken = githubToken, let name = githubRepositoryName, let owner = githubRepositoryOwner else {
            return nil
        }
        
        let path = "https://api.github.com/repos/\(owner)/\(name)/issues?access_token=\(githubToken)"
        
        guard let url = URL(string: path) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }()
    
    fileprivate func requestForIssue(issue: ABEIssue, errorHandler: @escaping (Error) -> ()) -> URLRequest? {
        guard var baseIssueRequest = self.baseSaveIssueURLRequest else {
            errorHandler(GithubAPIClientError.MissingInformation)
            return nil;
        }
        
        guard let json = try? JSONSerialization.data(withJSONObject: issue.dictionaryRepresentation!, options: []) else {
            errorHandler(GithubAPIClientError.JSONError)
            return nil
        }
        
        baseIssueRequest.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
        baseIssueRequest.httpBody = json
        
        return baseIssueRequest
    }
    
    public func saveIssue(issue: ABEIssue, success: @escaping () -> (), errorHandler: @escaping (Error) -> ()) {
        
        guard let request = self.requestForIssue(issue: issue, errorHandler: errorHandler) else {
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                errorHandler(error)
            } else {
                success()
            }
        }.resume()
    }
}
