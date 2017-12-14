//
//  IssueReporterError.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 12/13/17.
//

import Foundation

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
