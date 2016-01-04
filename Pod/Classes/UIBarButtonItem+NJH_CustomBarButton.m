//
//  UIBarButtonItem+NJHBarButton.m
//  nettdating
//
//  Created by Nikolai Johan Heum on 24.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "UIBarButtonItem+NJH_CustomBarButton.h"

#import "NSBundle+ABEBundle.h"


static NSString * const kNJHCloseButtonImage = @"close";
static NSString * const kNJHSaveButtonImage = @"save";

@implementation UIBarButtonItem (NJH_CustomBarButton)

+ (instancetype)njh_backButtonWithTarget:(id)target andColor:(UIColor *)color action:(SEL)action {
    NSBundle *cocoapodsBundle = [NSBundle abe_bundleForLibrary];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kNJHCloseButtonImage inBundle:cocoapodsBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:target action:action];
    button.tintColor = color;
    
    return button;
}

+ (instancetype)njh_saveButtonWithTarget:(id)target action:(SEL)action {
    NSBundle *cocoapodsBundle = [NSBundle abe_bundleForLibrary];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kNJHSaveButtonImage inBundle:cocoapodsBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:target action:action];
    button.imageInsets = UIEdgeInsetsMake(3, -6, 0, 0);
    button.tintColor = [UIColor whiteColor];
    
    return button;
}

@end
