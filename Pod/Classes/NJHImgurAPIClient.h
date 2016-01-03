//
//  NJHImgurAPIClient.h
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface NJHImgurAPIClient : AFHTTPSessionManager

+ (NJHImgurAPIClient *)sharedClient;

+ (BOOL)isAPIKeySet;

/**
 *  Uploads the an image to Imgur
 *
 *  @param imageData    The image data to upload
 *  @param successBlock The success block called with the URL of the picture if the operation was successful
 *  @param errorHandler The error block called with the error that occured, if any
 */
- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *imageURL))successBlock error:(void (^)(NSError *))errorHandler;

/**
 *  The imgur API key, which can be obtained by registering an application at https://api.imgur.com/oauth2/addclient . The checkbox
 *  labeled "Anonymous usage without user authorization" should be checked and the "Authorization callback URL" does not matter, but needs
 *  to be filled in with a domain name. (example.com works)
 */
@property (nonatomic, copy) NSString *imgurAPIKey;

@end
