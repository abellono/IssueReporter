//
//  ABEBundle+NSBundle.m
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import "NSBundle+ABEBundle.h"

#import "NJHReporter.h"

@implementation NSBundle (ABEBundle)

+ (NSBundle *)abe_bundleForLibrary {
    return [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/IssueReporterResources.bundle", [NSBundle bundleForClass:[[NJHReporter reporter] class]].bundlePath]];
}

@end
