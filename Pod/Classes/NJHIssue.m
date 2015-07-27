//
//  NJHIssue.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "NJHIssue.h"

@import Foundation;

@implementation NJHIssue

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title"      : @"title",
             @"body"       : @"body",
             @"assignee"   : @"assignee",
             @"labels"     : @"labels",
             @"identifier" : @"number",
             @"URL"        : @"html_url"};
}

@end
