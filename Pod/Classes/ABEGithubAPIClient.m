//
//  ABEGitHubIssueAPIClient.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "ABEGithubAPIClient.h"

#import "ABEIssue.h"
#import "ABEReporter.h"

static NSString * const kABEBaseAPIURL = @"https://api.github.com/";

@interface ABEGithubAPIClient ()

@property (nonatomic) NSString *githubToken;

@end

@implementation ABEGithubAPIClient

+ (instancetype)sharedClient {
    
    static ABEGithubAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *URL = [NSURL URLWithString:kABEBaseAPIURL];
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

- (void)saveIssue:(ABEIssue *)issue success:(void (^)())success error:(void (^)(NSError *error))errorHandler {
    
    NSMutableString *path1 = @"repos".mutableCopy;
    [path1 appendFormat:@"/%@", self.repositoryName];
    [path1 appendFormat:@"/issues?access_token=%@", self.githubToken];
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/issues?access_token=%@", self.repositoryName, self.githubToken];
    
    NSAssert([path isEqualToString:path1], @"ops");

    [self POST:path parameters:[issue toDictionary] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success();
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
