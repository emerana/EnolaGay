#
# Be sure to run `pod lib lint EnolaGay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnolaGay'
  s.version          = '4.0.6'
  s.summary          = 'EnolaGay 架构，由早期的 EMERANA 进化而成。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'EMERANA 经过了几年的历练，在多个 App 中不断完善，最终进化成可适用于绝大部分场景的便携式框架。'

  s.homepage         = 'https://github.com/emerana/EnolaGay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '醉翁之意' => 'Judy_u@163.com' }
  s.source           = { :git => 'https://github.com/emerana/EnolaGay.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.0'
  s.requires_arc = true
  
  #  如果不指定默认的 spec，则将安装所有的 spec。 pod ‘EnolaGay’ 即安装 EnolaGay/EMERANA 核心文件夹
  s.default_subspec = 'Core'
  
  # 默认安装的核心 spec
  s.subspec 'Core' do |ss|
      ss.source_files = 'EnolaGay/Classes/Core/*'
      # ss.dependency 'SwiftyJSON' 取消依赖 SwiftyJSON
      # ss.exclude_files = 'EnolaGay/Classes/*'
      # ss.resource_bundles = {'EnolaGay' => ['EnolaGay/Classes/*.xib']}
  end
  
  # MARK: - 可选能力模块
  
  # MARK: UI 扩展，默认包含核心所有能力
  s.subspec 'EMERANA' do |ss|
      ss.dependency 'EnolaGay/Core'
      ss.source_files = 'EnolaGay/Classes/UIBase/*'
  end

  # MARK: 水平方向选择器
  s.subspec 'SegmentedView' do |ss|
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/SegmentedView/*'
  end
  
  # MARK: 水平方向的滚动选择器，SegmentedView 则是不支持滚动选择的。
  s.subspec 'HPickerView' do |ss|
      ss.dependency 'EnolaGay/Core'
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/HPickerView/*'
  end
  
  # MARK: 一些输入框
  s.subspec 'TextFieldEffects' do |ss|
      # 全是 JudyBaseTextField 子类
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/TextFieldEffects/*'
  end

  # MARK: WKWebView
  s.subspec 'WKWebView' do |ss|
      ss.dependency 'EnolaGay/EMERANA'
      ss.source_files = 'EnolaGay/Classes/WKWebView/*'
  end
  
  # MARK: 以上 pod 能力模块独立安装时将自动安装 pod 'EnolaGay' 核心
  
  # MARK: -
  
  # MARK: - 以下 pod 独立安装时不依赖 pod 'EnolaGay' 核心
  
  # MARK: 此功能仅包含 Debug 打印和日志文件输出功能
  s.subspec 'Logger' do |ss|
      ss.source_files = 'EnolaGay/Classes/Core/Logger.Swift'
  end

  # MARK: 直播间送礼物面板
  s.subspec 'GiftMessageCtrlPanel' do |ss|
      ss.source_files = 'EnolaGay/Classes/GiftMessageCtrlPanel/*'
  end

  # MARK: 烟花爆炸效果
  s.subspec 'JudyPopBubble' do |ss|
      ss.source_files = 'EnolaGay/Classes/JudyPopBubble/*'
  end

  # MARK: 中间大按钮的 tabBar
  s.subspec 'JudyPlusButtonTabBar' do |ss|
      ss.source_files = 'EnolaGay/Classes/JudyPlusButtonTabBar/*'
  end
  
  # MARK: 圆环进度条
  s.subspec 'CircularProgressView' do |ss|
      ss.source_files = 'EnolaGay/Classes/CircularProgressView/*'
  end

  # MARK: 水波 View
  s.subspec 'JudyWaterWaveView' do |ss|
      ss.source_files = 'EnolaGay/Classes/JudyWaterWaveView/*'
  end
  
  # MARK: 跑马灯效果 View
  s.subspec 'MarqueeView' do |ss|
      ss.source_files = 'EnolaGay/Classes/MarqueeView/*'
  end

  # MARK: KeyboardHelper
  s.subspec 'KeyboardHelper' do |ss|
      ss.source_files = 'EnolaGay/Classes/KeyboardHelper/*'
  end

  # MARK: HUD
  s.subspec 'HUD' do |ss|
      ss.ios.deployment_target = '13.0'
      ss.source_files = 'EnolaGay/Classes/ProgressHUD/*'
  end

  
  #  s.subspec 'SearchViewCtrl' do |ss|
  #      ss.dependency 'EnolaGay/EMERANA'
  #      ss.source_files = 'EnolaGay/Classes/SearchViewCtrl/*'
  #  end
  
  #  s.subspec 'FileManager' do |ss|
  #      ss.dependency 'EnolaGay/EMERANA'
  #      ss.source_files = 'EnolaGay/Classes/FileManager/*'
  #  end
  
  #  emerana.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}
  #  s.source_files = 'EnolaGay/Classes/**/*' 包含所有子目录下的所有文件
  
  # s.resource_bundles = {
  #   'EnolaGay' => ['EnolaGay/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  

end
