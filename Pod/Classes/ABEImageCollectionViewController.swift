//
//  ABEImageCollectionViewController.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/7/16.
//
//

import Foundation
import CoreGraphics
import QuickLook
import UIKit

class ABEImageCollectionViewController: UICollectionViewController, UINavigationControllerDelegate {
    
    static let kABEAddPictureCollectionViewCellReuseIdentifier = "CollectionViewAddPictureIdentifier"
    static let kABEPictureCollectionViewCellReuseIdentifier = "CollectionViewPictureIdentifier"
    
    static let kABEJPEGFileExtension = "jpg"
    static let kABEFirstCellImageName = "picture"
    
    static let kABEActionMenuCameraString = "Camera"
    static let kABEActionMenuPhotoLibrarySting = "Photo library"
    static let kABEActionMenuCancelString = "Cancel"
    static let kABEActionMenuTitlePickImageString = "Pick image"
    
    static let kABECollectionViewVerticalSpace = CGFloat(1.0)
    static let kABE16x9AspectRatio = CGFloat(9.0 / 16.0)
    static let kABEAddPictureCollectionViewCellIndex = 0
    static let kABEAddPictureCollectionViewCellOffset = 1
    
    var issueManager: ABEIssueManager! {
        didSet {
//            issueManager.completionBlock = {
//                Thread.abe_guaranteeBlockExecution { [weak self] in
//                    self?.collectionView!.reloadData()
//                }
//            }
        }
    }
}

extension ABEImageCollectionViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            issueManager.add(imageToIssue: image)
        }
    }
}

extension ABEImageCollectionViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return issueManager.localImageURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return issueManager.localImageURLs[index] as QLPreviewItem
    }
}

extension ABEImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 2.0 * ABEImageCollectionViewController.kABECollectionViewVerticalSpace
        return CGSize(width: height * ABEImageCollectionViewController.kABE16x9AspectRatio, height: height)
    }
}

// MARK: UICollectionViewDelegate

extension ABEImageCollectionViewController  {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == ABEImageCollectionViewController.kABEAddPictureCollectionViewCellIndex {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        } else {
            let preview = QLPreviewController()
            preview.dataSource = self
            
            preview.currentPreviewItemIndex = indexPath.row - ABEImageCollectionViewController.kABEAddPictureCollectionViewCellOffset
            self.navigationController?.present(preview, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.issueManager.images.count + ABEImageCollectionViewController.kABEAddPictureCollectionViewCellOffset
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == ABEImageCollectionViewController.kABEAddPictureCollectionViewCellIndex {
            return self.buildAddPictureCell(for: collectionView, at: indexPath)
        } else {
            return self.buildPictureCell(for: collectionView, at: indexPath)
        }
    }
    
    private func buildAddPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ABEImageCollectionViewController.kABEAddPictureCollectionViewCellReuseIdentifier, for: indexPath)
    }
    
    private func buildPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ABEImageCollectionViewController.kABEPictureCollectionViewCellReuseIdentifier, for: indexPath) as! ABEImageCollectionViewCell
        cell.imageView.image = issueManager.images[indexPath.row - ABEImageCollectionViewController.kABEAddPictureCollectionViewCellOffset]
        return cell
    }
}
