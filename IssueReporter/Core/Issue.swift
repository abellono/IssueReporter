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

        let debugInformationDictionary = Reporter.debugInformationForIssueReporter()
        let debugInformationString = debugInformationDictionary.map {
            return "\($0.key) : \($0.value)"
        }.joined(separator: "\n")
        
        let base = "\(issueDescription) \n\n \(debugInformationString)"

        let fileURLs = files.filter { $0.state == .done }.map { $0.htmlURL!.absoluteString }.joined(separator: "\n")
        
        let imageURLs = images.filter { $0.state == .done }.map { $0.cloudImageURL!.absoluteString }
        let combinedImageURLString = imageURLs.map { "![image](\($0))\n" }.reduce("") { $0 + "\n" + $1 }
        
        return base + "\n" + combinedImageURLString + "\n\n Files :\n" + fileURLs
    }
    
    var dictionaryRepresentation : [String : String] {
        return ["title" : title.isEmpty ? "no title" : title,
                "body" : textRepresentation]
    }
}
