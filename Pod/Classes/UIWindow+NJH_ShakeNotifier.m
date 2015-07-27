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
    Method original = class_getInstanceMethod([self class], @selector(motionEnded:withEvent:));
    Method dhcPrefixed = class_getInstanceMethod([self class],@selector(NJH_motionEnded:withEvent:));
    
    method_exchangeImplementations(original, dhcPrefixed);
}

- (void)NJH_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNJHSHakeNotificationName object:nil]];
    }
    
    if ([UIWindow instancesRespondToSelector:@selector(NJH_motionEnded:withEvent:)]) {
        [self NJH_motionEnded:motion withEvent:event];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // Needed (?)
}

@end
