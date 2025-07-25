#
# Be sure to run `pod lib lint KVHeroTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

# to update new version need:
# - Increase s.version
# - Run command 'pod trunk push KVHeroTransition.podspec --allow-warnings'

Pod::Spec.new do |s|
  s.name             = 'KVHeroTransition'
  s.version          = '0.1.3'
  s.summary          = 'A lightweight and customizable zoom transition animation library for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  KVHeroTransition is a lightweight and customizable zoom transition animation library for iOS.
  It provides elegant view controller transitions similar to hero-style animations,
  supporting interactive dismiss and corner radius/curve customization.
    DESC

  s.homepage         = 'https://github.com/khanhVu-ops/KVHeroTransition'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Khanh Vu' => 'vuvankhanh022002@gmail.com' }
  s.source           = { :git => 'https://github.com/khanhVu-ops/KVHeroTransition.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'KVHeroTransition/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KVHeroTransition' => ['KVHeroTransition/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.requires_arc = true

  # s.dependency 'AFNetworking', '~> 2.3'
end
