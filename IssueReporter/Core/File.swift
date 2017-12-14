//
//  File.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 12/13/17.
//

import Foundation

internal class File {

    var path: String
    var data: Data
    var state: State = .initial
    var htmlURL: URL? = nil

    init(path: String, data: Data) {
        self.path = path
        self.data = data
    }
}
