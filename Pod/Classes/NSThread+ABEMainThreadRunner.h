//
//  NSThread+ABEMainThreadRunner.h
//  Roomservice
//
//  Created by Hakon Hanesand on 11/7/15.
//  Copyright © 2015 Abello. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (ABEMainThreadRunner)

+ (void)abe_guaranteeBlockExecutionOnMainThread:(nonnull void (^)())block;

@end

NS_ASSUME_NONNULL_END