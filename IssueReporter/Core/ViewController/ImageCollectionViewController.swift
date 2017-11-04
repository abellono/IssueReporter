//
//  ImageCollectionViewController.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/7/16.
//
//

import Foundation
import CoreGraphics
import QuickLook
import UIKit

internal class ImageCollectionViewController: UICollectionViewController, UINavigationControllerDelegate {
    
    fileprivate static let kABEAddPictureCollectionViewCellReuseIdentifier = "CollectionViewAddPictureIdentifier"
    fileprivate static let kABEPictureCollectionViewCellReuseIdentifier = "CollectionViewPictureIdentifier"
    
    fileprivate static let kABEJPEGFileExtension = "jpg"
    fileprivate static let kABEFirstCellImageName = "picture"
    
    fileprivate static let kABEActionMenuCameraString = "Camera"
    fileprivate static let kABEActionMenuPhotoLibrarySting = "Photo library"
    fileprivate static let kABEActionMenuCancelString = "Cancel"
    fileprivate static let kABEActionMenuTitlePickImageString = "Pick image"
    
    fileprivate static let kABECollectionViewVerticalSpace = CGFloat(1.0)
    fileprivate static let kABE16x9AspectRatio = CGFloat(9.0 / 16.0)
    fileprivate static let kABEAddPictureCollectionViewCellIndex = 0
    fileprivate static let kABEAddPictureCollectionViewCellOffset = 1
    
    var issueManager: IssueManager!
}

extension ImageCollectionViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self?.issueManager.add(image)
            }
        }
    }
}

extension ImageCollectionViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return issueManager.images.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let imageURL = issueManager.images[index].localImageURL as QLPreviewItem? {
            return imageURL
        }
        
        return URL(string: "")! as QLPreviewItem
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
            let image = self.issueManager.images[index]
            
            if image.state.contents == .errored {
                self.presentRetryMenu(for: image)
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
        return self.issueManager.images.count + ImageCollectionViewController.kABEAddPictureCollectionViewCellOffset
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == ImageCollectionViewController.kABEAddPictureCollectionViewCellIndex {
            return self.buildAddPictureCell(for: collectionView, at: indexPath)
        } else {
            return self.buildPictureCell(for: collectionView, at: indexPath)
        }
    }
    
    private func buildAddPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewController.kABEAddPictureCollectionViewCellReuseIdentifier, for: indexPath)
    }
    
    private func buildPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewController.kABEPictureCollectionViewCellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let image = issueManager.images[indexPath.row - ImageCollectionViewController.kABEAddPictureCollectionViewCellOffset]
        cell.imageView.image = image.image
        cell.didErrorDuringUpload = image.state.contents == .errored
        return cell
    }
}
