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

// Helpers
#import "NJHReporter.h"

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

static double const kNJHCompressionRatio = 0.7;

static NSString * const kNJHAddPictureCollectionViewCellReuseIdentifier = @"CollectionViewAddPictureIdentifier";
static NSString * const kNJHPictureCollectionViewCellReuseIdentifier =    @"CollectionViewPictureIdentifier";

/**
 *  This is the name of the resource bundle that is specified in our podspec. It is a bundle countained in our framework bundle, meaning that if we want to get to it,
 *  we have to first get the current bundle with bundleForClass, and then move to this sub bundle
 */
static NSString * const kNJHResourceBundleName =                          @"/IssueReporter.bundle";
static NSString * const kNJHJPEGFileExtension =                           @"jpg";
static NSString * const kNJHFirstCellImageName =                          @"picture";

static NSString * const kNJHActionMenuCameraString =                      @"Camera";
static NSString * const kNJHActionMenuPhotoLibrarySting =                 @"Photo library";
static NSString * const kNJHActionMenuCancelString =                      @"Cancel";
static NSString * const kNJHActionMenuTitlePickImageString =              @"Pick image";

@interface NJHImageCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSMutableArray<NSURL *> *localImageURLs;
@property (nonatomic) NSMutableArray<UIImage *> *images;

@end

@implementation NJHImageCollectionViewController

#pragma mark UICollectionViewDataSource

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _images = [NSMutableArray new];
        _localImageURLs = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count] + kNJHAddPictureCollectionViewCellOffset;
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
    
    // Get the correct bundle from our directory
    NSBundle *cocoapodsBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[NJHReporter class]].bundlePath stringByAppendingString:kNJHResourceBundleName]];
    UIImage *image = [UIImage imageNamed:kNJHFirstCellImageName inBundle:cocoapodsBundle compatibleWithTraitCollection:nil];
    
    collectionViewCell.imageView.image = image;
    
    return collectionViewCell;
}

- (UICollectionViewCell *)buildPictureCollectionViewCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    NJHImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[kNJHPictureCollectionViewCellReuseIdentifier stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)indexPath.row]] forIndexPath:indexPath];
    cell.imageView.image = self.images[indexPath.row - kNJHAddPictureCollectionViewCellOffset];
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
        [self presentImagePickerActionMenu];
    } else {
        QLPreviewController *previewController = [QLPreviewController new];
        previewController.dataSource = self;
        previewController.currentPreviewItemIndex = indexPath.row - kNJHAddPictureCollectionViewCellOffset;
        [self.navigationController presentViewController:previewController animated:YES completion:nil];
    }
}

- (void)presentImagePickerActionMenu {
    __weak typeof(self) weakSelf = self;
    void (^imagePickerPresenter)(UIImagePickerControllerSourceType sourceType) = ^void(UIImagePickerControllerSourceType sourceType) {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = sourceType;
        picker.delegate = weakSelf;
        [weakSelf presentViewController:picker animated:YES completion:nil];
    };
    
    UIAlertAction *imageFromCameraAction = [UIAlertAction actionWithTitle:kNJHActionMenuCameraString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePickerPresenter(UIImagePickerControllerSourceTypeCamera);
    }];
    
    UIAlertAction *imageFromCameraRoll = [UIAlertAction actionWithTitle:kNJHActionMenuPhotoLibrarySting style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePickerPresenter(UIImagePickerControllerSourceTypePhotoLibrary);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:kNJHActionMenuCancelString style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kNJHActionMenuTitlePickImageString message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:imageFromCameraAction];
    [alertController addAction:imageFromCameraRoll];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.localImageURLs count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.localImageURLs[index];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self didPickImage:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Handling

- (void)didPickImage:(UIImage *)image {
    [self.images addObject:image];
    
    UIImage *flippedImage = [image njh_rotateImageInPreparationForDataConversion];
    NSData *imageData = UIImageJPEGRepresentation(flippedImage, kNJHCompressionRatio);
    
    [self.imageDelegate userDidPickImageData:imageData];
    [self saveImageData:imageData];
    
    [self.collectionView reloadData];
}

- (void)saveImageData:(NSData *)imageData {
    NSURL *saveLocation = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] njh_URLByAddingRandomImagePathWithExtension:kNJHJPEGFileExtension];
    [imageData writeToURL:saveLocation options:kNilOptions error:nil];
    
    [self.localImageURLs addObject:saveLocation];
}

@end
