//
//  Reporter.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import UIKit

@objc public protocol ReporterDelegate {
    func debugInformationForIssueReporter() -> [String: String]
}

public class Reporter: NSObject {

    public static var enabled: Bool = true
    public static var delegate: ReporterDelegate?

    private weak static var reporterViewController: ReporterViewController?

    private static var notificationObserver: NSObjectProtocol?

    public class func debugInformationForIssueReporter() -> [String: String] {

        var info = [
            "Current Localization": Locale.preferredLanguages[0],
            "Current Device": UIDevice.current.model,
            "iOS Version": UIDevice.current.systemVersion
        ]
        
        info["App Version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        info["Bundle Version"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        Reporter.delegate?.debugInformationForIssueReporter().forEach { info[$0] = $1 }

        return info
    }

    // Made private to make sure no-one creates their own Reporter instance
    private override init() { }

    @objc public class func setup(repositoryName: String,
                                  owner: String,
                                  githubToken: String,
                                  imgurClientId: String? = nil) {

        UIWindow.swizzleMotionEnded()

        GithubAPIClient.githubRepositoryName = repositoryName
        GithubAPIClient.githubRepositoryOwner = owner
        GithubAPIClient.githubToken = githubToken

        ABEImgurAPIClient.imgurClientId = imgurClientId

        Reporter.notificationObserver = NotificationCenter.default.addObserver(forName: .onWindowShake,
                                                                               object: nil,
                                                                               queue: .main) { notification in
            Reporter.showReporterView()
        }
    }

    @objc public class func showReporterView() {

        guard self.reporterViewController == nil && enabled else {
            return
        }

        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            print("No root view controller")
            return
        }

        let presentationTarget = presentingTargetForReporterViewController(cannidate: rootViewController)
        let reporterViewController = ReporterViewController.instance(withIssueManager: IssueManager(referenceView: presentationTarget.view))

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

