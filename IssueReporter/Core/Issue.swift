//
//  Issue.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

internal struct Issue {
   
    var title: String?
    var issueDescription: String?
    var images: [Image] = []
    
    var textRepresentation : String? {

        let extraDebuggingInformation = Reporter.extraDebuggingInformationForIssue()
        
        let base = "\(issueDescription ?? "") \n\n \(extraDebuggingInformation)"
        
        let imageURLs = images.filter { $0.state.contents == .done }.map { $0.cloudImageURL!.absoluteString }
        let combinedImageURLString = imageURLs.map { "![image](\($0))\n" }.reduce("") { $0 + "\n" + $1 }
        
        return base + "\n" + combinedImageURLString
    }
    
    var dictionaryRepresentation : [String : String]? {
        guard let title = title, let body = textRepresentation else { return nil }
        return ["title" : title, "body" : body]
    }
}
