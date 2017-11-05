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

public protocol ReporterDelegate {

    func extraDebuggingInformationForIssue() -> [String: String]
}

public class Reporter: NSObject {

    public static var enabled: Bool = true
    public static var delegate: ReporterDelegate?

    private weak static var reporterViewController: ReporterViewController?

    private static var notificationObserver: NSObjectProtocol?

    public class func extraDebuggingInformationForIssue() -> [String: String] {

        var info = [
            "Current Localization": Locale.preferredLanguages[0],
            "Current Device": UIDevice.current.model,
            "iOS Version": UIDevice.current.systemVersion
        ]
        info["App Version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        info["Bundle Version"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        Reporter.delegate?.extraDebuggingInformationForIssue().forEach { info[$0] = $1 }

        return info
    }

    private override init() {

        Reporter.notificationObserver = NotificationCenter.default.addObserver(forName: .onWindowShake, object: nil, queue: .main) { notification in
            Reporter.showReporterView()
        }
    }

    deinit {
        if let notificationObserver = Reporter.notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }

    @objc public class func setup(repositoryName name: String, owner: String, token: String, imgurKey: String? = nil) {

        GithubAPIClient.githubRepositoryName = name
        GithubAPIClient.githubRepositoryOwner = owner
        GithubAPIClient.githubToken = token

        ABEImgurAPIClient.imgurAPIKey = imgurKey
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

