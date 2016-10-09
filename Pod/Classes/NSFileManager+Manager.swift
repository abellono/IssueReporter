//
//  NSFileManager+Manager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation

extension FileManager {
    
    class func clearDocumentsDirectory() {
        // TODO: Error handling
        let directory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
        
        for file in try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: options) {
            
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Unable to delete the file at \(file)")
            }
        }
        
        
    }
}
