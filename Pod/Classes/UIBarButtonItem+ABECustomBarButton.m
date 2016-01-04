//
//  UIBarButtonItem+ABEBarButton.m
//  nettdating
//
//  Created by Nikolai Johan Heum on 24.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "UIBarButtonItem+ABECustomBarButton.h"

#import "NSBundle+ABEBundle.h"


static NSString * const kABECloseButtonImage = @"close";
static NSString * const kABESaveButtonImage = @"save";

@implementation UIBarButtonItem (ABECustomBarButton)

+ (instancetype)njh_backButtonWithTarget:(id)target andColor:(UIColor *)color action:(SEL)action {
    NSBundle *cocoapodsBundle = [NSBundle abe_bundleForLibrary];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kABECloseButtonImage inBundle:cocoapodsBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:target action:action];
    button.tintColor = color;
    
    return button;
}

+ (instancetype)njh_saveButtonWithTarget:(id)target action:(SEL)action {
    NSBundle *cocoapodsBundle = [NSBundle abe_bundleForLibrary];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kABESaveButtonImage inBundle:cocoapodsBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:target action:action];
    button.imageInsets = UIEdgeInsetsMake(3, -6, 0, 0);
    button.tintColor = [UIColor whiteColor];
    
    return button;
}

@end
