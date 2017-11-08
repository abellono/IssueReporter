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

extension String {

    static let kLocalizedStringNotFound = "kLocalizedStringNotFound"

    static func localizedStringForKey(key:String,
                                      value:String?,
                                      table:String?,
                                      bundle:Bundle?) -> String {
        // First try main bundle
        var string: String = Bundle.main.localizedString(forKey: key, value: kLocalizedStringNotFound, table: table)

        // Then try the backup bundle
        if string == kLocalizedStringNotFound {
            string = bundle!.localizedString(forKey: key, value: kLocalizedStringNotFound, table: table)
        }

        // Still not found?
        if string == kLocalizedStringNotFound {

            print("No localized string for '\(key)' in '\(String(describing: table))'")
            if let value = value {
                string = value.count > 0 ? value : key
            } else {
                string = key
            }
        }

        return string;
    }
}
