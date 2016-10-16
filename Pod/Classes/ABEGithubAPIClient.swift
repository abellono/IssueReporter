//
//  ABEGithubAPIClient.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/6/16.
//
//

import UIKit

final class ABEGithubAPIClient {
    
    public static var githubToken: String? = nil
    public static var githubRepositoryName : String? = nil
    public static var githubRepositoryOwner : String? = nil
    
    public static let sharedInstance = ABEGithubAPIClient()
    
    private init() { }
    
    static fileprivate func humanReadableDescriptionForMissingInformation() -> String? {
        if githubToken == nil {
            return "github personal access token"
        } else if githubRepositoryName == nil {
            return "github repository name"
        } else if githubRepositoryOwner == nil {
            return "github repository owner name"
        }

        return nil
    }
    
    fileprivate func baseSaveIssueURLRequest() throws -> URLRequest {
        guard let githubToken = ABEGithubAPIClient.githubToken, let name = ABEGithubAPIClient.githubRepositoryName, let owner = ABEGithubAPIClient.githubRepositoryOwner else {
            let humanReadableDescription = ABEGithubAPIClient.humanReadableDescriptionForMissingInformation()!
            throw IssueReporterError.missingInformation(name: humanReadableDescription)
        }
        
        let path = "https://api.github.com/repos/\(owner)/\(name)/issues?access_token=\(githubToken)"
        
        guard let url = URL(string: path) else {
            throw IssueReporterError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    fileprivate func requestForIssue(issue: ABEIssue, errorHandler: @escaping (IssueReporterError) -> ()) throws -> URLRequest {
        var baseIssueRequest = try self.baseSaveIssueURLRequest()
        
        do {
            let json = try JSONSerialization.data(withJSONObject: issue.dictionaryRepresentation!, options: [])
            
            baseIssueRequest.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
            baseIssueRequest.httpBody = json
            
            return baseIssueRequest
        } catch {
            throw IssueReporterError.jsonError(underlyingError: error)
        }
    }
    
    public func saveIssue(issue: ABEIssue, callbackQueue: DispatchQueue = DispatchQueue.main, success: @escaping () -> (), errorHandler: @escaping (IssueReporterError) -> ()) throws {
        
        let issueRequest = try self.requestForIssue(issue: issue, errorHandler: errorHandler)
        
        URLSession.shared.dataTask(with: issueRequest) { (data, response, error) in
            
            do {
                if let error = error {
                    throw IssueReporterError.error(error: error)
                }
                
                guard let response = response as? HTTPURLResponse, let data = data else {
                    throw IssueReporterError.unparseableResponse
                }
                
                if response.statusCode == 401 {
                    throw IssueReporterError.invalid(name: "github token or github repository path")
                } else if response.statusCode == 201 {
                    callbackQueue.async(execute: success)
                    return
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                throw IssueReporterError.network(response: response, detail: json.value(forKeyPath: "message") as? String)
                
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
