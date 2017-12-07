//
//  Issue.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

internal struct Issue {
   
    var title = ""
    var issueDescription = " "
    var images: [Image] = []
    
    var textRepresentation : String {

        let debugInformationDictionary = Reporter.debugInformationForIssueReporter()
        let debugInformationString = debugInformationDictionary.map {
            return "\($0.key) : \($0.value)"
        }.joined(separator: "\n")
        
        let base = "\(issueDescription) \n\n \(debugInformationString)"
        
        let imageURLs = images.filter { $0.state.contents == .done }.map { $0.cloudImageURL!.absoluteString }
        let combinedImageURLString = imageURLs.map { "![image](\($0))\n" }.reduce("") { $0 + "\n" + $1 }
        
        return base + "\n" + combinedImageURLString
    }
    
    var dictionaryRepresentation : [String : String] {
        guard !title.isEmpty else {
            return ["title" : "No title", "body" : textRepresentation]
        }

        return ["title" : title, "body" : textRepresentation]
    }
}
