//
//  UIImage+Rotate.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/8/16.
//
//

import Foundation
import UIKit
import CoreGraphics

internal extension UIImage {
    
    func applyRotationToImageData() -> UIImage {

        if self.imageOrientation == .up || self.imageOrientation == .upMirrored {
            let size = self.size
            
            UIGraphicsBeginImageContext(size)
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image!
        }
        
        return self
    }
}
