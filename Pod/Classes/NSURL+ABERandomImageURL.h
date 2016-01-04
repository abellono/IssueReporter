//
//  NSURL+RandomImageURL.h
//  IssueReporter
//
//  Created by Hakon Hanesand on 7/24/15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import Foundation;

@interface NSURL (ABERandomImageURL)

- (NSURL *)njh_URLByAddingRandomImagePathWithExtension:(NSString *)string;

@end
