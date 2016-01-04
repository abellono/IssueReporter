//
//  UIAlertController+ABEErrorAlertController.h
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ABEErrorAlertController)

+ (instancetype)abe_alertControllerFromError:(NSError *)error;

@end
