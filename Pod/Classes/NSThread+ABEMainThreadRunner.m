//
//  NSThread+ABEMainThreadRunner.m
//  Roomservice
//
//  Created by Hakon Hanesand on 11/7/15.
//  Copyright © 2015 Abello. All rights reserved.
//

#import "NSThread+ABEMainThreadRunner.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSThread (ABEMainThreadRunner)

+ (void)abe_guaranteeBlockExecutionOnMainThread:(void (^)())block {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    } else {
        block();
    }
}

@end

NS_ASSUME_NONNULL_END