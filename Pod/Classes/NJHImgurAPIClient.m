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

+ (NJHImgurAPIClient *)sharedClient {
    
    static NJHImgurAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *URL = [NSURL URLWithString:kNJHBaseAPIURL];
        _sharedClient = [[self alloc] initWithBaseURL:URL];
        
    });
    
    return _sharedClient;
}

+ (BOOL)isAPIKeySet {
    return [self sharedClient].imgurAPIKey.length > 0;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *imageURL))success error:(void (^)(NSError *))errorHandler {
    
    if (![NJHImgurAPIClient isAPIKeySet]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Authentication required for Imgur",
                                   NSLocalizedRecoverySuggestionErrorKey : @"Did you set the imgur client key in your appdelegate using `setupWithRepositoryName:gitHubAccessToken:imgurClientID:`? If you do not have a key, go to https://api.imgur.com/oauth2/addclient and create one. This error has also been printed to the console."};
        
        errorHandler([NSError errorWithDomain:@"no.abello.IssueReporter" code:NSURLErrorUserAuthenticationRequired userInfo:userInfo]);
        return;
    }

    NSMutableDictionary *parameters = @{}.mutableCopy;
    
    parameters[@"image"] = [imageData base64EncodedStringWithOptions:kNilOptions];
    parameters[@"type"] = @"base64";
    
    [self POST:@"upload" parameters:parameters.copy progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject[@"data"][@"link"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)setImgurAPIKey:(NSString *)imgurAPIKey {
    _imgurAPIKey = [imgurAPIKey copy];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Client-ID %@", imgurAPIKey] forHTTPHeaderField:@"Authorization"];
}

@end
