Pod::Spec.new do |s|
  s.name             = "IssueReporter"
  s.version          = "2.0.2"
      s.summary      = "Shake your beta app to report issues to GitHub!"
  s.description      = <<-DESC
                      Submit issues to github through your development app by shaking your phone! Beta testers can use this tool to report bugs to you while they are testing your app.
                       DESC
  s.homepage         = "https://github.com/abellono/IssueReporter"
  s.license          = 'MIT'
  s.author           = { "Hakon Hanesand" => "hakon@hanesand.no", "Nikolai Heum" => "nikolaiheum@gmail.com"}
  s.source           = { :git => "https://github.com/abellono/IssueReporter.git", :tag => s.version.to_s }
  s.social_media_url   = "https://twitter.com/hhanesand"

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
    'IssueReporterResources' => ['Pod/Assets/*.{png,strings,storyboard}']
  }
end
