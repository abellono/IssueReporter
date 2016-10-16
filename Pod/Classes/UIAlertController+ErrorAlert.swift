//
//  UIAlertController+ErrorAlert.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

internal extension UIAlertController {
    
    convenience init(error: NSError) {
        self.init(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .alert)
        
        self.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true)
        })
    }
    
    convenience init(error: IssueReporterError) {
        self.init(title: "Error", message: error.message, preferredStyle: .alert)
        
        self.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true)
        })
    }
}
