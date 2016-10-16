//
//  ABEAppDelegate.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import "ABEAppDelegate.h"

@import IssueReporter;

@implementation ABEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ABEReporter setupWithRepositoryName:@"IssueReporter" owner:@"abellono" token:@"4639d2e12ef6233b5e709779bf581887263fbee3" imgurKey:@"e148ae37bac7efe"];
    
    return YES;
}

@end
