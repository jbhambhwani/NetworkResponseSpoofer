Pod::Spec.new do |s|
  s.name = 'APIResponseSpoofer'
  s.version = '0.9.0'
  s.license = 'MIT'
  s.summary = 'Network request-response recording and replaying library for iOS.'
  s.homepage = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.authors = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.source = { :git => 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer.git', :branch => 'warning-fix' }
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.public_header_files = 'APIResponseSpoofer/APIResponseSpoofer.h'
  s.source_files = 'APIResponseSpoofer/**/*.swift'
  s.requires_arc = true
end
