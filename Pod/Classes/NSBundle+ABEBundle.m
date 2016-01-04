//
//  ABEBundle+NSBundle.m
//  Pods
//
//  Created by Hakon Hanesand on 1/3/16.
//
//

#import "NSBundle+ABEBundle.h"

#import "ABEReporter.h"

/**
 *  This is the name of the resource bundle that is specified in our podspec. It is a bundle countained in our framework bundle, meaning that if we want to get to it,
 *  we have to first get the current bundle with bundleForClass, and then move to this sub bundle
 */
static NSString * const kABEResourceBundleName = @"IssueReporterResources.bundle";

@implementation NSBundle (ABEBundle)

+ (NSBundle *)abe_bundleForLibrary {
    return [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [NSBundle bundleForClass:[[ABEReporter reporter] class]].bundlePath, kABEResourceBundleName]];
}

@end
