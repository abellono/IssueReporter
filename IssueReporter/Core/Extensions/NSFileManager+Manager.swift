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
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let manager = FileManager()
                let options: DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants , .skipsPackageDescendants, .skipsHiddenFiles]
                let directory = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let pictureDirectory = directory.appendingPathComponent(FileManager.documentsSubdirectoryName)

                for file in try manager.contentsOfDirectory(at: pictureDirectory, includingPropertiesForKeys: nil, options: options) {
                    if file.lastPathComponent.hasSuffix(FileManager.pngSuffix) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? FileManager.default.removeItem(at: file)
                        }
                    }
                }
            } catch {
                print("Error while deleting temporary files : \(error)")
            }
        }
    }
    
    class func write(data: Data,
                     completion: @escaping (URL) -> (),
                     errorBlock: @escaping (Error) -> ()) {

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let manager = FileManager()
                let directory = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let pictureDirectory = directory.appendingPathComponent(FileManager.documentsSubdirectoryName)

                try manager.createDirectory(at: pictureDirectory, withIntermediateDirectories: true, attributes: nil)

                let saveLocation = pictureDirectory.randomURL(withExtension: FileManager.pngSuffix)
                try data.write(to: saveLocation)

                DispatchQueue.main.async {
                    completion(saveLocation)
                }
            } catch {
                DispatchQueue.main.async {
                    errorBlock(error)
                }
            }
        }
    }
}
