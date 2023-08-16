# EnolaGay

[![Version](https://img.shields.io/cocoapods/v/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![License](https://img.shields.io/cocoapods/l/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![Platform](https://img.shields.io/cocoapods/p/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)


#### EnolaGay 基础
- 仅包含 Core 文件夹下的基础功能，常用扩展、Judy 工具类、日志打印类等。
```ruby
pod 'EnolaGay'
```

## 此部分的 Pod 已包含 pod 'EnolaGay'，独立安装时会安装 pod 'EnolaGay'

#### UIKit 扩展功能
- 为 UIKit 提供的功能。
```ruby
pod 'EnolaGay/EMERANA'
```
  
#### EnolaGay/HPickerView
- 水平方向的滚动选择器，SegmentedView 则是不支持滚动选择的。
```ruby
pod 'EnolaGay/HPickerView'
```

#### EnolaGay/TextFieldEffects
- 一些输入框
```ruby
pod 'EnolaGay/TextFieldEffects'
```
  
#### EnolaGay/WKWebView
- 包含 'EnolaGay/EMERANA' 核心
```ruby
pod 'EnolaGay/WKWebView'
```

## 以下的 Pod 均不包含 pod 'EnolaGay'，独立安装时不会安装 pod 'EnolaGay'

## 极简的打印工具

#### 日志打印功能
- 仅包含日志打印功能，常用与 SwiftUI 项目。
```ruby
pod 'EnolaGay/Logger'
```

#### 直播间送礼物面板
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/GiftMessageCtrlPanel'
```

#### 烟花爆炸效果
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/JudyPopBubble'
```

#### 中间大按钮的 tabBar
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/JudyPlusButtonTabBar'
```

#### 圆环进度条
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/CircularProgressView'
```

#### 水波 View
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/JudyWaterWaveView'
```

#### 跑马灯效果 View
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/MarqueeView'
```

#### KeyboardHelper 动画键盘
- 不包含 pod 'EnolaGay'
```ruby
pod 'EnolaGay/KeyboardHelper'
```

#### HUD
- 不包含 pod 'EnolaGay'，要求 iOS 13.
```ruby
pod 'EnolaGay/HUD'
```


## 核心
描述。
#### EnolaGay
- 核心

## 功能介绍

- 核心。

## 实现以下扩展

#### 基础配置
EnolaGay 全局配置，当前包含配置全局字体样式、颜色等，详见 EnolaGayAdapter 协议。
```ruby
extension UIApplication: EnolaGayAdapter
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements

- iOS 11.0
- Xcode 10+
- Swift 5.0+

## Installation

EnolaGay is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EnolaGay'
```
## 可选能力模块

#### UI 扩展相关功能
```ruby
pod 'EnolaGay/EMERANA'
```
#### HPickerView
```ruby
pod 'EnolaGay/HPickerView'
```
#### TextFieldEffects
```ruby
pod 'EnolaGay/TextFieldEffects'
```
#### JudyPopBubble
```ruby
pod 'EnolaGay/JudyPopBubble'
```
#### JudyWaterWaveView
```ruby
pod 'EnolaGay/JudyWaterWaveView'
```
#### CircularProgressView
```ruby
pod 'EnolaGay/CircularProgressView'
```
#### GiftMessageCtrlPanel
```ruby
pod 'EnolaGay/GiftMessageCtrlPanel'
```
#### MarqueeView
```ruby
pod 'EnolaGay/MarqueeView'
```

#### SearchViewCtrl
```ruby
pod 'EnolaGay/SearchViewCtrl'
```

#### FileManager
```ruby
pod 'EnolaGay/FileManager'
```

#### JudyBaseWebViewCtrl
```ruby
pod 'EnolaGay/WKWebView'
```

#### JudyPlusButtonTabBar
```ruby
pod 'EnolaGay/JudyPlusButtonTabBar'
```


## Author

醉翁之意, Judy_u@163.com

## License

EnolaGay is available under the MIT license. See the LICENSE file for more info.
