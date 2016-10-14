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
    [ABEReporter setupWithRepositoryName:@"IssueReporter" owner:@"abellono" token:@"YOUR GITHUB TOKEN" imgurKey:@"YOUR IMGUR KEY"];
    
    return YES;
}

@end
