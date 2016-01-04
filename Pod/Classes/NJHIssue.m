//
//  NJHIssue.m
//  IssueReporter
//
//  Created by Nikolai Johan Heum on 04.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

#import "NJHIssue.h"

#import "NJHReporter.h"

@import Foundation;

@interface NJHIssue ()
@property (nonatomic) NSMutableArray *imageURLs;
@end

@implementation NJHIssue

- (NSDictionary *)toDictionary {
    return @{NSStringFromSelector(@selector(title)) : self.title,
             NSStringFromSelector(@selector(body)) : self.body};
}

- (void)attachImageAtURL:(NSString *)url {
    [self.imageURLs addObject:url];
}

- (NSString *)body {
    NSString *base = [NSString stringWithFormat:@"%@ \n\n %@ \n", self.issueDescription, [[NJHReporter reporter] extraInfoForIssue]];
    
    for (NSString *url in self.imageURLs) {
        base = [base stringByAppendingString:[NSString stringWithFormat:@"![image](%@)\n", url]];
    }
    
    return base;
}

- (NSMutableArray *)imageURLs {
    if (!_imageURLs) {
        _imageURLs = [NSMutableArray new];
    }
    
    return _imageURLs;
}

@end
