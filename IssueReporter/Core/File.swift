//
//  File.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 12/13/17.
//

import Foundation

internal class File {

    var name: String
    var data: Data
    var state: State = .initial
    var htmlURL: URL? = nil

    init(name: String, data: Data) {
        assert(data.count > 0)
        assert(name.count > 0)
        
        self.name = name
        self.data = data
    }
}
