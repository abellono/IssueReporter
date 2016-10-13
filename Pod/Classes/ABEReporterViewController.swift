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

class ABEReporterViewController: UIViewController {
    
    private static let kABETextFieldInset = 14
    
    private static let kABEdescriptionTextViewCornerRadius = CGFloat(4);
    private static let kABEdescriptionTextViewBorderWidth = CGFloat(0.5);
    
    private static let kABETableName = "IssueReporter-Localizable"
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    fileprivate var imageCollectionViewController: ABEImageCollectionViewController!
    
    public var issueManager: ABEIssueManager! {
        didSet {
            issueManager.delegate = self
        }
    }
    
    public class func instance(withIssueManager manager: ABEIssueManager) -> ABEReporterViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle.bundleForLibrary())
        let reporterViewController = storyboard.instantiateInitialViewController() as! ABEReporterViewController
        
        reporterViewController.issueManager = manager
        
        return reporterViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextView()
        setupLocalization()
        
        navigationController?.navigationBar.barTintColor = UIColor.blueNavigationBarColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    private func configureTextView() {
        
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: ABEReporterViewController.kABETextFieldInset, height: ABEReporterViewController.kABETextFieldInset))
        
        titleTextField.leftViewMode = .always
        titleTextField.leftView = spacerView
        
        descriptionTextView.layer.borderColor = UIColor.greyBorderColor().cgColor
        descriptionTextView.layer.cornerRadius = ABEReporterViewController.kABEdescriptionTextViewCornerRadius
        descriptionTextView.layer.borderWidth = ABEReporterViewController.kABEdescriptionTextViewBorderWidth
        
        let textFieldInset = CGFloat(ABEReporterViewController.kABETextFieldInset)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: textFieldInset, left: textFieldInset, bottom: 0, right: textFieldInset)
        descriptionTextView.delegate = self
    }
    
    private func setupLocalization() {
        titleTextField.text = NSLocalizedString(titleTextField.text!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary(), comment: "title of issue")
        placeHolderLabel.text = NSLocalizedString(placeHolderLabel.text!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary(), comment: "placeholder")
        title = NSLocalizedString(self.navigationItem.title!, tableName: ABEReporterViewController.kABETableName, bundle: Bundle.bundleForLibrary(), comment: "title")
    }
    
    @IBAction func cancelIssueReporting(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "embed_segue" {
            self.imageCollectionViewController = segue.destination as! ABEImageCollectionViewController
            self.imageCollectionViewController.issueManager = self.issueManager
        }
    }
    
    public func saveIssue() {
        
        issueManager.issue.title = titleTextField.text
        issueManager.issue.issueDescription = descriptionTextView.text

        issueManager.saveIssue { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(false)
                self?.dismissIssueReporter()
            }
        }
    }
    
    fileprivate func dismissIssueReporter() {
        FileManager.clearDocumentsDirectory()
        presentingViewController?.dismiss(animated: true)
    }
    
    deinit {
        DispatchQueue.global(qos: .background).async {
            FileManager.clearDocumentsDirectory()
        }
    }
}

extension ABEReporterViewController: ABEIssueManagerDelegate {

    func issueManagerUploadingStateDidChange(issueManager: ABEIssueManager) {
        DispatchQueue.main.async {
            self.imageCollectionViewController?.collectionView?.reloadData()
            
            if issueManager.isUploading {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
                spinner.startAnimating()
                
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.saveButton(self, action: #selector(ABEReporterViewController.saveIssue))
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func issueManager(_ issueManager: ABEIssueManager, didFailToUploadIssueWithError error: Error) {
        let alertController = UIAlertController(error: error as NSError)
        
        alertController.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] action in
            issueManager.saveIssue { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.view.endEditing(false)
                    self?.dismissIssueReporter()
                }
            }
        })
    }
}

extension ABEReporterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let length = textView.text?.characters.count ?? 0
        placeHolderLabel.isHidden = length > 0
    }
}
