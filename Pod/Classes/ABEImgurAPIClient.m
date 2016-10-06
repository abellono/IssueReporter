//
//  ABEImgurAPIClient.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "ABEImgurAPIClient.h"
#import "ABEReporter.h"

@interface ABEImgurAPIClient ()

@property (nonatomic) NSMutableURLRequest *baseImageUploadRequest;

@end

@implementation ABEImgurAPIClient

+ (ABEImgurAPIClient *)sharedClient {
    
    static ABEImgurAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
        
    });
    
    return _sharedClient;
}

+ (BOOL)isAPIKeySet {
    return [self sharedClient].imgurAPIKey.length > 0;
}

- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *imageURL))success error:(void (^)(NSError *))errorHandler {
    
    if (![ABEImgurAPIClient isAPIKeySet]) {
        // TODO : Refactor out error
        
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Authentication required for Imgur",
                                   NSLocalizedRecoverySuggestionErrorKey : @"Did you set the imgur client key in your appdelegate using `setupWithRepositoryName:gitHubAccessToken:imgurClientID:`? If you do not have a key, go to https://api.imgur.com/oauth2/addclient and create one. This error has also been printed to the console."};
        
        errorHandler([NSError errorWithDomain:@"no.abello.IssueReporter" code:NSURLErrorUserAuthenticationRequired userInfo:userInfo]);
        return;
    }
    
    NSURLRequest *request = [self imageUploadRequestForImageData:imageData];
    
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error while uploading the picture with Imgur's API.");
            NSLog(@"Error : %@", error);
            errorHandler(error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if (error) {
            NSLog(@"There was an error parsing the returned data from Imgur's API.");
            NSLog(@"Error : %@", jsonError);
        }
        
        // TODO : Actually check for valid url returned by imgur api instead of blindly forwarding it
        success(jsonResponse[@"data"][@"link"]);
    }];
}

- (NSURLRequest *)imageUploadRequestForImageData:(NSData *)imageData {
    NSDictionary *parameters = @{
                                 @"image" : [imageData base64EncodedStringWithOptions:kNilOptions],
                                 @"type" : @"base64"
                                 };
    
    NSAssert([NSJSONSerialization isValidJSONObject:parameters], @"JSON Post body generated from issue is not valid JSON.");
    
    NSMutableURLRequest *baseRequest = [self baseImageUploadRequest];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"There was an error serializing the upload image request body.");
        NSLog(@"Error : %@", error);
    }
    
    [baseRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [baseRequest setHTTPBody:data];
    
    return baseRequest;
}

- (NSMutableURLRequest *)baseImageUploadRequest {
    if (!_baseImageUploadRequest) {
        NSURL *url = [NSURL URLWithString:@"https://api.imgur.com/3/upload"];
        _baseImageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        
        [_baseImageUploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_baseImageUploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [_baseImageUploadRequest setValue:[NSString stringWithFormat:@"Client-ID %@", self.imgurAPIKey] forHTTPHeaderField:@"Authorization"];
    }
    
    return _baseImageUploadRequest;
}

- (void)setImgurAPIKey:(NSString *)imgurAPIKey {
    _imgurAPIKey = [imgurAPIKey copy];
}

@end
