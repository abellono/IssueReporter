//
//  ABEissueManager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

static private let kABECompressionRatio = CGFloat(5.0)

class ABEIssueManager {
    
    public var isUploading = false
    
    fileprivate var uploadingImages: [Data]
    private var images: [UIImage]
    
    let referenceView: UIView
    let viewController: UIViewController
    
    init(referenceView: UIView, viewController: UIViewController) {
        self.referenceView = referenceView
        self.viewController = viewController
        
        process(referenceView: referenceView) { image in
            
        }
    }
    
    private func process(referenceView view: UIView, complete: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .default).async {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            complete(image)
        }
    }
    
    private func add(image: UIImage, to issue: inout ABEIssue) {
        
        let flippedImage = image.applyRotationToImageData()
        let imageData = UIImageJPEGRepresentation(flippedImage, kABECompressionRatio)!
        
        self.images.append(flippedImage)
        
        self.persist(imageData: imageData) { url in
            issue.attachImage(withURL: url)
        }
    }
}

extension ABEIssue {
    
    mutating func add(image image: UIImage) {
        let flippedImage = image.applyRotationToImageData()
        let imageData = UIImageJPEGRepresentation(flippedImage, kABECompressionRatio)!
        
        self.persist(imageData: imageData) { url in
            self.attachImage(withURL: url)
        }
    }
    
    private func persist(imageData data: Data, complete: @escaping (String) -> ()) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let saveLocation = documentsDirectory.randomURL(withExtension: "jpg")
        
        DispatchQueue.global(qos: .`default`).async {
            try? data.write(to: saveLocation)
        }
        
        ABEImgurAPIClient.sharedInstance.upload(imageData: data, success: complete)
    }
}
