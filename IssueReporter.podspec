

Pod::Spec.new do |s|
    s.name         = "IssueReporter"
    s.version      = "2.0.0"
    s.summary      = "Shake your beta app to report issues to GitHub"
    s.description  = <<-DESC
                  Submit issues to github through your development app by shaking your phone! Beta testers can use this tool to report bugs to you while they are testing your app.
                   DESC

    s.homepage     = "https://github.com/abellono/IssueReporter"
    s.license          = 'MIT'

    s.source           = { :git => "https://github.com/abellono/IssueReporter.git", :tag => s.version.to_s }
    s.authors             = { "Hakon Hanesand" => "hakon@abello.no", "Nikolai Heum" => "nikolaiheum@gmail.com"}
    s.social_media_url   = "https://twitter.com/hhanesand"

    s.platform     = :ios, "8.0"

    s.requires_arc = true
    s.source_files = "IssueReporter/Classes/**/*"
    s.frameworks = "UIKit", "Foundation"

    s.resource_bundles = {
      'IssueReporterResources' => ['Pod/Assets/*.{png,strings,storyboard}']
    }
end
