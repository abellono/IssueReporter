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

    [Reporter setupWithRepositoryName:@"IssueReporter" owner:@"abellono" githubToken:@"long_github_token_here" imgurClientId:@"shorter_imgur_client_id"];
    
    // Set the delegate to provide extra debug information.
    // Reporter.delegate =
    
    return YES;
}

@end
