//
//  ABEIssue.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/6/16.
//
//

struct ABEIssue {
   
    var title: String?
    var issueDescription: String?
    
    var imageURLS : [String] = []
    
    mutating func attachImage(withURL urlString: String) {
        imageURLS.append(urlString)
    }
    
    var textRepresentation : String? {
        // TODO
        let extraDebuggingInformation = ""
        
        let base = "\(issueDescription) \n\n \(extraDebuggingInformation)"
        let images = imageURLS.map { "![image](\($0))\n" }.reduce("") { $0 + "\n" + $1 }
        
        print(images)
        
        return base + "\n" + images
    }
    
    var dictionaryRepresentation : [String : String]? {
        guard let title = title, let body = textRepresentation else { return nil }
        return ["title" : title, "body" : body]
    }
}
