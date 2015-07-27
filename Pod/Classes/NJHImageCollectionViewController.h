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

@protocol NJHImageCollectionViewControllerDelegate <NSObject>

/**
 *  Called when the user selects an image to add to the github issue
 *
 *  @param image The image that the user selected, in data form
 */
- (void)userDidPickImageData:(NSData *)imageData;

@end

@interface NJHImageCollectionViewController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource>

@property (nonatomic, weak) id <NJHImageCollectionViewControllerDelegate> delegate;

/**
 *  Called when the user chooses a new image to include in the issue. This method saves that image to disk for QuickLook and tells the delegate to upload it to Imgur
 *
 *  @param image The image the user picked
 */
- (void)didPickImage:(UIImage *)image;

@end
