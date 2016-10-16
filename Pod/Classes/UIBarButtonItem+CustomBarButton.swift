//
//  UIBarButtonItem+CustomBarButton.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/8/16.
//
//

import Foundation
import UIKit

internal extension UIBarButtonItem {
    
    fileprivate static let kABECloseButtonImage = "close"
    fileprivate static let kABESaveButtonImage = "save"
    
    static func backButton(_ target: AnyObject, action: Selector, color: UIColor) -> UIBarButtonItem {
        let cocoapodsBundle = Bundle.bundleForLibrary()
        let image = UIImage(named: UIBarButtonItem.kABECloseButtonImage, in: cocoapodsBundle, compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        
        button.tintColor = color
        
        return button
    }
    
    static func saveButton(_ target: AnyObject, action: Selector) -> UIBarButtonItem {
        let cocoapodsBundle = Bundle.bundleForLibrary()
        let image = UIImage(named: UIBarButtonItem.kABESaveButtonImage, in: cocoapodsBundle, compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        
        button.imageInsets = UIEdgeInsets(top: 3, left: -6, bottom: 0, right: 0)
        button.tintColor = UIColor.white
        
        return button
    }
}
