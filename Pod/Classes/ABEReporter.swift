//
//  ABEReporter.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

public class ABEReporter: NSObject {
    
    public static var enabled: Bool = true
    private weak static var reporterViewController: ABEReporterViewController?
    
    private static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return formatter
    }
    
    private override init() {}
    
    public class func setup(repositoryName name: String, owner: String, token: String, imgurKey: String? = nil) {
        ABEGithubAPIClient.githubRepositoryName = name
        ABEGithubAPIClient.githubRepositoryOwner = owner
        ABEGithubAPIClient.githubToken = token
        
        ABEImgurAPIClient.imgurAPIKey = imgurKey
    }
    
    public class func showReporterView() {
        if self.reporterViewController != nil || !enabled {
            return;
        }
        
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            print("No root view controller ")
            return
        }
        
        let presentationTarget = presentingTargetForReporterViewController(cannidate: rootViewController)
        let reporterViewController = ABEReporterViewController.instance(withIssueManager: ABEIssueManager(referenceView: presentationTarget.view))
        
        self.reporterViewController = reporterViewController
        let navigationController = UINavigationController(rootViewController: reporterViewController)
        
        presentationTarget.present(navigationController, animated: true)
    }
    
    private class func presentingTargetForReporterViewController(cannidate: UIViewController) -> UIViewController {
    
        if let newCannidate = cannidate.presentedViewController {
            return presentingTargetForReporterViewController(cannidate: newCannidate)
        } else {
            return cannidate
        }
    }
}
