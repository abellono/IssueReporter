//
//  UIWindow+Shake.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import UIKit

internal extension Notification.Name {
    static let onWindowShake = Notification.Name("shakeyshakey")
}

internal extension UIWindow {

    internal static var _onceTracker = [String]()

    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.

     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    internal class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }

    internal class func swizzleMotionEnded() {

        UIWindow.once(token: "swizzleMotionEnded") {

            let originalSelector = #selector(UIWindow.motionEnded(_:with:))
            let swizzledSelector = #selector(UIWindow.abe_motionEnded(_:with:))

            let originalMethod = class_getInstanceMethod(UIWindow.self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIWindow.self, swizzledSelector)

            let didAddMethod = class_addMethod(UIWindow.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

            if didAddMethod {
                class_replaceMethod(UIWindow.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
    }

    @objc internal func abe_motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if let event = event, event.type == .motion, event.subtype == .motionShake {
            NotificationCenter.default.post(name: .onWindowShake, object: self)
        }
    }
}

