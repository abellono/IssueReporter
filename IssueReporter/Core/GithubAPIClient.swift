//
//  GithubAPIClient.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import UIKit

internal final class GithubAPI {

    private static func baseGithubRequest(method: String, path: String) throws -> URLRequest {
        guard let githubToken = GithubAPIClient.githubToken else {
            let humanReadableDescription = GithubAPIClient.humanReadableDescriptionForMissingInformation()!
            throw IssueReporterError.missingInformation(name: humanReadableDescription)
        }

        let urlString = "https://api.github.com/\(path)?access_token=\(githubToken)"

        guard let url = URL(string: urlString) else {
            throw IssueReporterError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = method

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("token \(githubToken)", forHTTPHeaderField: "Authorization")

        return request
    }

    // MARK : API Methods

    static func saveIssueRequest(for issue: Issue) throws -> URLRequest {
        guard let name = GithubAPIClient.githubRepositoryName, let owner = GithubAPIClient.githubRepositoryOwner else {
            let humanReadableDescription = GithubAPIClient.humanReadableDescriptionForMissingInformation()!
            throw IssueReporterError.missingInformation(name: humanReadableDescription)
        }
        
        var request = try self.baseGithubRequest(method: "POST", path: "repos/\(owner)/\(name)/issues")

        do {
            let json = try JSONSerialization.data(withJSONObject: issue.dictionaryRepresentation, options: [])

            request.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = json

            return request
        } catch {
            throw IssueReporterError.jsonError(underlyingError: error)
        }
    }

    static func uploadFileRequest(for issue: Issue, with data: Data, at path: String) throws -> URLRequest {
        guard let name = GithubAPIClient.githubRepositoryName, let owner = GithubAPIClient.githubRepositoryOwner else {
            let humanReadableDescription = GithubAPIClient.humanReadableDescriptionForMissingInformation()!
            throw IssueReporterError.missingInformation(name: humanReadableDescription)
        }

        var request = try self.baseGithubRequest(method: "PUT", path: "repos/\(owner)/\(name)/contents/\(path)")

        let parameters = [
            "message": "Issue \"\(issue.title)\" file upload",
            "content": data.base64EncodedString()
        ]

        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: [])

            request.setValue("\(json.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = json

            return request
        } catch {
            throw IssueReporterError.jsonError(underlyingError: error)
        }
    }

    // MARK : API Helpers

    static func handle(error: Error, with handler: @escaping (IssueReporterError) -> (), on queue: DispatchQueue) {
        queue.async {
            if let error = error as? IssueReporterError {
                handler(error)
            } else {
                handler(.error(error: error))
            }
        }
    }

    static func handleReponseSuccess(code successCode: Int, data: Data?, response: URLResponse?, error: Error?) throws -> (HTTPURLResponse, Data) {
        if let error = error {
            throw IssueReporterError.error(error: error)
        }

        guard let response = response as? HTTPURLResponse, let data = data else {
            throw IssueReporterError.unparseableResponse
        }

        if response.statusCode == 401 {
            throw IssueReporterError.invalid(name: "github token or github repository path")
        }

        if response.statusCode != successCode {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            throw IssueReporterError.network(response: response, detail: json.value(forKeyPath: "message") as? String)
        }

        return (response, data)
    }
}

internal final class GithubAPIClient {
    
    static var githubToken: String?
    static var githubRepositoryName: String?
    static var githubRepositoryOwner: String?

    internal static func humanReadableDescriptionForMissingInformation() -> String? {
        if githubToken == nil {
            return "github personal access token"
        } else if githubRepositoryName == nil {
            return "github repository name"
        } else if githubRepositoryOwner == nil {
            return "github repository owner name"
        }

        return nil
    }
    
    static let shared = GithubAPIClient()
    
    private init() { }
    
    func save(issue: Issue, callback queue: DispatchQueue = DispatchQueue.main,
              success: @escaping () -> (), failure: @escaping (IssueReporterError) -> ()) {
        let issueRequest: URLRequest

        do {
            issueRequest = try GithubAPI.saveIssueRequest(for: issue)
        } catch {
            GithubAPI.handle(error: error, with: failure, on: queue)
            return
        }
        
        URLSession.shared.dataTask(with: issueRequest) { (data, response, error) in
            do {
                let _ = try GithubAPI.handleReponseSuccess(code: 201, data: data, response: response, error: error)
                queue.async(execute: success)
            } catch {
                GithubAPI.handle(error: error, with: failure, on: queue)
            }
        }.resume()
    }

    func upload(file: Data, for issue: Issue, at path: String,
                callback queue: DispatchQueue = .main, success: @escaping (URL) -> (), failure: @escaping (IssueReporterError) -> ()) {

        let uploadRequest: URLRequest

        do {
            uploadRequest = try GithubAPI.uploadFileRequest(for: issue, with: file, at: path)
        } catch {
            GithubAPI.handle(error: error, with: failure, on: queue)
            return
        }

        URLSession.shared.dataTask(with: uploadRequest) { (data, response, error) in
            do {
                let (_, data) = try GithubAPI.handleReponseSuccess(code: 201, data: data, response: response, error: error)

                guard
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let content = responseJSON["content"] as? [String: Any],
                    let urlString = content["html_url"] as? String
                else {
                    throw IssueReporterError.unparseableResponse
                }

                guard let url = URL(string: urlString) else {
                    throw IssueReporterError.malformedResponseURL
                }

                queue.async {
                    success(url)
                }
            } catch {
                GithubAPI.handle(error: error, with: failure, on: queue)
            }
        }.resume()
    }
}
