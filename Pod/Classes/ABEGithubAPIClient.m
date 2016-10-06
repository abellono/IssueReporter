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
@property (nonatomic) NSMutableURLRequest *baseSaveIssueURLRequest;

@end

@implementation ABEGithubAPIClient

+ (instancetype)sharedClient {
    
    static ABEGithubAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

// TODO : JSON Response serializing

- (void)saveIssue:(ABEIssue *)issue success:(void (^)())success error:(void (^)(NSError *error))errorHandler {
    
    NSURLRequest *saveIssueRequest = [self saveIssueRequestForIssue:issue];

    // TODO : Send request to github somehow, maybe a central manager is smart?
    // Maybe copy lightly copy AFNetworking structure with a central manager
    
    
//    [self POST:path parameters:[issue toDictionary] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (success) {
//            success();
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (errorHandler) {
//            errorHandler(error);
//        }
//    }];
}

- (NSURLRequest *)saveIssueRequestForIssue:(ABEIssue *)issue {
    NSMutableURLRequest *baseIssueSaveRequest = [[self baseSaveIssueURLRequest] mutableCopy];
    NSAssert([NSJSONSerialization isValidJSONObject:[issue toDictionary]], @"JSON Post body generated from issue is not valid JSON.");
    
    NSError *error = nil;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:[issue toDictionary] options:0 error:&error];
    
    if (error) {
        NSLog(@"There was an error saving the issue to github.");
        NSLog(@"Error : %@", error);
    }
    
    [baseIssueSaveRequest setValue:[NSString stringWithFormat:@"%d", [jsonObject length]] forHTTPHeaderField:@"Content-Length"];
    [baseIssueSaveRequest setHTTPBody:jsonObject];
    
    return baseIssueSaveRequest;
}

- (NSMutableURLRequest *)baseSaveIssueURLRequest {
    if (!_baseSaveIssueURLRequest) {
        NSString *path = [NSString stringWithFormat:@"repos/%@/issues?access_token=%@", self.repositoryName, self.githubToken];
        NSURL *url = [NSURL URLWithString:path];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // TODO : Does this need base64 encoding?
        [request setValue:[NSString stringWithFormat:@"token %@", self.githubToken] forHTTPHeaderField:@"Authorization"];
        
        return request;
    }
    
    return _baseSaveIssueURLRequest;
}

- (void)setGithubAPIKey:(NSString *)string {
    self.githubToken = string;
}

@end
