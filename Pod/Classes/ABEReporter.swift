//
//  ABEReporter.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

public class ABEReporter {
    
    public static var enabled: Bool = true
    private static var reporterViewController: ABEReporterViewController?
    
    private static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return formatter
    }
    
    private init() {}
    
    class func setup(repositoryName name: String, owner: String, token: String, imgurKey imgurKey: String? = nil) {
        ABEGithubAPIClient.githubRepositoryName = name
        ABEGithubAPIClient.githubRepositoryOwner = owner
        ABEGithubAPIClient.githubToken = token
        
        if let imgurKey = imgurKey {
            ABEImgurAPIClient.imgurAPIKey = imgurKey
        }
    }
    
    class func showReporterView() {
        if self.reporterViewController != nil || !enabled {
            return;
        }
        
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            print("No root view controller ")
            return
        }
        
        let presentationTarget = presentingTargetForReporterViewController(cannidate: rootViewController)
        
        self.reporterViewController = ABEReporterViewController.instance(withIssueManager: ABEIssueManager(referenceView: presentationTarget.view))
        let navigationController = UINavigationController(rootViewController: reporterViewController!)
    }
    
    private class func presentingTargetForReporterViewController(cannidate: UIViewController) -> UIViewController {
    
        if let newCannidate = cannidate.presentedViewController {
            return presentingTargetForReporterViewController(cannidate: newCannidate)
        } else {
            return cannidate
        }
    }
}
