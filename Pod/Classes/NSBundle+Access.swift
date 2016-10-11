//
//  NSBundle+Access.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation

fileprivate let kABEResourceBundleName = "IssueReporterResources.bundle"

extension Bundle {
    
    class func bundleForLibrary() -> Bundle {
        return Bundle(path: "\(Bundle(for: ABEReporter.self).bundlePath)/\(kABEResourceBundleName)")!
    }
}
