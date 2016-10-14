//
//  ABEissueManager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

extension Array where Element: Equatable {
    
    mutating func removeFirst(element: Element) {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
}

private let kABECompressionRatio = CGFloat(5.0)

public protocol ABEIssueManagerDelegate: class {
    
    func issueManagerUploadingStateDidChange(issueManager: ABEIssueManager)
    
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadIssueWithError error: Error)
}

public class ABEIssueManager {
    
    public var isUploading: Bool {
        get {
            return uploadingImages.count != 0
        }
    }
    
    public private(set) var images: [UIImage] = []
    public private(set) var localImageURLs: [URL] = []
    
    private var uploadingImages: [Data] = []
    
    let referenceView: UIView
    
    weak var delegate: ABEIssueManagerDelegate?
    
    var issue: ABEIssue = ABEIssue()
    
    init(referenceView: UIView, delegate: ABEIssueManagerDelegate? = nil) {
        self.referenceView = referenceView
        self.delegate = delegate
        
        drawSnapshotOf(referenceView: referenceView) { [weak self] image in
            self?.add(imageToIssue: image)
        }
    }
    
    private func drawSnapshotOf(referenceView view: UIView, complete: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            complete(image)
        }
    }
    
    public func add(imageToIssue image: UIImage) {
        
        let flippedImage = image.applyRotationToImageData()
        let imageData = UIImageJPEGRepresentation(flippedImage, kABECompressionRatio)!
        
        self.images.append(flippedImage)
        
        self.persist(imageData: imageData) { [weak self] url in
            self?.issue.attachImage(withURL: url)
        }
    }
    
    private func persist(imageData data: Data, complete: @escaping (String) -> ()) {
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .`default`)
        
        queue.async(group: group) { [weak self] in
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let saveLocation = documentsDirectory.randomURL(withExtension: "jpg")
            self?.localImageURLs.append(saveLocation)
            
            try? data.write(to: saveLocation)
        }
        
        self.uploadingImages.append(data)
        
        DispatchQueue.main.async {
            self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
        }
        
        try? ABEImgurAPIClient.shared.upload(imageData: data, errorHandler: { [weak self] error, imageData in
            
            print(error.message)
            self?.uploadingImages.removeFirst(element: imageData)
            
        }, success: { [weak self] url, imageData in
            
            self?.uploadingImages.removeFirst(element: data)
            
            if let `self` = self {
                self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
            }
            
            group.notify(queue: queue) {
                complete(url)
            }
        })
    }
    
    public func saveIssue(completion: @escaping () -> ()) {
        do {
            try ABEGithubAPIClient.sharedInstance.saveIssue(issue: self.issue, success: completion) { [weak self] error in
                if let `self` = self {
                    self.delegate?.issueManager(self, didFailToUploadIssueWithError: error)
                }
            }
        } catch {
            print("Error while trying to save issue : \(error)")
        }
    }
}
