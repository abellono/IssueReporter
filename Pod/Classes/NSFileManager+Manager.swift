//
//  NSFileManager+Manager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation

internal extension FileManager {
    
    static let documentsSubdirectoryName = "IssueReporter-UserImages"
    static let pngSuffix = ".png"
    
    class func earseStoredPicturesFromDisk() {
        do {
            let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pictureDirectory = try directory.appendingPathComponent(FileManager.documentsSubdirectoryName)
        
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
        let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
        
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pictureDirectory = try directory.appendingPathComponent(FileManager.documentsSubdirectoryName)
            let saveLocation = pictureDirectory.randomURL(withExtension: FileManager.pngSuffix)
        
            try data.write(to: saveLocation)
            
            completion(saveLocation)
        } catch {
            _error(error)
            return;
        }
    }
}
