//
//  JudyNavigationFullCtrl.h
//
//  全屏幕返回样式的导航
//  Created by cz10000 on 16/4/27.
//  Copyright © 2016年 cz10000. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 全屏幕Pop和Push样式的导航控制器,系统的手势方式全屏动画Navigation */
@interface JudyNavigationFullCtrl : UINavigationController

/** 是否开启JudyNavigationFullCtrl功能，默认是true。*/
@property (assign, nonatomic) BOOL isEnabled;


@end
