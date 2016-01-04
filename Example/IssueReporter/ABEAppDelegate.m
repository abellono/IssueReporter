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
    [ABEReporter setupWithRepositoryName:@"user/repo" gitHubAccessToken:@"long_github_token_here" imgurClientID:@"shorter_imgur_client_id"];
    
    return YES;
}

@end
