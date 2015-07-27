Pod::Spec.new do |s|
  s.name             = "IssueReporter"
  s.version          = "0.1.14"
  s.summary          = "An extremely lightweight but powerful plugin to use in your iOS application that can create new GitHub issues when the phone is shaken."
  s.description      = <<-DESC
                        An extremely lightweight library that only relies on AFNetworking to allow creating new issues on Github. After proper configuration, this library
                        allows the user to shake the phone to report bugs in the app. Very useful for clients who are not comfortable with using Github. After the phone is has been
                        shaken, the library snapshots the current screen the user was on to aid in debugging. The user then is presented with a screen where he can enter the title of
                        the issue and a more detailed description. The user even has the option to add more images to upload with the issue.
                       DESC
  s.homepage         = "https://github.com/abellono/IssueReporter"
  s.license          = 'MIT'
  s.author           = { "Hakon Hanesand" => "hakon@hanesand.no"}
  s.source           = { :git => "https://github.com/abellono/IssueReporter.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
    'IssueReporter' => ['Pod/Assets/*.{png,strings}']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'AFNetworking'
end
