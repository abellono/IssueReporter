//
//  UIBarButtonItem+CustomBarButton.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import UIKit

internal extension UIBarButtonItem {
    
    private static let kABECloseButtonImage = "close"
    private static let kABESaveButtonImage = "save"
    
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
