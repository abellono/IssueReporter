//
//  ABEAppDelegate.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import <IssueReporter/ABEReporter.h>

#import "ABEAppDelegate.h"

@implementation ABEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ABEReporter setupWithRepositoryName:@"abellono/IssueReporter" gitHubAccessToken:@"fd93485f83a2d7c5e9834d5559d8535fa7af1f3f" imgurClientID:@"11beab0d0337132"];
    
    return YES;
}

@end
