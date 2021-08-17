#
# Be sure to run `pod lib lint EnolaGay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnolaGay'
  s.version          = '3.5.0'
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
  s.requires_arc = true
  #  s.default_subspec  = 'EMERANA'

  s.subspec 'EMERANA' do |emerana|
      emerana.source_files = 'EnolaGay/Classes/*'
      # emerana.exclude_files = 'EnolaGay/Classes/*'
      emerana.resource_bundles = {'EnolaGay' => ['EnolaGay/Classes/*.xib']}

  end
  
  s.subspec 'Judy' do |judy|
      judy.source_files = 'EnolaGay/Classes/Judy/*'
  end

  s.subspec 'SegmentedView' do |segmentedView|
      segmentedView.source_files = 'EnolaGay/Classes/SegmentedView/*'
  end
  
  s.subspec 'HPickerView' do |hpickerView|
      hpickerView.source_files = 'EnolaGay/Classes/HPickerView/*'
  end
  
  s.subspec 'JudyTextFieldEffects' do |textFieldEffects|
      textFieldEffects.source_files = 'EnolaGay/Classes/JudyTextFieldEffects/*'
  end
  
  s.subspec 'SearchViewCtrl' do |searchViewCtrl|
      searchViewCtrl.source_files = 'EnolaGay/Classes/SearchViewCtrl/*'
  end
  
  #  emerana.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}
  #  s.source_files = 'EnolaGay/Classes/**/*' 包含所有子目录下的所有文件
  
  # s.resource_bundles = {
  #   'EnolaGay' => ['EnolaGay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'SwiftyJSON'

end
