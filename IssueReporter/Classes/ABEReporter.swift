import Foundation
import UIKit

public protocol ABEReporterDelegate {

    func extraDebuggingInformationForIssue() -> [String: String]
}

public class ABEReporter: NSObject {

    public static var enabled: Bool = true
    public static var delegate: ABEReporterDelegate?

    private weak static var reporterViewController: ABEReporterViewController?

    private static var notificationObserver: NSObjectProtocol?

    public class func extraDebuggingInformationForIssue() -> [String: String] {

        var info = [
            "Current Localization": Locale.preferredLanguages[0],
            "Current Device": UIDevice.current.model,
            "iOS Version": UIDevice.current.systemVersion
        ]
        info["App Version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        info["Bundle Version"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        ABEReporter.delegate?.extraDebuggingInformationForIssue().forEach { info[$0] = $1 }

        return info
    }

    private override init() {

        ABEReporter.notificationObserver = NotificationCenter.default.addObserver(forName: .onWindowShake, object: nil, queue: .main) { notification in
            ABEReporter.showReporterView()
        }
    }

    deinit {
        if let notificationObserver = ABEReporter.notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }

    @objc public class func setup(repositoryName name: String, owner: String, token: String, imgurKey: String? = nil) {

        ABEGithubAPIClient.githubRepositoryName = name
        ABEGithubAPIClient.githubRepositoryOwner = owner
        ABEGithubAPIClient.githubToken = token

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

