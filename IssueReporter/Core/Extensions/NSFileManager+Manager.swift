//
//  FileManager+Manager.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation

internal extension FileManager {
    
    static let documentsSubdirectoryName = "IssueReporter-UserImages"
    static let pngSuffix = ".png"
    
    class func eraseStoredPicturesFromDisk() {
        do {
            let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pictureDirectory = directory.appendingPathComponent(FileManager.documentsSubdirectoryName)
        
            for file in try FileManager.default.contentsOfDirectory(at: pictureDirectory, includingPropertiesForKeys: nil, options: options) {
                if file.lastPathComponent.hasSuffix(FileManager.pngSuffix) {
                    DispatchQueue.main.async {
                        try? FileManager.default.removeItem(at: file)
                    }
                }
            }
        } catch {
            print("Error while deleting temporary files : \(error)")
        }
    }
    
    class func write(data: Data, completion: (URL) -> (), error _error: (Error) -> ()) {        
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pictureDirectory = directory.appendingPathComponent(FileManager.documentsSubdirectoryName)

            try FileManager.default.createDirectory(at: pictureDirectory, withIntermediateDirectories: true, attributes: nil)

            let saveLocation = pictureDirectory.randomURL(withExtension: FileManager.pngSuffix)
        
            try data.write(to: saveLocation)
            
            completion(saveLocation)
        } catch {
            _error(error)
            return;
        }
    }
}
