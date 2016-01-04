//
//  UIAlertController+ABEErrorAlertController.m
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import "UIAlertController+ABEErrorAlertController.h"

@implementation UIAlertController (ABEErrorAlertController)

+ (instancetype)abe_alertControllerFromError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    return alert;
}

@end
