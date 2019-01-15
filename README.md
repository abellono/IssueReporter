# IssueReporter

[![Version](https://img.shields.io/cocoapods/v/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)
[![License](https://img.shields.io/cocoapods/l/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)
[![Platform](https://img.shields.io/cocoapods/p/IssueReporter.svg?style=flat)](http://cocoapods.org/pods/IssueReporter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

IssueReporter is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod "IssueReporter"
```

You may run into issues with swift versions. Use the following code to apply the correct Swift version :

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|  
            if target.name == "IssueReporter"
                config.build_settings['SWIFT_VERSION'] = "4.2"
            end
        end
    end
end
```

## Author

Hakon Hanesand, hakon@abello.no
Nikolai Heum, heum@abello.no

## License

IssueReporter is available under the MIT license. See the LICENSE file for more info.
