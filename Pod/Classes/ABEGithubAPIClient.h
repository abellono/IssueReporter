//
//  ABEGitHubIssueAPIClient.h
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@class ABEIssue;

@interface ABEGithubAPIClient : NSObject

+ (instancetype)sharedClient;

/**
 *  The name of the repository we are creating issues in. In the format "user/repository"
 */
@property (nonatomic) NSString *repositoryName;

/**
 *  Saves an issue to the target GitHub repository
 *
 *  @param issue The issue to save
 */
- (void)saveIssue:(ABEIssue *)issue success:(void (^)())success error:(void (^)(NSError *error))errorHandler;

/**
 *  Sets the API key to use with all Github API requests. Generate a new key by going to https://github.com/settings/tokens and clicking generate new token. If you are planning to
 *  create issues in a private repository, then take care to select the "Private Repository" permission checkbox
 *
 *  @param key The API key (aka token)
 */
- (void)setGithubAPIKey:(NSString *)string;

@end
