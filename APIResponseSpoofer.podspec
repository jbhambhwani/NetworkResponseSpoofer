Pod::Spec.new do |s|
  s.name = 'APIResponseSpoofer'
  s.version = '3.1.0'
  s.summary = 'Network request-response recording and replaying library for iOS.'
  s.description = <<-EOS
  APIResponseSpoofer is a network request-response recording and replaying library for iOS. It’s built on top of the Foundation URL Loading System to make recording and replaying network requests really simple.
  EOS
  s.homepage = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.license = 'MIT'
  s.authors = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.platforms = { :ios => '8.0'}
  s.ios.deployment_target = '8.0'
  s.source = { :git => 'https://stash/scm/hotwire/apiresponsespoofer.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.dependency 'RealmSwift'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/**/*.swift'
    ss.framework  = 'Foundation'
  end

  s.subspec 'iOS-UI' do |ss|
    ss.source_files = 'Source/iOS UI/**/*.swift'
    s.resources = 'Source/iOS UI/View/*.storyboard'
    ss.framework = 'UIKit'
  end

end
