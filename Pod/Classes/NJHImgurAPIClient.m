//
//  NJHImgurAPIClient.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "NJHImgurAPIClient.h"
#import "NJHReporter.h"

static NSString * const kNJHBaseAPIURL = @"https://api.imgur.com/3/";

@implementation NJHImgurAPIClient

+ (instancetype)sharedClient {
    
    static NJHImgurAPIClient *_sharedClient = nil;
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

- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *imageURL))success error:(void (^)(NSError *))errorHandler {

    NSMutableDictionary *parameters = @{}.mutableCopy;
    
    parameters[@"image"] = [imageData base64EncodedStringWithOptions:kNilOptions];
    parameters[@"type"] = @"base64";
    
    [self POST:@"upload" parameters:parameters.copy success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(responseObject[@"data"][@"link"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)setImgurAPIKey:(NSString *)imgurAPIKey {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@", imgurAPIKey] forHTTPHeaderField:@"Authorization"];
}

@end
