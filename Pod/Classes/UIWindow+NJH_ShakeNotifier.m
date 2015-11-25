//
//  UIWindow+NJHShakeNotifier.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 16.03.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "UIWindow+NJH_ShakeNotifier.h"

@import Foundation;
@import UIKit;
@import ObjectiveC;

NSString * const kNJHSHakeNotificationName = @"CONJUShakeNotification";

@implementation UIWindow (NJH_ShakeNotifier)

#pragma mark - Listen for shake

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        Method originalMethod = class_getInstanceMethod(class, @selector(motionEnded:withEvent:));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(njh_motionEnded:withEvent:));
        
        // Since we know both methods exist (we are implementing them) we can simply exchange their implementations
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)njh_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // Will not create an infinite loop, as this will call the `original` implementation
    if ([UIWindow instancesRespondToSelector:@selector(njh_motionEnded:withEvent:)]) {
        [self njh_motionEnded:motion withEvent:event];
    }

    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNJHSHakeNotificationName object:nil]];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // We need to implement this so we can call it from our swizzled implementation
    // Had we not done this, further subclasses of UIWindow would no longer recieve this method
}

@end
