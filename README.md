# IssueReporter

[![CI Status](http://img.shields.io/travis/Hakon Hanesand/IssueReporter.svg?style=flat)](https://travis-ci.org/Hakon Hanesand/IssueReporter)
[![Version](https://img.shields.io/cocoapods/v/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)
[![License](https://img.shields.io/cocoapods/l/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)
[![Platform](https://img.shields.io/cocoapods/p/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)

## Usage

To run the example project, simply clone this gihub respoitory and run the `IssueReporter-Example` target in the Xcode project located at `Example/IsssueReporter.xcodeproj`.

## Installation

IssueReporter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "IssueReporter"
```

## Requirements

### Github API Token

In order for this library to have access to your github repository, you need to provide a github api token with the correct permissions.

First, navigate to [the personal access token generation page][https://github.com/settings/tokens/new] and enter a name for the token.

If you are using a private repository, you need to select the `repo` scope

![private scope](http://i.imgur.com/2wFa3Ho.png)

and if you are using a public repository, select the `public_repo` scope.

![public scope](http://i.imgur.com/GB6dxiS.png)

### Imgur API token

This step is optional, but necessary if you want to include screenshots and images in the submitted issues. Creating a Imgur API key allows the library to automatically include images in the uploaded Github Issues.

First, navigate to the the [imgur application creation page](https://imgur.com/account/settings/apps). If you do not have an account, you will need to create one.

Give your application a name, anything works.

Select the `Anonymous usage without user authorization` radio button.

Enter any valid URL for the `Authorization callback URL`, such as `www.example.com`.

Enter your email, and a short description for the app.

Once you've created the application, copy the `Client ID`, as that is what the library needs to upload pictures.

## Setup

Once you've gotten the necessary tokens, navigate to your app delegate, and add the following line :

```objc
[ABEReporter setupWithRepositoryName:@"user/repo" gitHubAccessToken:@"long_github_token_here" imgurClientID:@"shorter_imgur_client_id"];
```

## Authors

Hakon Hanesand, hakon@abello.no

Nikolai Heum, heum@abello.no


## License

IssueReporter is available under the MIT license. See the LICENSE file for more info.
