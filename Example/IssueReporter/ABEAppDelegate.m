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
    [ABEReporter setupWithRepositoryName:@"IssueReporter" owner:@"abellono" token:@"f8056e00b831dc758063e9a2360052ae693fe2de" imgurKey:@"11beab0d0337132"];
    
    return YES;
}

@end
