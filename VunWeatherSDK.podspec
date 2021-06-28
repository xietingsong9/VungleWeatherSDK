#
# Be sure to run `pod lib lint VunWeatherSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VunWeatherSDK'
  s.version          = '0.1.0'
  s.summary          = 'Provide the function of getting real-time weather'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Provide the function of getting real-time weather.
                       DESC

  s.homepage         = 'https://github.com/xietingsong9/VungleWeatherSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xietingsong9' => 'xietingsong3@163.com' }
  s.source           = { :git => 'https://github.com/xietingsong9/VungleWeatherSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.1'

  s.source_files = 'VunWeatherSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'VunWeatherSDK' => ['VunWeatherSDK/Assets/*.png']
  # }
s.frameworks = "CoreGraphics", "CoreLocation", "Foundation"
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
