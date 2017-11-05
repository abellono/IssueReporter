//
//  Bundle+Access.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation

private let kABEResourceBundleName = "IssueReporterResources.bundle"

internal extension Bundle {
    
    class func bundleForLibrary() -> Bundle {
        return Bundle(path: "\(Bundle(for: Reporter.self).bundlePath)/\(kABEResourceBundleName)")!
    }
}
