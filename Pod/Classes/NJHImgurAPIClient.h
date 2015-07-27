//
//  NJHImgurAPIClient.h
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface NJHImgurAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

/**
 *  Uploads the an image to Imgur
 *
 *  @param imageData    The image data to upload
 *  @param successBlock The success block called with the URL of the picture if the operation was successful
 *  @param errorHandler The error block called with the error that occured, if any
 */
- (void)uploadImageData:(NSData *)imageData success:(void (^)(NSString *imageURL))successBlock error:(void (^)(NSError *))errorHandler;

/**
 *  Sets the API key to use with all requests to Imgur
 *
 *  @param key The imgur API key, which can be obtained by registering an application at http://api.imgur.com/oauth2/addclient . The checkbox
 *             labeled "Anonymous usage without user authorization" should be checked when you are making your application.
 */
- (void)setImgurAPIKey:(NSString *)key;

@end
