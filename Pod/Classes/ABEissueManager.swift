//
//  ABEissueManager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

private let kABECompressionRatio = CGFloat(5.0)

public protocol ABEIssueManagerDelegate: class {
    
    func issueManagerUploadingStateDidChange(issueManager: ABEIssueManager)
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
            
            print("written to disk")
        }
        
        self.uploadingImages.append(data)
        self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
        
        try? ABEImgurAPIClient.sharedInstance.upload(imageData: data) { [weak self] url in
            guard let index = self?.uploadingImages.index(of: data) else {
                print("Unexpected error")
                return
            }
            
            print("uploaded")
            
            self?.uploadingImages.remove(at: index)
            
            if let `self` = self {
                self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
            }
            
            group.notify(queue: queue) {
                // We are sure that the disk operation has finished
                complete(url)
            }
        }
    }
    
    public func saveIssue(completion: @escaping () -> ()) {
        // self is only used in inner closure....
        // TODO: Do we need [weak self] in both closures here? What happens if we remove the first [weak self]?
        ABEGithubAPIClient.sharedInstance.saveIssue(issue: self.issue, success: completion) { [weak self] error in
            let alertController = UIAlertController(error: error as NSError)
            
            alertController.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] action in
                self?.saveIssue(completion: completion)
            })
        }
    }
}
