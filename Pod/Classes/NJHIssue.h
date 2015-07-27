//
//  NJHIssue.h
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import Foundation;

@interface NJHIssue : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *assignee;
@property (nonatomic, copy) NSArray *labels;

@property (nonatomic) NSNumber *identifier;
@property (nonatomic) NSURL *URL;

@end
