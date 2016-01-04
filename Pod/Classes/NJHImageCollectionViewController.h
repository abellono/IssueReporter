//
//  NHJImageCollectionViewController.h
//  IssueReporter
//
//  Created by Hakon Hanesand on 7/23/15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import Foundation;
@import UIKit;
@import QuickLook;

@class ABEIssueManager;

@interface NJHImageCollectionViewController : UICollectionViewController <UIImagePickerControllerDelegate, QLPreviewControllerDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

@property (nonatomic) ABEIssueManager *issueManager;

@end
