//
//  ReporterViewController.swift
//  IssueReporter
//
//  Created by Hakon Hanesand on 10/6/16.
//  Copyright © 2017 abello. All rights reserved.
//
//

import Foundation
import UIKit
import CoreGraphics

internal class ReporterViewController: UIViewController {
    
    private static let kABETextFieldInset = 14
    
    private static let kABEdescriptionTextViewCornerRadius: CGFloat = 4
    private static let kABEdescriptionTextViewBorderWidth: CGFloat = 0.5
    
    private static let kABETableName = "IssueReporter-Localizable"
    
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var placeHolderLabel: UILabel!
    
    private var imageCollectionViewController: ImageCollectionViewController!
    
    var issueManager: IssueManager! {
        didSet {
            issueManager.delegate = self
        }
    }
    
    class func instance(withIssueManager manager: IssueManager) -> ReporterViewController {

        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle.bundleForLibrary())
        let reporterViewController = storyboard.instantiateInitialViewController() as! ReporterViewController
        
        reporterViewController.issueManager = manager
        
        return reporterViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextView()
        setupLocalization()
        
        navigationController?.navigationBar.barTintColor = UIColor.blueNavigationBarColor()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    private func configureTextView() {
        
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: ReporterViewController.kABETextFieldInset, height: ReporterViewController.kABETextFieldInset))
        
        titleTextField.leftViewMode = .always
        titleTextField.leftView = spacerView
        
        descriptionTextView.layer.borderColor = UIColor.greyBorderColor().cgColor
        descriptionTextView.layer.cornerRadius = ReporterViewController.kABEdescriptionTextViewCornerRadius
        descriptionTextView.layer.borderWidth = ReporterViewController.kABEdescriptionTextViewBorderWidth
        
        let textFieldInset = CGFloat(ReporterViewController.kABETextFieldInset)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: textFieldInset, left: textFieldInset, bottom: 0, right: textFieldInset)
        descriptionTextView.delegate = self
    }
    
    private func setupLocalization() {
        titleTextField.placeholder = NSLocalizedString(titleTextField.placeholder!,
                                                       tableName: ReporterViewController.kABETableName,
                                                       bundle: Bundle.bundleForLibrary(),
                                                       comment: "title of issue")
        placeHolderLabel.text = NSLocalizedString(placeHolderLabel.text!,
                                                  tableName: ReporterViewController.kABETableName,
                                                  bundle: Bundle.bundleForLibrary(),
                                                  comment: "placeholder for description")
        title = NSLocalizedString(self.navigationItem.title!,
                                  tableName: ReporterViewController.kABETableName,
                                  bundle: Bundle.bundleForLibrary(),
                                  comment: "title")
    }
    
    @IBAction func cancelIssueReporting(_ sender: AnyObject) {
        self.dismissIssueReporter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "embed_segue" {
            self.imageCollectionViewController = segue.destination as! ImageCollectionViewController
            self.imageCollectionViewController.issueManager = self.issueManager
        }
    }
    
    @objc func saveIssue() {
        
        issueManager.issue.title = titleTextField.text
        issueManager.issue.issueDescription = descriptionTextView.text
        
        issueManager.saveIssue { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(false)
                self?.dismissIssueReporter()
            }
        }
    }
    
    func dismissIssueReporter() {
        FileManager.eraseStoredPicturesFromDisk()
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func titleTextDidChange(_ sender: UITextField) {
        updateCheckmarkEnabledState()
    }
}

extension ReporterViewController: IssueManagerDelegate {

    internal func issueManagerUploadingStateDidChange(issueManager: IssueManager) {
        self.imageCollectionViewController?.collectionView?.reloadData()
        
        if issueManager.isUploading {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            spinner.startAnimating()
            
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.saveButton(self, action: #selector(ReporterViewController.saveIssue))
            updateCheckmarkEnabledState()
        }
    }
    
    internal func issueManager(_ issueManager: IssueManager, didFailToUploadImage image: Image, error: IssueReporterError) {
        if self.issueManager.images.index(of: image) != nil {
            let alert = UIAlertController(error: error)
            self.present(alert, animated: true)
        }
    }
    
    internal func issueManager(_ issueManager: IssueManager, didFailToUploadIssueWithError error: IssueReporterError) {
        let alert = UIAlertController(error: error)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            issueManager.saveIssue { [weak self] in
                self?.view.endEditing(false)
                self?.dismissIssueReporter()
            }
        })
        
        self.present(alert, animated: true)
    }
}

extension ReporterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

        let length = textView.text?.count ?? 0
        let shouldHide = length > 0
        
        placeHolderLabel.isHidden = shouldHide
        
        updateCheckmarkEnabledState()
    }
    
    internal func updateCheckmarkEnabledState() {
        let hasTitle = (titleTextField.text?.count ?? 0) > 0
        let hasDescription = (descriptionTextView.text?.count ?? 0) > 0
        navigationItem.rightBarButtonItem?.isEnabled = hasTitle && hasDescription
    }
}
