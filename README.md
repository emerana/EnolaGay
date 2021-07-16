# EnolaGay

[![CI Status](https://img.shields.io/travis/pods/EnolaGay.svg?style=flat)](https://travis-ci.org/pods/EnolaGay)
[![Version](https://img.shields.io/cocoapods/v/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![License](https://img.shields.io/cocoapods/l/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![Platform](https://img.shields.io/cocoapods/p/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)


## Core
### EnolaGay 为项目开发提供了一些便利，简化了部分开发流程，极大地减少了日常开发中重复的流程。
- 项目中所有的 ViewController 均继承自 JudyBaseViewCtrl 及其子类。
- 配置 Api 层。
- 配置上下拉刷新控件（如果需要）。

## Features

- [x] 项目中无论你有多少个域名，配置好了 Api 层你将不再混乱。
- [x] 每个 ViewController 及其子类无需关心网络请求的细节，只管根据请求结果做你想做的任何事。
- [x] 更改所有 viewCtrl、tableView、collectionView 及部分其他控件的背景色。
- [x] EMERANA 是个宝藏，里面有很多常用的扩展。
- [x] Judy 是 EnolaGay 的元老，功能少但随处可见，其诞生于 2017 年。EnolaGay 在 2020 年基于 Judy 的基础上迅速扩展。
- [x] EnolaGay 中的其他组件。

## master extension
- [x] extension EMERANA.Key: 项目中用到的可访问性字符，当然您也可以自己管理而不必扩展。
- [x] extension UIApplication: EnolaGayAdapter: EnolaGay 全局配置，当前只是配置部分通用背景色等，详见 EnolaGayAdapter.
- [x] extension UIApplication: RefreshAdapter: 配置刷新控件, JudyBaseRefreshTableViewCtrl、JudyBaseRefreshCollectionViewCtrl 需要上拉分页加载。

- [x] extension UIApplication: ApiAdapter: Api 层配置，ApiRequestConfig 部分属性及初值以及通用的请求接口均可配置，整好了 ApiRequestConfig 项目中的网络请求将会简单许多。
- [x] extension ApiRequestConfig.Domain: 项目 Api 层中所用到的域名管理，无论项目中需要用到多少域名，ApiRequestConfig  会整理得井井有条。


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 12.0
- Xcode 10+
- Swift 5.0+

## Installation

EnolaGay is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EnolaGay'
```

## Author

醉翁之意, Judy_u@163.com

## License

EnolaGay is available under the MIT license. See the LICENSE file for more info.
