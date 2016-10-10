//
//  NSBundle+Access.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation

extension Bundle {
    
    fileprivate static let kABEResourceBundleName = "IssueReporterResources.bundle"
    
    static let bundleForLibrary: Bundle = {
        return Bundle(path: "\(Bundle(for: ABEReporter.self).bundlePath)/\(Bundle.kABEResourceBundleName)")!
    }()
}
