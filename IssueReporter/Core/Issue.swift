//
//  Issue.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

internal enum State {
    case initial
    case uploading
    case errored
    case done
}

internal struct Issue {
   
    var title = ""
    var issueDescription = " "
    var images: [Image] = []
    var files: [File] = []
    
    var textRepresentation : String {
        
        let base = "\(issueDescription) \n\n \(standardDebugInformation) \n \(extraDebugInformation)"

        let fileURLs = files.filter { $0.state == .done }.map { $0.htmlURL!.absoluteString }.joined(separator: "\n")
        
        let imageURLs = images.filter { $0.state == .done }.map { $0.cloudImageURL!.absoluteString }
        let combinedImageURLString = imageURLs.map { "![image](\($0))\n" }.reduce("") { $0 + "\n" + $1 }
        
        return base + "\n" + combinedImageURLString + "\n\n Files :\n" + fileURLs
    }
    
    var dictionaryRepresentation : [String : String] {
        return ["title" : title.isEmpty ? "no title" : title,
                "body" : textRepresentation]
    }
    
    private var extraDebugInformation : String {
        return """
        <details>
        <summary>Extra Debugging Information</summary>
        <table>
            <tr>
            <th>Key</th>
            <th>Value</th>
            </tr>
            \(Reporter.additionalDebuggingInformation().map {
                return "<tr><td>\($0.key)</td><td>\($0.value)</td></tr>"
            }.joined(separator: "\n"))
        </table>
        </details>
        """
    }
    
    private var standardDebugInformation : String {
        let debugInformationDictionary = Reporter.standardDebuggingInformation()
        
        return debugInformationDictionary.map {
            return "\($0.key) : \($0.value)"
        }.joined(separator: "\n")
    }
}
