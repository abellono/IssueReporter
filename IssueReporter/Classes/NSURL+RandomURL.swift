//
//  NSURL+RandomURL.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation

internal extension URL {
    
    func randomURL(withExtension `extension`: String) -> URL {
        return self.appendingPathComponent("\(UUID.init().uuidString).\(`extension`)")
    }
}
