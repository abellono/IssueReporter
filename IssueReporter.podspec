Pod::Spec.new do |s|
  s.name             = "IssueReporter"
  s.version          = "1.1.1"
  s.summary          = "Shake your phone to submit issues to your GitHub repository!"
  s.description      = <<-DESC
                        Presents a modal view controller when the phone is shaken that allows the user to report an issue in the app. A screen shot of the window the user was on is taken, and the user also has the option to upload his or her own images.
                       DESC
  s.homepage         = "https://github.com/abellono/IssueReporter"
  s.license          = 'MIT'
  s.author           = { "Hakon Hanesand" => "hakon@hanesand.no", "Nikolai Heum" => "nikolaiheum@gmail.com"}
  s.source           = { :git => "https://github.com/abellono/IssueReporter.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
    'IssueReporterResources' => ['Pod/Assets/*.{png,strings,storyboard}']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
end
