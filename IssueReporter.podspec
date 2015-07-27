Pod::Spec.new do |s|
  s.name             = "IssueReporter"
  s.version          = "0.1.12"
  s.summary          = "A short description of IssueReporter."
  s.description      = <<-DESC
                       An optional longer description of IssueReporter

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/IssueReporter"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hakon Hanesand" => "hakon@hanesand.no" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/IssueReporter.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.4'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'IssueReporter' => ['Pod/Assets/*.{png,strings}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.5'
end
