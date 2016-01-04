//
//  NJHReporter.h
//  nettdating
//
//  Created by Nikolai Johan Heum on 24.05.15.
//  Copyright (c) 2015 Abello. All rights reserved.
//

@import UIKit;

@protocol NJHReporterInformationDelegate <NSObject>

/**
 *  Called when the user shakes the phone to make an issue to ask for more information to send with the issue (must be string values)
 *
 *  By default, the following information is sent
 *      -   App version (CFBundleShortVersionString)
 *      -   Bundle version (CFBundleVersion)
 *      -   Current localization
 *      -   Device
 *      -   iOS Version
 *
 * @return Extra information that you wish to include in the issue, in the form of @{String, String}
 */
- (NSDictionary *)extraDebuggingInformationForIssue;

@end

@interface NJHReporter : NSObject <UINavigationControllerDelegate>

/**
 *  @return The shared instance for this class
 */
+ (instancetype)reporter;

/**
 *  Configures the reporter with a github repository
 *
 *  @param reponame          The repository name, should be in the format of 'user/repositoryName'
 *  @param githubAccessToken The access token to the user's account, generated on the settings page
 */
+ (void)setupWithRepositoryName:(NSString *)reponame gitHubAccessToken:(NSString *)githubAccessToken;

/**
 *  Configures the reporter with a github repository and an imgur image hosting application
 *
 *  @param reponame          The repository name, should be in the format of 'user/repositoryName'
 *  @param githubAccessToken The github access token to the user's account, generated on the settings page
 *  @param imgurAccessToken  The imgur access token for the user generated imgur application
 */
+ (void)setupWithRepositoryName:(NSString *)reponame gitHubAccessToken:(NSString *)githubAccessToken imgurClientID:(NSString *)imgurAccessToken;

/**
 *  Whether or not the shake to report functionality is enabled, set to NO to prevent the issue reporting view to appear after
 *  the user shakes the device. The default value is YES.
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 *  The object to ask for extra information when the user shakes the device, see the comment in the protocol above to see what is already sent
 */
@property (nonatomic) id <NJHReporterInformationDelegate> delegate;

/**
 *  Returns the extra key value pair to append to the issues that are sent to Github to aid in debugging
 */
- (NSDictionary *)extraInfoForIssue;

@end
