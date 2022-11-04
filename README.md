# EnolaGay

[![Version](https://img.shields.io/cocoapods/v/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![License](https://img.shields.io/cocoapods/l/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![Platform](https://img.shields.io/cocoapods/p/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)


## 核心
EnolaGay 中的核心成员为项目开发提供了很多便利，简化了大部分开发流程，并极大地减少了日常开发中重复的工作。
#### JudyBaseViewCtrl
- 所有 ViewCtrl 的核心，建议使用 JudyBaseViewCtrl 作为项目中所有 ViewController 的父类。
- 集成了数据请求流程
- 支持 view 的背景色统一配置
#### JudyBaseTableViewCtrl、JudyBaseTableRefreshViewCtrl
- 集成了 tableView 的 JudyBaseViewCtrl
- 通过配置全局上下拉刷新功能更方便地使用 JudyBaseTableRefreshViewCtrl
#### JudyBaseCollectionViewCtrl、JudyBaseCollectionRefreshViewCtrl
- 类似 JudyBaseTableViewCtrl、JudyBaseTableRefreshViewCtrl 的 CollectionViewCtrl

## 功能介绍

- 抽象 Api 层，使你更清晰、简单的使用网络请求以便获取数据。
- 配置好 Api 层后，每个 JudyBaseViewCtrl 不再需要关心网络请求的细节，只管根据请求结果做你想做的任何事。
- 统一管理所有 JudyBaseViewCtrl、tableView、collectionView 及部分其他控件的背景色。
- EMERANA 是个宝藏，里面有很多常用的扩展。
- 对 UIColor 扩展构造函数。
- 对 UIFont 扩展构造函数，更方便的构造 UIFont.
- Judy 来自 2017，是 EnolaGay 的元老，功能少却最常用。EnolaGay 在 2020 年基于 Judy 的基础上迅速扩展。
- EnolaGay 中的其他组件也很丰富。


## 实现以下扩展

#### 基础配置
EnolaGay 全局配置，当前包含配置全局字体样式、颜色等，详见 EnolaGayAdapter 协议。
```ruby
extension UIApplication: EnolaGayAdapter
```

#### Api 层配置
JudyBaseViewCtrl 中的 ApiRequestConfig 部分属性及初值以及通用的请求接口配置，这在 JudyBaseViewCtrl 中是用于获取数据来源的重要对象。
```ruby
extension UIApplication: ApiAdapter
```

#### 域名管理配置
项目中所用到的域名均在此统一配置。通常情况下，为了配合 ApiRequestConfig 发起网络请求，需要同时配置 Api 层中用到的域名，无论项目中需要用到多少域名，ApiRequestConfig  会整理得井井有条。
```ruby
extension ApiRequestConfig.Domain
```

#### 上下拉刷新控件配置（如果需要）
用于 JudyBaseRefreshTableViewCtrl、JudyBaseRefreshCollectionViewCtrl 中实现下拉刷新、上拉分页加载。
```ruby
extension UIApplication: RefreshAdapter
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements

- iOS 13.0
- Xcode 10+
- Swift 5.0+

## Installation

EnolaGay is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EnolaGay'
```
## 可选能力模块

#### SegmentedView
```ruby
pod 'EnolaGay/SegmentedView'
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

## Author

醉翁之意, Judy_u@163.com

## License

EnolaGay is available under the MIT license. See the LICENSE file for more info.
