#
# Be sure to run `pod lib lint EnolaGay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnolaGay'
  s.version          = '2.12.1'
  s.summary          = '便携式 App 架构，由早期的 EMERANA 进化而成。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'EMERANA 不再是当年艾美拉娜公主了，现如今已强化成足矣摧毁日本帝国的战士'

  s.homepage         = 'https://github.com/emerana/EnolaGay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '醉翁之意' => 'Judy_u@163.com' }
  s.source           = { :git => 'https://github.com/emerana/EnolaGay.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'EnolaGay/Classes/**/*'
  
  # s.resource_bundles = {
  #   'EnolaGay' => ['EnolaGay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'SwiftyJSON'

end
