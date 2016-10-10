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

class ABEIssueManager {
    
    public var isUploading: Bool {
        get {
            return uploadingImages.count != 0
        }
    }
    
    public var localImageURLs: [URL] = []
    
    fileprivate var uploadingImages: [Data] = []
    private var images: [UIImage] = []
    
    let referenceView: UIView
    let viewController: UIViewController
    
    var issue: ABEIssue = ABEIssue()
    
    init(referenceView: UIView) {
        self.referenceView = referenceView
        
        drawSnapshotOf(referenceView: referenceView) { [weak self] image in
            self?.add(imageToIssue: image)
        }
    }
    
    private func drawSnapshotOf(referenceView view: UIView, complete: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .default).async {
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
        
        self.persist(imageData: imageData) { url in
            self.issue.attachImage(withURL: url)
        }
    }
    
    private func persist(imageData data: Data, complete: @escaping (String) -> ()) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let saveLocation = documentsDirectory.randomURL(withExtension: "jpg")
        
        DispatchQueue.global(qos: .`default`).async {
            try? data.write(to: saveLocation)
        }
        
        try? ABEImgurAPIClient.sharedInstance.upload(imageData: data, success: complete)
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
