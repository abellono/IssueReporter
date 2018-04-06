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

@objc public protocol IssueReporterDelegate {

    func debugInformationForIssueReporter() -> [String: String]

    func debugFilesForIssueReporter() -> [String: Data]

    func didDismissIssueReporter(with success: Bool)

    // Behaviour

    func shouldAskForTesterName() -> Bool
}

@objcMembers public class Reporter: NSObject {

    public static var enabled: Bool = true
    public static var delegate: IssueReporterDelegate?

    private weak static var reporterViewController: ReporterViewController?

    private static var notificationObserver: NSObjectProtocol?

    internal class func standardDebuggingInformation() -> [String: String] {

        var info = [
            "Current Localization": Locale.preferredLanguages[0],
            "Current Device": UIDevice.current.model,
            "iOS Version": UIDevice.current.systemVersion
        ]

        info["App Version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        info["Bundle Version"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        info["Name"] = UserDefaults.standard.string(forKey: "tester_name")

        return info
    }
    
    internal class func additionalDebuggingInformation() -> [String : String] {
        return Reporter.delegate?.debugInformationForIssueReporter() ?? [:]
    }

    public class func shouldPresentNameAlert() -> Bool {
        return delegate?.shouldAskForTesterName() ?? false
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

        ImgurAPIClient.imgurClientId = imgurClientId

        Reporter.notificationObserver = NotificationCenter.default.addObserver(forName: .onWindowShake,
                                                                               object: nil,
                                                                               queue: .main) { notification in
            Reporter.showReporterView()
        }
    }

    public class func set(fileRepository name: String, owner: String) {
        GithubAPIClient.githubFileRepositoryName = name
        GithubAPIClient.githubFileRepositoryOwner = owner
    }

    @objc public class func showReporterView() {

        guard
            let rootViewController = UIApplication.shared.delegate?.window??.rootViewController,
            enabled
        else {
            return
        }

        let presentationTarget = presentingTargetForReporterViewController(cannidate: rootViewController)
        reporterViewController = ReporterViewController.instance(withIssueManager: IssueManager(referenceView: presentationTarget.view))

        guard let reporterViewController = self.reporterViewController else { return }

        let navigationController = UINavigationController(rootViewController: reporterViewController)
        presentationTarget.present(navigationController, animated: true)

    }

    class func dismissReporterView(with success: Bool) {
        FileManager.eraseStoredPicturesFromDisk()
        self.reporterViewController?.presentingViewController?.dismiss(animated: true)
        self.delegate?.didDismissIssueReporter(with: success)
    }

    private class func presentingTargetForReporterViewController(cannidate: UIViewController) -> UIViewController {

        if let newCannidate = cannidate.presentedViewController {
            return presentingTargetForReporterViewController(cannidate: newCannidate)
        } else {
            return cannidate
        }
    }
}

