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

    [ABEReporter setupWithRepositoryName:@"IssueReporter" owner:@"abellono" token:@"long_github_token_here" imgurKey:@"shorter_imgur_client_id"];
    
    return YES;
}

@end
