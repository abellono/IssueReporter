//
//  IssueManager.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import UIKit

internal let kABECompressionRatio: CGFloat = 5

internal protocol IssueManagerDelegate: class {
    
    func issueManagerUploadingStateDidChange(issueManager: IssueManager)

    func issueManager(_ issueManager: IssueManager, didFailToUploadImage image: Image, error: IssueReporterError)
    func issueManager(_ issueManager: IssueManager, didFailToUploadFile file: File, error: IssueReporterError)

    func issueManager(_ issueManager: IssueManager, didFailToUploadIssueWithError error: IssueReporterError)
}

internal class IssueManager {

    weak var delegate: IssueManagerDelegate? {
        didSet {
            delegate?.issueManagerUploadingStateDidChange(issueManager: self)
        }
    }

    var issue: Issue = Issue()

    var isUploading: Bool {
        let imageUploadingCount = images.filter { $0.state == .uploading }.count
        let fileUploadingCount = files.filter { $0.state == .uploading }.count

        return (fileUploadingCount + imageUploadingCount) > 0
    }
    
    var images: [Image] {
        return issue.images
    }

    var files: [File] {
        return issue.files
    }
    
    init(referenceView: UIView, delegate: IssueManagerDelegate? = nil) {
        self.delegate = delegate

        let referenceImage = drawSnapshotOf(referenceView: referenceView)
        add(image: referenceImage)

        if let debugFiles = Reporter.delegate?.debugFilesForIssueReporter() {
            for (path, contents) in debugFiles {
                addFile(at: path, with: contents)
            }
        }
    }
    
    private func drawSnapshotOf(referenceView view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
    
    func add(image: UIImage) {
        let image = Image(image: image)
        issue.images.append(image)
        persist(image: image)
    }

    func retrySaving(image: Image) {
        assert(image.state == .errored, "Can not retry a image that has not errored.")

        guard let data = image.imageData else {
            print("can not retry saving image that has no data")
            return
        }

        persistToCloud(image: image, with: data)
    }

    func addFile(at path: String, with contents: Data) {
        let file = File(path: path, data: contents)
        issue.files.append(file)
        persist(file: file)
    }

    // MARK : File Persistance

    func persist(file: File) {
        file.state = .uploading

        GithubAPIClient.shared.upload(file: file.data, for: issue, at: file.path, success: { [weak self] (url) in
            guard let strongSelf = self else { return }

            file.htmlURL = url
            file.state = .done
            strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: strongSelf)
        }) { [weak self] (error) in
            guard let strongSelf = self else { return }
            
            file.state = .errored
            strongSelf.delegate?.issueManager(strongSelf, didFailToUploadFile: file, error: error)
            strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: strongSelf)
        }
    }

    // MARK : Image Persistance

    private func persist(image: Image) {
        image.compressionCompletionBlock = { [weak self] image in

            guard
                let data = image.imageData,
                let strongSelf = self
            else { return }

            strongSelf.persistToDisk(image: image, with: data)
            strongSelf.persistToCloud(image: image, with: data)
        }
    }

    private func persistToDisk(image: Image, with data: Data) {
        DispatchQueue.global(qos: .default).async {
            FileManager.write(data: data, completion: { url in
                image.localImageURL = url
            }, error: { error in
                print("Error saving image or screenshot to disk. Error : \(error)")
            })
        }
    }
    
    private func persistToCloud(image: Image, with data: Data) {
        image.state = .uploading
        delegate?.issueManagerUploadingStateDidChange(issueManager: self)
        
        ImgurAPIClient.shared.upload(data: data, success: { [weak self] (url) in
            guard let strongSelf = self else { return }

            image.cloudImageURL = url
            image.state = .done
            strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: strongSelf)

        }, failure: { [weak self] (error) in
            guard let strongSelf = self else { return }

            image.state = .errored

            strongSelf.delegate?.issueManager(strongSelf, didFailToUploadImage: image, error: error)
            strongSelf.delegate?.issueManagerUploadingStateDidChange(issueManager: strongSelf)
        })
    }
    
    func saveIssue(completion: @escaping () -> ()) {
        GithubAPIClient.shared.save(issue: self.issue, success: completion) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.issueManager(strongSelf, didFailToUploadIssueWithError: error)
        }
    }
}
