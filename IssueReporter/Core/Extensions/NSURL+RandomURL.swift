//
//  URL+RandomURL.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation

internal extension URL {
    
    func randomURL(withExtension `extension`: String) -> URL {
        return self.appendingPathComponent("\(UUID.init().uuidString).\(`extension`)")
    }
}
