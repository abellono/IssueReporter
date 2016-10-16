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

protocol ABEIssueManagerDelegate: class {
    
    func issueManagerUploadingStateDidChange(issueManager: ABEIssueManager)
    
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadImage image: Image, error: IssueReporterError)
    
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadIssueWithError error: IssueReporterError)
}

public class ABEIssueManager {
    
    public var isUploading: Bool {
        get {
            return images.filter {
                $0.state.contents == .uploading
            }.count > 0
        }
    }
    
    var issue: ABEIssue = ABEIssue()
    
    var images: [Image] {
        get {
            return issue.images
        }
    }
    
    weak var delegate: ABEIssueManagerDelegate?
    
    init(referenceView: UIView, delegate: ABEIssueManagerDelegate? = nil) {
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
        
        let image = Image(image: image)
        self.issue.images.append(image)
        self.persist(image)
    }
    
    public func retrySavingImage(image: Image) {
        assert(image.state.contents == .errored, "Can not retry a image that has not errored.")
        persistToCloud(image, withDispatchGroup: DispatchGroup())
    }
    
    private func persist(_ image: Image) {
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .`default`)
        
        group.enter()
        
        image.compressionCompletionBlock.contents = { image in
            
            self.persistToDisk(image, withDispatchGroup: group, dispatchQueue: queue)
            self.persistToCloud(image, withDispatchGroup: group)
            
            DispatchQueue.main.async {
                self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
            }
            
            group.leave()
        }
    }
    
    private func persistToDisk(_ image: Image, withDispatchGroup group: DispatchGroup, dispatchQueue queue: DispatchQueue) {
        
        assert(image.imageData != nil, "Image data must have been set.")
        
        queue.async(group: group) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let saveLocation = documentsDirectory.randomURL(withExtension: "jpg")
            
            try? image.imageData?.write(to: saveLocation)
            
            image.localImageURL = saveLocation
        }
    }
    
    private func persistToCloud(_ image: Image, withDispatchGroup group: DispatchGroup) {
        assert(image.imageData != nil, "Image data must have been set")
        
        group.enter()
        image.state.contents = .uploading
        
        do {
            try ABEImgurAPIClient.shared.upload(imageData: image.imageData!, errorHandler: { [weak self] error in
                group.leave()
                
                image.state.contents = .errored
                
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    self.delegate?.issueManager(self, didFailToUploadImage: image, error: error)
                    self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
                }
                
            }, success: { [weak self] url in
                group.leave()
                
                guard let `self` = self else { return }
                
                image.cloudImageURL = url
               
                DispatchQueue.main.async {
                    self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
                }
            })
        } catch {
            print("Error while making image upload request \(error)")
        }
    }
    
    public func saveIssue(completion: @escaping () -> ()) {
        do {
            try ABEGithubAPIClient.sharedInstance.saveIssue(issue: self.issue, success: completion) { [weak self] error in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    self.delegate?.issueManager(self, didFailToUploadIssueWithError: error)
                }
            }
        } catch {
            print("Error while trying to save issue : \(error)")
        }
    }
}
