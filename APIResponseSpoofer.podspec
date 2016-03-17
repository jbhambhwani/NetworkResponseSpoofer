Pod::Spec.new do |s|
  s.name = 'APIResponseSpoofer'
  s.version = '0.9.5'
  s.license = 'MIT'
  s.summary = 'Network request-response recording and replaying library for iOS.'
  s.homepage = 'https://stash/projects/HOTWIRE/repos/apiresponsespoofer'
  s.authors = { 'Hotwire' => 'hotwiredevices@gmail.com' }
  s.source = { :git => 'https://dmukundan@stash/scm/hotwire/apiresponsespoofer.git', :tag => s.version }
  s.platforms = { :ios => "8.0", :tvos => "9.0" }
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'APIResponseSpoofer/**/*.swift'
  s.requires_arc = true
end
