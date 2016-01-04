//
//  NHJImageCollectionViewController.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 7/23/15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

// View Controllers
#import "NJHImageCollectionViewController.h"

// Views
#import "NJHImageCollectionViewCell.h"

// Categories
#import "UIImage+NJH_AutoRotation.h"
#import "NSURL+NJH_RandomImageURL.h"
#import "NSBundle+ABEBundle.h"
#import "NSThread+ABEMainThreadRunner.h"

// Helpers
#import "NJHReporter.h"
#import "ABEIssueManager.h"

/**
 *  The space that is added above and below the collection view cells
 */
static int const kNJHCollectionViewVerticalSpace = 1;

/**
 *  Used to calculate a correct size for the image cells in order to optimally fit the aspect ratio for an image
 */
static double const kNJH16x9AspectRatio = 9.0 / 16.0;

/**
 *  The index of the special collection view cell that the user can click to upload a new image
 */
static int const kNJHAddPictureCollectionViewCellIndex = 0;

/**
 *  The offset we use to transition between the model and index paths recieved from the collection view
 */
static int const kNJHAddPictureCollectionViewCellOffset = 1;

static NSString * const kNJHAddPictureCollectionViewCellReuseIdentifier = @"CollectionViewAddPictureIdentifier";
static NSString * const kNJHPictureCollectionViewCellReuseIdentifier =    @"CollectionViewPictureIdentifier";

static NSString * const kNJHJPEGFileExtension =                           @"jpg";
static NSString * const kNJHFirstCellImageName =                          @"picture";

static NSString * const kNJHActionMenuCameraString =                      @"Camera";
static NSString * const kNJHActionMenuPhotoLibrarySting =                 @"Photo library";
static NSString * const kNJHActionMenuCancelString =                      @"Cancel";
static NSString * const kNJHActionMenuTitlePickImageString =              @"Pick image";

@implementation NJHImageCollectionViewController

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.issueManager.images.count + kNJHAddPictureCollectionViewCellOffset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kNJHAddPictureCollectionViewCellIndex) {
        return [self buildAddPictureCollectionViewCellForCollectionView:collectionView atIndexPath:indexPath];
    } else {
        return [self buildPictureCollectionViewCellForCollectionView:collectionView atIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)buildAddPictureCollectionViewCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    NJHImageCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:kNJHAddPictureCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    collectionViewCell.imageView.image = [UIImage imageNamed:kNJHFirstCellImageName inBundle:[NSBundle abe_bundleForLibrary] compatibleWithTraitCollection:nil];
    return collectionViewCell;
}

- (UICollectionViewCell *)buildPictureCollectionViewCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    NJHImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNJHPictureCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = self.issueManager.images[indexPath.row - kNJHAddPictureCollectionViewCellOffset];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(self.collectionView.frame) - 2 * kNJHCollectionViewVerticalSpace;
    return CGSizeMake(height * kNJH16x9AspectRatio, height);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kNJHAddPictureCollectionViewCellIndex) {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        QLPreviewController *previewController = [QLPreviewController new];
        previewController.dataSource = self;
        previewController.currentPreviewItemIndex = indexPath.row - kNJHAddPictureCollectionViewCellOffset;
        [self.navigationController presentViewController:previewController animated:YES completion:nil];
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.issueManager.localImageURLs.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.issueManager.localImageURLs[index];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.issueManager addImageToIssue:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setIssueManager:(ABEIssueManager *)issueManager {
    _issueManager = issueManager;
    
    __weak typeof(self) _self_weak = self;
    self.issueManager.completionBlock = ^{
        [NSThread abe_guaranteeBlockExecutionOnMainThread:^{
            __strong typeof(self) self = _self_weak;
            [self.collectionView reloadData];
        }];
    };
}

@end


