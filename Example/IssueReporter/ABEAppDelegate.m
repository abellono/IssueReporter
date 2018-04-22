//
//  ABEAppDelegate.m
//  IssueReporter
//
//  Created by Hakon Hanesand on 07/27/2015.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.
//

#import "ABEAppDelegate.h"

@import IssueReporter;

@interface ABEAppDelegate () <IssueReporterDelegate>
@end

@implementation ABEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Reporter setupWithRepositoryName:@"pure-ios-issues" owner:@"abellono" githubToken:@"4d08a844a452ebc894664b33c00609c2af32f890" imgurClientId:@"shorter_imgur_client_id"];

    [Reporter setWithFileRepository:@"pure-ios-issues" owner:@"abellono"];
    
    // Set the delegate to provide extra debug information.
    // Reporter.delegate =

    Reporter.delegate = self;

    return YES;
}

#pragma mark - IssueReporterDelegate

- (BOOL)shouldAskForTesterName {
    return YES;
}

- (NSDictionary<NSString *,NSData *> * _Nonnull)debugFilesForIssueReporter {
    // Files are uploaded to a the specified repository.
    return @{[NSUUID UUID].UUIDString : [NSJSONSerialization dataWithJSONObject:@{@"json" : @"object"} options:0 error:nil]};
}

- (void)debugFilesForIssueReporterWithCompletion:(void (^)(NSDictionary<NSString *, NSData *> *))completion {
    // Load some data from disk, and call the completion handler with the name of the file and the data.
    completion(@{[NSUUID UUID].UUIDString : [NSJSONSerialization dataWithJSONObject:@{@"json" : @"object"} options:0 error:nil]});
}

- (NSDictionary<NSString *,NSString *> *)debugInformationForIssueReporter {
    // Return extra debugging flags from the device, displayed in a table.
    return @{};
}

- (void)didDismissIssueReporterWith:(BOOL)success {

}


@end
