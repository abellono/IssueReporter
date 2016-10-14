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
    
    NSURLRequest *saveIssueRequest = [self saveIssueRequestForIssue:issue errorHandler:errorHandler];
    
    if (!saveIssueRequest) {
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithRequest:saveIssueRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error while saving the issue with Github's API.");
            NSLog(@"Error : %@", error);
            
            if (errorHandler) {
                errorHandler(error);
            }
            
            return;
        }
        
        if (success) {
            success();
        }
        
    }] resume];
}

- (NSURLRequest *)saveIssueRequestForIssue:(ABEIssue *)issue errorHandler:(void (^)(NSError *error))errorHandler {
    NSMutableURLRequest *baseIssueSaveRequest = [[self baseSaveIssueURLRequest] mutableCopy];
    NSAssert([NSJSONSerialization isValidJSONObject:[issue toDictionary]], @"JSON Post body generated from issue is not valid JSON.");
    
    NSError *error = nil;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:[issue toDictionary] options:0 error:&error];
    
    if (error) {
        NSLog(@"There was an error saving the issue to github.");
        NSLog(@"Error : %@", error);
        
        if (errorHandler) {
            errorHandler(error);
        }
        
        return nil;
    }
    
    [baseIssueSaveRequest setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[jsonObject length]] forHTTPHeaderField:@"Content-Length"];
    [baseIssueSaveRequest setHTTPBody:jsonObject];
    
    return baseIssueSaveRequest;
}

- (NSMutableURLRequest *)baseSaveIssueURLRequest {
    if (!_baseSaveIssueURLRequest) {
        NSString *path = [NSString stringWithFormat:@"https://api.github.com/repos/%@/issues?access_token=%@", self.repositoryName, self.githubToken];
        NSURL *url = [NSURL URLWithString:path];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:[NSString stringWithFormat:@"token %@", self.githubToken] forHTTPHeaderField:@"Authorization"];
        
        return request;
    }
    
    return _baseSaveIssueURLRequest;
}

- (void)setGithubAPIKey:(NSString *)string {
    self.githubToken = string;
}

@end
