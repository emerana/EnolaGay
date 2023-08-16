# EnolaGay

[![Version](https://img.shields.io/cocoapods/v/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![License](https://img.shields.io/cocoapods/l/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![Platform](https://img.shields.io/cocoapods/p/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)


#### EnolaGay 基础
- Core 文件夹下的基础功能，常用扩展、Judy 工具类、日志打印类等。
```ruby
pod 'EnolaGay'
```

## 此部分的 Pod 已包含 EnolaGay 基础，独立安装时会安装 pod 'EnolaGay'

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


#### 极简的打印工具，日志打印功能
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


## 要求

- iOS 11.0
- Xcode 10+
- Swift 5.0+

## 安装

就像这样，即可使用基础的 EnolaGay 能力。
```ruby
pod 'EnolaGay'
```
如果需要额外的能力，直接加上你要的 pod 就像这样……
```ruby
pod 'EnolaGay'
pod 'EnolaGay/EMERANA'
pod 'EnolaGay/TextFieldEffects'
pod 'EnolaGay/JudyPlusButtonTabBar'
……
```

## Author

醉翁之意, Judy_u@163.com

## License

EnolaGay is available under the MIT license. See the LICENSE file for more info.
