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
        do {
            let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
            for file in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: options) {
                DispatchQueue.main.async {
                    do {
                        try FileManager.default.removeItem(at: file)
                        print("Deleted file at \(file)")
                    } catch {
                        print("Unable to delete the file at \(file)")
                    }
                }
            }
        } catch {
            print("Error while deleting temporary files : \(error)")
        }
    }
}
