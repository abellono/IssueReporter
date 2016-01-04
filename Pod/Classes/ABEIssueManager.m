//
//  ABEIssueManager.m
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import "ABEIssueManager.h"

#import "NJHIssue.h"
#import "NJHGithubAPIClient.h"

#import "NJHImgurAPIClient.h"
#import "UIAlertController+ABEErrorAlertController.h"
#import "UIImage+NJH_AutoRotation.h"
#import "NSURL+NJH_RandomImageURL.h"

static double const kNJHCompressionRatio = 0.5;

@interface ABEIssueManager ()
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation ABEIssueManager

- (instancetype)initWithReferenceView:(UIView *)referenceView viewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        _imagesToUpload = [NSMutableArray new];
        _issue = [NJHIssue new];
        _viewController = viewController;
        
        [self p_processReferenceView:referenceView];
    }
    
    return self;
}

- (void)p_processReferenceView:(UIView *)referenceView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(referenceView.bounds.size, NO, 0);
        [referenceView drawViewHierarchyInRect:referenceView.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [self addImageToIssue:image];
    });
}

- (void)addImageToIssue:(UIImage *)image {
    UIImage *flippedImage = [image njh_rotateImageInPreparationForDataConversion];
    NSData *imageData = UIImageJPEGRepresentation(flippedImage, kNJHCompressionRatio);
    
    [self addImageDataToIssue:imageData];
}

- (void)addImageDataToIssue:(NSData *)imageData {
    [self willChangeValueForKey:@"imagesToUpload"];
    [self.imagesToUpload addObject:imageData];
    [self didChangeValueForKey:@"imagesToUpload"];
    
    NSURL *saveLocation = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] njh_URLByAddingRandomImagePathWithExtension:@"jpg"];
    [imageData writeToURL:saveLocation options:kNilOptions error:nil];
    
    [self.localImageURLs addObject:saveLocation];
    
    if (self.completionBlock) {
        self.completionBlock();
    }
    
    __weak typeof(self) weakSelf = self;
    [[NJHImgurAPIClient sharedClient] uploadImageData:imageData success:^(NSString *imageURL) {
        __strong typeof(self) self = weakSelf;
        [self p_didUploadImageWithData:imageData atURL:imageURL];
    } error:^(NSError *error) {
        __strong typeof(self) self = weakSelf;
        [self p_didFailImageUploadWithData:imageData error:error];
    }];
}

- (void)p_didUploadImageWithData:(NSData *)imageData atURL:(NSString *)url {
    NSAssert([self.imagesToUpload containsObject:imageData], @"Images to upload did not contain image that was uploaded.");
    
    [self willChangeValueForKey:@"imagesToUpload"];
    [self.imagesToUpload removeObject:imageData];
    [self didChangeValueForKey:@"imagesToUpload"];
    
    [self.issue attachImageAtURL:url];
}

- (void)p_didFailImageUploadWithData:(NSData *)imageData error:(NSError *)error {
    NSAssert([self.imagesToUpload containsObject:imageData], @"Images to upload did not contain image that just failed uploading.");
    
    [self willChangeValueForKey:@"imagesToUpload"];
    [self.imagesToUpload removeObject:imageData];
    [self didChangeValueForKey:@"imagesToUpload"];
    
    UIAlertController *alertController = [UIAlertController abe_alertControllerFromError:error];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addImageDataToIssue:imageData];
    }]];
    
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)saveIssueWithCompletion:(void (^)())completion {
    [[NJHGithubAPIClient sharedClient] saveIssue:self.issue success:^{
        completion();
    } error:^(NSError *error) {
        UIAlertController *alertController = [UIAlertController abe_alertControllerFromError:error];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveIssueWithCompletion:completion];
        }]];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }];

}

- (NSUInteger)numberOfCurrentlyUploadingImages {
    return self.imagesToUpload.count;
}

- (NSMutableArray *)imagesToUpload {
    return [self mutableArrayValueForKey:[NSString stringWithFormat:@"_%@", NSStringFromSelector(_cmd)]];
}

@end
