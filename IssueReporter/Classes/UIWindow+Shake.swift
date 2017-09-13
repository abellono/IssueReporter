//
//  UIWindow+Shake.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/8/16.
//
//

import Foundation
import UIKit

internal extension Notification.Name {
    static let onWindowShake = Notification.Name("shakeyshakey")
}

extension UIWindow {

    open override static func initialize() {

        if self !== UIWindow.self {
            return
        }
        
        // Best way of doing dispatch_once in swift
        let _: () = {
            let originalSelector = #selector(UIWindow.motionEnded(_:with:))
            let swizzledSelector = #selector(UIWindow.abe_motionEnded(_:with:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }()
    }

    open func abe_motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if let event = event, event.type == .motion, event.subtype == .motionShake {
            NotificationCenter.default.post(name: .onWindowShake, object: self)
        }
    }
}
