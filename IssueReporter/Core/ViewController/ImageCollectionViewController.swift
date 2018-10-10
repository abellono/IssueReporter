//
//  ImageCollectionViewController.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import CoreGraphics
import QuickLook
import UIKit

internal class ImageCollectionViewController: UICollectionViewController, UINavigationControllerDelegate {
    
    private static let kABEAddPictureCollectionViewCellReuseIdentifier = "CollectionViewAddPictureIdentifier"
    private static let kABEPictureCollectionViewCellReuseIdentifier = "CollectionViewPictureIdentifier"
    
    private static let kABEJPEGFileExtension = "jpg"
    private static let kABEFirstCellImageName = "picture"
    
    private static let kABEActionMenuCameraString = "Camera"
    private static let kABEActionMenuPhotoLibrarySting = "Photo library"
    private static let kABEActionMenuCancelString = "Cancel"
    private static let kABEActionMenuTitlePickImageString = "Pick image"
    
    private static let kABECollectionViewVerticalSpace = CGFloat(1.0)
    private static let kABE16x9AspectRatio = CGFloat(9.0 / 16.0)
    private static let kABEAddPictureCollectionViewCellIndex = 0
    private static let kABEAddPictureCollectionViewCellOffset = 1
    
    var issueManager: IssueManager!
}

extension ImageCollectionViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.presentingViewController?.dismiss(animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                self?.issueManager.add(image: image)
            }
        }
    }
}

extension ImageCollectionViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return issueManager.images.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let imageURL = issueManager.images[index].localImageURL as QLPreviewItem? else {
            fatalError("Could not find preview item at index \(index)")
        }

        return imageURL
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 2.0 * ImageCollectionViewController.kABECollectionViewVerticalSpace
        return CGSize(width: height * ImageCollectionViewController.kABE16x9AspectRatio, height: height)
    }
}

extension ImageCollectionViewController  {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == ImageCollectionViewController.kABEAddPictureCollectionViewCellIndex {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        } else {

            let index = indexPath.row - ImageCollectionViewController.kABEAddPictureCollectionViewCellOffset
            let image = issueManager.images[index]
            
            if image.state == .errored {
                presentRetryMenu(for: image)
                return
            }
            
            let preview = QLPreviewController()
            preview.dataSource = self
            
            preview.currentPreviewItemIndex = index
            navigationController?.present(preview, animated: true)
        }
    }
    
    internal func presentRetryMenu(for image: Image) {

        let alertController = UIAlertController(title: "Failed to upload image", message: "There was an error uploading the image.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.issueManager.retrySaving(image: image)
        })
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alertController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return issueManager.images.count + ImageCollectionViewController.kABEAddPictureCollectionViewCellOffset
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == ImageCollectionViewController.kABEAddPictureCollectionViewCellIndex {
            return buildAddPictureCell(for: collectionView, at: indexPath)
        } else {
            return buildPictureCell(for: collectionView, at: indexPath)
        }
    }
    
    private func buildAddPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewController.kABEAddPictureCollectionViewCellReuseIdentifier, for: indexPath)
    }
    
    private func buildPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewController.kABEPictureCollectionViewCellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let image = issueManager.images[indexPath.row - ImageCollectionViewController.kABEAddPictureCollectionViewCellOffset]
        cell.imageView.image = image.image
        cell.didErrorDuringUpload = image.state == .errored
        return cell
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
