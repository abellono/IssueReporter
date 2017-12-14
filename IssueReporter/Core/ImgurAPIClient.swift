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

internal final class ImgurAPI {

    static func baseImageUploadRequest() throws -> URLRequest {

        guard let imgurAPIKey = ImgurAPIClient.imgurClientId else {
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

    // MARK : API Methods

    static func uploadRequest(for data: Data) throws -> URLRequest {

        let parameters = ["image" : data.base64EncodedString(), "type" : "base64"]

        var baseIssueRequest = try baseImageUploadRequest()
        let data = try JSONSerialization.data(withJSONObject: parameters)

        baseIssueRequest.httpBody = data
        baseIssueRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")

        return baseIssueRequest
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

        if response.statusCode == 403 {
            throw IssueReporterError.invalid(name: "client id")
        }

        if response.statusCode != successCode {
            guard
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let data = json["data"] as? [String: Any],
                let errorMessage = data["error"] as? String
            else {
                throw IssueReporterError.unparseableResponse
            }

            throw IssueReporterError.network(response: response, detail: errorMessage)
        }

        return (response, data)
    }
}

internal final class ImgurAPIClient {
    
    static var imgurClientId: String?
    static let shared = ImgurAPIClient()
    
    private init() { }
    
    func upload(data: Data, callback queue: DispatchQueue = DispatchQueue.main,
                success: @escaping (URL) -> (), failure: @escaping (IssueReporterError) -> ()) {
        let request: URLRequest

        do {
            request = try ImgurAPI.uploadRequest(for: data)
        } catch {
            ImgurAPI.handle(error: error, with: failure, on: queue)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let (_, data) = try ImgurAPI.handleReponseSuccess(code: 200, data: data, response: response, error: error)

                guard
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let contents = json["data"] as? [String: Any],
                    let link = contents["link"] as? String
                else {
                    throw IssueReporterError.unparseableResponse
                }

                guard let url = URL(string: link) else {
                    throw IssueReporterError.malformedResponseURL
                }
                
                queue.async {
                    success(url)
                }
            } catch {
                ImgurAPI.handle(error: error, with: failure, on: queue)
            }
        }.resume()
    }
}
