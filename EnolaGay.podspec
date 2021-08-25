#
# Be sure to run `pod lib lint EnolaGay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnolaGay'
  s.version          = '3.7.2'
  s.summary          = '便携式 App 架构，由早期的 EMERANA 进化而成。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '为了更高效地开发 iOS App, EMERANA 经过了几年的历练，在多个 App 中不断完善，最终进化成可适用于绝大部分场景的便携式框架。'

  s.homepage         = 'https://github.com/emerana/EnolaGay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '醉翁之意' => 'Judy_u@163.com' }
  s.source           = { :git => 'https://github.com/emerana/EnolaGay.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.requires_arc = true
  #  如果不指定默认的 spec，则将安装所有的 spec
  s.default_subspec = 'EMERANA'
  
  s.subspec 'EMERANA' do |ss|
      ss.source_files = 'EnolaGay/Classes/Core/*'
      ss.dependency 'SwiftyJSON'
      # ss.exclude_files = 'EnolaGay/Classes/*'
      # ss.resource_bundles = {'EnolaGay' => ['EnolaGay/Classes/*.xib']}
  end
  
  s.subspec 'SegmentedView' do |ss|
      # 使用到 JudyBasePageViewCtrl
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/SegmentedView/*'
  end
  
  s.subspec 'HPickerView' do |ss|
      # 使用到 NSMutableAttributedString 高配版生成器
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/HPickerView/*'
  end
  
  s.subspec 'JudyPopBubble' do |ss|
      ss.source_files = 'EnolaGay/Classes/JudyPopBubble/*'
  end

  s.subspec 'JudyWaterWaveView' do |ss|
      ss.source_files = 'EnolaGay/Classes/JudyWaterWaveView/*'
  end
  
  s.subspec 'MarqueeView' do |ss|
      ss.source_files = 'EnolaGay/Classes/MarqueeView/*'
  end
  
  s.subspec 'CircularProgressView' do |ss|
      ss.source_files = 'EnolaGay/Classes/CircularProgressView/*'
  end
  
  s.subspec 'GiftMessageCtrlPanel' do |ss|
      ss.source_files = 'EnolaGay/Classes/GiftMessageCtrlPanel/*'
  end
  
  s.subspec 'TextFieldEffects' do |ss|
      # 全是 JudyBaseTextField 子类
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/TextFieldEffects/*'
  end
  
  s.subspec 'SearchViewCtrl' do |ss|
    ss.dependency 'EnolaGay/EMERANA'
    ss.source_files = 'EnolaGay/Classes/SearchViewCtrl/*'
  end
  
  s.subspec 'FileManager' do |ss|
    ss.dependency 'EnolaGay/EMERANA'
    ss.source_files = 'EnolaGay/Classes/FileManager/*'
  end
  
  #  emerana.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}
  #  s.source_files = 'EnolaGay/Classes/**/*' 包含所有子目录下的所有文件
  
  # s.resource_bundles = {
  #   'EnolaGay' => ['EnolaGay/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  

end
