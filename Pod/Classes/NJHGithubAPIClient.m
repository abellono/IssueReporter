//
//  NJHGitHubIssueAPIClient.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

// Helpers
#import "NJHGithubAPIClient.h"
#import "NJHIssue.h"
#import "NJHReporter.h"

static NSString * const kNJHBaseAPIURL = @"https://api.github.com/";

@interface NJHGithubAPIClient ()

@property (nonatomic) NSString *githubToken;

@end

@implementation NJHGithubAPIClient

+ (instancetype)sharedClient {
    
    static NJHGithubAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *URL = [NSURL URLWithString:kNJHBaseAPIURL];
        _sharedClient = [[self alloc] initWithBaseURL:URL];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
         self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)saveIssue:(NJHIssue *)issue success:(void (^)(BOOL finished))success error:(void (^)(NSError *error))errorHandler {
    
    NSMutableString *path = @"repos".mutableCopy;
    [path appendFormat:@"/%@", self.repositoryName];
    [path appendFormat:@"/issues?access_token=%@", self.githubToken];
    
    NSMutableDictionary *parameters = @{}.mutableCopy;
    
    if (issue.title) {
        parameters[@"title"] = issue.title;
    }
    
    if (issue.body) {
        parameters[@"body"] = issue.body;
    }
    
    if (issue.assignee) {
        parameters[@"assignee"] = issue.assignee;
    }
    
    if (issue.labels) {
        parameters[@"labels"] = issue.labels;
    }
    
    [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(YES);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)setGithubAPIKey:(NSString *)string {
    self.githubToken = string;
    [self.requestSerializer setValue:[NSString stringWithFormat:@"token %@", string] forHTTPHeaderField:@"Authorization"];
}

@end
