//
//  ABEIssueManager.h
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import <Foundation/Foundation.h>

@class NJHIssue;

@interface ABEIssueManager : NSObject

- (instancetype)initWithReferenceView:(UIView *)referenceView viewController:(UIViewController *)viewController;

@property (nonatomic) NJHIssue *issue;

// Called when the manager finishes saving an image to disk
@property (nonatomic, copy) void (^completionBlock)();

@property (nonatomic) NSMutableArray<NSData *> *imagesToUpload; // kvo compliant
@property (nonatomic) NSMutableArray<NSURL *> *localImageURLs;
@property (nonatomic) NSMutableArray<UIImage *> *images;

- (void)addImageToIssue:(UIImage *)image;

- (void)saveIssueWithCompletion:(void (^)())completion;

@end
