//
//  ABEReporter.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit

fileprivate extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public protocol ABEReporterDelegate {
    
    func extraDebuggingInformationForIssue() -> [String : String]
}

public class ABEReporter: NSObject {
    
    public static var enabled: Bool = true
    internal static var delegate: ABEReporterDelegate?
    
    private weak static var reporterViewController: ABEReporterViewController?
    private static var notificationObserver: NSObjectProtocol? = nil
    
    internal class func extraDebuggingInformationForIssue() -> [String : String] {
        var info = ["Current Localization : " : Locale.preferredLanguages[0],
                    "Current Device : " : UIDevice.current.model,
                    "iOS Version : " : UIDevice.current.systemVersion]
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            info.updateValue(appVersion, forKey: "App Version")
        }
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            info.updateValue(bundleVersion, forKey: "Bundle Version")
        }
        
        if let extra = ABEReporter.delegate?.extraDebuggingInformationForIssue() {
            info.update(other: extra)
        }
    
        return info
    }
    
    open override static func initialize() {
        
        if self !== ABEReporter.self {
            return
        }
        
        ABEReporter.notificationObserver = NotificationCenter.default.addObserver(forName: .onWindowShake, object: nil, queue: .main) { notification in
            ABEReporter.showReporterView()
        }
    }
    
    deinit {
        if let notificationObserver = ABEReporter.notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
    
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
