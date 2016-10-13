//
//  ABEGithubAPIClient.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/6/16.
//
//

import UIKit

public enum GithubAPIClientError: Error {
    
    case missingInformation(name: String)
    case jsonError(underlyingError: Error)
    case invalidURL
    
    var message : String {
        switch self {
        case let .missingInformation(name):
            return "Missing the \(name) required to save the issue."
        case .jsonError:
            return "Error constructing the JSON body for the save issue request."
        case .invalidURL:
            return "Error constructing the URL for the save issue request."
        }
    }
    
    static func humanReadableDescriptionForNilVariable(token: String?, repoName: String?, owner: String?) -> String {
        
        if token == nil {
            return "github personal access token"
        } else if repoName == nil {
            return "github repository name"
        } else {
            return "github repository owner name"
        }
    }
}

final class ABEGithubAPIClient {
    
    public static var githubToken: String? = nil
    public static var githubRepositoryName : String? = nil
    public static var githubRepositoryOwner : String? = nil
    
    public static let sharedInstance = ABEGithubAPIClient()
    
    private init() { }
    
    fileprivate func baseSaveIssueURLRequest() throws -> URLRequest {
        guard let githubToken = ABEGithubAPIClient.githubToken, let name = ABEGithubAPIClient.githubRepositoryName, let owner = ABEGithubAPIClient.githubRepositoryOwner else {
            let humanReadableDescription = GithubAPIClientError.humanReadableDescriptionForNilVariable(token: ABEGithubAPIClient.githubToken, repoName: ABEGithubAPIClient.githubRepositoryName, owner: ABEGithubAPIClient.githubRepositoryOwner)
            throw GithubAPIClientError.missingInformation(name: humanReadableDescription)
        }
        
        let path = "https://api.github.com/repos/\(owner)/\(name)/issues?access_token=\(githubToken)"
        
        guard let url = URL(string: path) else {
            throw GithubAPIClientError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    fileprivate func requestForIssue(issue: ABEIssue, errorHandler: @escaping (Error) -> ()) throws -> URLRequest {
        var baseIssueRequest = try self.baseSaveIssueURLRequest()
        
        do {
            let json = try JSONSerialization.data(withJSONObject: issue.dictionaryRepresentation!, options: [])
            
            baseIssueRequest.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
            baseIssueRequest.httpBody = json
            
            return baseIssueRequest
        } catch {
            throw GithubAPIClientError.jsonError(underlyingError: error)
        }
    }
    
    public func saveIssue(issue: ABEIssue, callbackQueue: DispatchQueue = DispatchQueue.main, success: @escaping () -> (), errorHandler: @escaping (Error) -> ()) throws {
        
        let issueRequest = try self.requestForIssue(issue: issue, errorHandler: errorHandler)
        
        URLSession.shared.dataTask(with: issueRequest) { (data, response, error) in
            callbackQueue.async {
                if let error = error {
                    errorHandler(error)
                } else {
                    success()
                }
            }
        }.resume()
    }
}
