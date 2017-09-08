//
//  ABEissueManager.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

fileprivate extension Array where Element: Equatable {
    
    mutating func removeFirst(element: Element) {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
}

private let kABECompressionRatio: CGFloat = 5

internal protocol ABEIssueManagerDelegate: class {
    func issueManagerUploadingStateDidChange(issueManager: ABEIssueManager)
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadImage image: Image, error: IssueReporterError)
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadIssueWithError error: IssueReporterError)
}

internal class ABEIssueManager {
    
    var isUploading: Bool {
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
            self?.add(image)
        }
    }
    
    private func drawSnapshotOf(referenceView view: UIView, complete: @escaping (UIImage) -> Void) {

        DispatchQueue.global(qos: .userInitiated).async {

            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            complete(image)
        }
    }
    
    func add(_ image: UIImage) {
        let image = Image(image: image)
        self.issue.images.append(image)
        self.persist(image)
    }
    
    func retrySaving(image: Image) {
        assert(image.state.contents == .errored, "Can not retry a image that has not errored.")
        persistToCloud(image, with: DispatchGroup())
    }
    
    private func persist(_ image: Image) {
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .`default`)
        
        group.enter()
        
        image.compressionCompletionBlock.contents = { image in
            
            self.persistToDisk(image, with: group, on: queue)
            self.persistToCloud(image, with: group)
            
            DispatchQueue.main.async {
                self.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
            }
            
            group.leave()
        }
    }
    
    private func persistToDisk(_ image: Image, with group: DispatchGroup, on queue: DispatchQueue) {
        
        guard let imageData = image.imageData else {
            print("Image data not set!")
            return
        }
        
        queue.async(group: group) {

            FileManager.write(data: imageData, completion: { url in
                image.localImageURL = url
            }, error: { error in
                print("Error saving image or screenshot to disk. Error : \(error)")
            })
        }
    }
    
    private func persistToCloud(_ image: Image, with group: DispatchGroup) {

        assert(image.imageData != nil, "Image data must have been set")
        
        group.enter()
        image.state.contents = .uploading
        
        do {
            try ABEImgurAPIClient.shared.upload(imageData: image.imageData!, errorHandler: { [weak self] error in
                group.leave()
                
                image.state.contents = .errored
                
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.issueManager(self, didFailToUploadImage: image, error: error)
                    strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: strongSelf)
                }
                
            }, success: { [weak self] url in
                group.leave()
                
                guard let strongSelf = self else { return }
                
                image.cloudImageURL = url
               
                DispatchQueue.main.async {
                    strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: self)
                }
            })
        } catch {
            print("Error while making image upload request \(error)")
        }
    }
    
    func saveIssue(completion: @escaping () -> Void) {
        do {
            try ABEGithubAPIClient.shared.save(issue: self.issue, success: completion) { [weak self] error in
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.issueManager(strongSelf, didFailToUploadIssueWithError: error)
                }
            }
        } catch {
            print("Error while trying to save issue : \(error)")
        }
    }
}
