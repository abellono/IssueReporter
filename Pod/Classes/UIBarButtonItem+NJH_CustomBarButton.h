//
//  UIBarButtonItem+NJHBarButton.h
//  nettdating
//
//  Created by Nikolai Johan Heum on 24.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import UIKit;

@interface UIBarButtonItem (NJH_CustomBarButton)

// A button item with a X button as image
+ (instancetype)njh_backButtonWithTarget:(id)target andColor:(UIColor *)color action:(SEL)action;

// A button with a check image
+ (instancetype)njh_saveButtonWithTarget:(id)target action:(SEL)action;

@end
