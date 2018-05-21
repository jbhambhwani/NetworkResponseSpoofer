Pod::Spec.new do |s|
  s.name            = 'APIResponseSpoofer'
  s.version         = '6.0.0'
  s.swift_version   = '4.1.0'
  s.summary         = 'Network request-response recording and replaying library for iOS.'
  s.homepage        = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.license         = 'MIT'
  s.authors         = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.description     = <<-EOS
  APIResponseSpoofer is a network request-response recording and replaying library for iOS.
  It’s built on top of the Foundation URL Loading System to make recording and replaying network requests really simple.
  EOS

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '4.0'
  s.tvos.deployment_target = '10.0'

  s.source          = { :git => 'https://stash/scm/hotwire/apiresponsespoofer.git', :tag => s.version.to_s }
  s.requires_arc    = true
  s.default_subspec = 'Core'
  s.dependency 'RealmSwift'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/**/*.swift'
    ss.framework  = 'Foundation'
  end

  s.subspec 'iOS-UI' do |ss|
    ss.source_files = 'Source/iOS_UI/**/*.swift'
    ss.resources = ['Source/iOS_UI/View/**/*.storyboard', 'Source/iOS_UI/View/**/*.xcassets']
    ss.framework = 'UIKit'
  end

end
