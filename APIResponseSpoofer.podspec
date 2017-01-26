Pod::Spec.new do |s|
  s.name = 'APIResponseSpoofer'
  s.version = '4.2.0'
  s.summary = 'Network request-response recording and replaying library for iOS.'
  s.description = <<-EOS
  APIResponseSpoofer is a network request-response recording and replaying library for iOS. It’s built on top of the Foundation URL Loading System to make recording and replaying network requests really simple.
  EOS
  s.homepage = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.license = 'MIT'
  s.authors = { 'Hotwire' => 'hotwiredevices@gmail.com' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source = { :git => 'https://stash/scm/hotwire/apiresponsespoofer.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.dependency 'RealmSwift'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/**/*.swift'
    ss.framework  = 'Foundation'
  end

  s.subspec 'iOS-UI' do |ss|
    ss.source_files = 'Source/iOS_UI/**/*.swift'
    ss.resources = 'Source/iOS_UI/View/*.{xcassets, storyboard}'
    ss.framework = 'UIKit'
  end

end
