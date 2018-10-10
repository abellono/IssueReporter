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
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
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
        title = NSLocalizedString(navigationItem.title!,
                                  tableName: ReporterViewController.kABETableName,
                                  bundle: Bundle.bundleForLibrary(),
                                  comment: "title")
    }
    
    @IBAction func cancelIssueReporting(_ sender: AnyObject) {
        dismissIssueReporter(success: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "embed_segue" {
            imageCollectionViewController = segue.destination as! ImageCollectionViewController
            imageCollectionViewController.issueManager = issueManager
        }
    }
    
    @objc func saveIssue() {

        if let name = UserDefaults.standard.string(forKey: "tester_name") {
            return saveIssueInternal(name: name)
        }

        if (Reporter.shouldPresentNameAlert()) {
            return presentNameAlertBeforeSave()
        } else {
            saveIssueInternal(name: "No Name")
        }
    }

    private func saveIssueInternal(name: String) {

        UserDefaults.standard.set(name, forKey: "tester_name")

        issueManager.issue.title = titleTextField.text ?? ""
        issueManager.issue.issueDescription = descriptionTextView.text

        issueManager.saveIssue(completion: { [weak self] in
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                strongSelf.dismissIssueReporter(success: true)
            }
        })
    }
    
    func dismissIssueReporter(success: Bool) {
        view.endEditing(false)
        Reporter.dismissReporterView(with: success)
    }

    // Name Dialoge

    func presentNameAlertBeforeSave() {
        let alert = UIAlertController(title: "What is your first name?",
                                      message: "So we can shoot you a message to further investigate, if need be.",
                                      preferredStyle: .alert)

        alert.addTextField(configurationHandler: nil)

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?.first?.text else {
                return
            }

            self?.saveIssueInternal(name: name)
        }))

        present(alert, animated: true)
    }
}

extension ReporterViewController: IssueManagerDelegate {

    internal func issueManagerUploadingStateDidChange(issueManager: IssueManager) {
        imageCollectionViewController?.collectionView?.reloadData()
        
        if issueManager.isUploading {
            let spinner = UIActivityIndicatorView(style: .white)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            spinner.startAnimating()
            
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem.saveButton(self, action: #selector(ReporterViewController.saveIssue))
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    internal func issueManager(_ issueManager: IssueManager, didFailToUploadImage image: Image, error: IssueReporterError) {
        if issueManager.images.index(of: image) != nil {
            let alert = UIAlertController(error: error)
            present(alert, animated: true)
        }
    }

    internal func issueManager(_ issueManager: IssueManager, didFailToUploadFile file: File, error: IssueReporterError) {
        let alert = UIAlertController(error: error)
        present(alert, animated: true)
    }
    
    internal func issueManager(_ issueManager: IssueManager, didFailToUploadIssueWithError error: IssueReporterError) {
        let alert = UIAlertController(error: error)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.saveIssue()
        })
        
        present(alert, animated: true)
    }
}

extension ReporterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

        let length = textView.text?.count ?? 0
        let shouldHide = length > 0
        
        placeHolderLabel.isHidden = shouldHide
    }
}
