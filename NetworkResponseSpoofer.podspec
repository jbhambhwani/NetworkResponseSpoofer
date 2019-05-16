Pod::Spec.new do |s|
  s.name            = 'NetworkResponseSpoofer'
  s.version         = '10.1.0'
  s.swift_version   = '5.0.1'
  s.summary         = 'Network response record and replay library for iOS, watchOS, tvOS and macOS.'
  s.homepage        = 'https://github.com/HotwireDotCom/NetworkResponseSpoofer.git'
  s.license         = 'MIT'
  s.author          = { 'Deepu Mukundan' => 'deepumukundan@gmail.com' }
  s.description     = <<-EOS
  NetworkResponseSpoofer is a network response record and replay library for iOS, watchOS, tvOS and macOS.
  It’s built on top of the Foundation URL Loading System to make recording and replaying network requests really simple.
  EOS
  s.source          = { :git => 'https://github.com/HotwireDotCom/NetworkResponseSpoofer.git', :tag => s.version.to_s }
  s.requires_arc    = true

  s.ios.deployment_target = '10.0'
  s.dependency 'RealmSwift'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/**/*.swift'
    ss.framework  = 'Foundation'
    ss.ios.deployment_target = '10.0'
    ss.osx.deployment_target = '10.12'
    ss.watchos.deployment_target = '4.0'
    ss.tvos.deployment_target = '10.0'
  end

  s.subspec 'SpooferUI' do |ss|
    ss.source_files = 'Source/iOS_UI/**/*.swift'
    ss.resources = ['Source/iOS_UI/View/**/*.storyboard', 'Source/iOS_UI/View/**/*.xcassets']
    ss.dependency 'NetworkResponseSpoofer/Core'
    ss.framework = 'Foundation', 'UIKit'
    ss.ios.deployment_target = '10.0'
  end

end
