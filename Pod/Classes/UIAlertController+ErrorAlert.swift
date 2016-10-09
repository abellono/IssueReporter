//
//  UIAlertController+ErrorAlert.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

extension UIAlertController {
    
    convenience init(error: NSError) {
        self.init(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .alert)
        
        self.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true)
        })
    }
}
