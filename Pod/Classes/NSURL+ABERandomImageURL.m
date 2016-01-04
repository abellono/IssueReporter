//
//  NSURL+RandomImageURL.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 7/24/15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "NSURL+ABERandomImageURL.h"

@implementation NSURL (ABERandomImageURL)

- (NSURL *)njh_URLByAddingRandomImagePathWithExtension:(NSString *)string {
    return [self URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [NSUUID UUID].UUIDString, string]];
}

@end
