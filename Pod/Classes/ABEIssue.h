//
//  ABEIssue.h
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import Foundation;

@interface ABEIssue : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *issueDescription;

// Computed property from description and images
@property (nonatomic, readonly) NSString *body;

- (void)attachImageAtURL:(NSString *)url;

- (NSDictionary *)toDictionary;

@end
