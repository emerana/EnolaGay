# EnolaGay

[![CI Status](https://img.shields.io/travis/醉翁之意/EnolaGay.svg?style=flat)](https://travis-ci.org/醉翁之意/EnolaGay)
[![Version](https://img.shields.io/cocoapods/v/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![License](https://img.shields.io/cocoapods/l/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)
[![Platform](https://img.shields.io/cocoapods/p/EnolaGay.svg?style=flat)](https://cocoapods.org/pods/EnolaGay)

### EnolaGay 为项目开发提供了一些便利，简化了部分开发流程，极大地减少了日常开发中重复的流程。

## Core

- Judy
- EMERANA
- JudyBaseViewCtrl

## Features

- [x] 整合 Api 请求流程的 base viewController
- [x] 支持全局 Api 请求配置
- [x] 支持全局字体、颜色配置
- [x] 内置常用 UI 组件
- [x] 内置常用套件

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
