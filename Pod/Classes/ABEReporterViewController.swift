//
//  ABEReporterViewController.swift
//  Pods
//
//  Created by Hakon Hanesand on 10/9/16.
//
//

import Foundation
import UIKit
import CoreGraphics

final class ABEReporterViewController: UIViewController {
    
    private static let kABETextFieldInset = 14
    
    private static let kABEdescriptionTextViewCornerRadius = CGFloat(4);
    private static let kABEdescriptionTextViewBorderWidth = CGFloat(0.5);
    
    private static let kABETableName = "IssueReporter-Localizable"
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    private let imageCollectionViewController: ABEImageCollectionViewController
    public var issueManager: ABEIssueManager!
    
    public class func instance(withIssueManager manager: ABEIssueManager) -> ABEReporterViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle.bundleForLibrary)
        let reporterViewController = storyboard.instantiateInitialViewController() as! ABEReporterViewController
        
        reporterViewController.issueManager = manager
        
        return reporterViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.blueNavigationBarColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    private func configureTextView() {
        
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: ABEReporterViewController.kABETextFieldInset, height: ABEReporterViewController.kABETextFieldInset))
        
        titleTextField.leftViewMode = .always
        titleTextField.leftView = spacerView
        
        descriptionTextView.layer.borderColor = UIColor.greyBorderColor.cgColor
        descriptionTextView.layer.cornerRadius = ABEReporterViewController.kABEdescriptionTextViewCornerRadius
        descriptionTextView.layer.borderWidth = ABEReporterViewController.kABEdescriptionTextViewBorderWidth
        
        let textFieldInset = CGFloat(ABEReporterViewController.kABETextFieldInset)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: textFieldInset, left: textFieldInset, bottom: 0, right: textFieldInset)
    }
    
    private func setupLocalization() {
        titleTextField.text = NSLocalizedString(titleTextField.text!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary, comment: "title of issue")
        placeHolderLabel.text = NSLocalizedString(placeHolderLabel.text!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary, comment: "placeholder")
        title = NSLocalizedString(title!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary, comment: "title")
    }
    
    private func saveIssue() {

        issueManager.saveIssue { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(false)
            }
            
            self?.dismissIssueReporter()
        }
    }
    
    private func dismissIssueReporter() {
        FileManager.clearDocumentsDirectory()
        presentingViewController?.dismiss(animated: true)
    }
}
