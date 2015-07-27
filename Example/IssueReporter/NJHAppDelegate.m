//
//  NJHAppDelegate.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import <IssueReporter/NJHReporter.h>

#import "NJHAppDelegate.h"

@implementation NJHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NJHReporter setupWithRepositoryName:@"user/repo" gitHubAccessToken:@"long_github_token_here" imgurClientID:@"shorter_imgur_client_id"];
    
    return YES;
}

@end
