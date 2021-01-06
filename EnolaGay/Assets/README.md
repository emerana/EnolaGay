# 注意事项 

### 使用EnolaGay框架必须安装的pod


pod 'MJRefresh'
pod 'SDWebImage'
pod 'Alamofire', '~> 4.9.0'
pod 'MBProgressHUD'


##   常用到的 pod
##    几块废铁
###    pod 'FileKit', '~> 5.0.0'
###   pod 'PermissionScope'
###    pod 'ImageViewer'
###    pod 'Timepiece'
###    pod 'Spring'

* pod 'Alamofire', '~> 4.4'
* pod 'IQKeyboardManagerSwift'
* pod 'MBProgressHUD'
* pod 'SwiftMessages'
* pod 'JLRoutes'
* pod 'MJRefresh'
* pod 'SDWebImage'
* pod 'SDCycleScrollView'
* pod 'CSGrowingTextView', '~> 1.0'
* pod 'SocketRocket'    # https://github.com/facebook/SocketRocket.git
* pod ‘RESideMenu’, ‘~> 4.0.7’ #侧边菜单
* pod 'IGListKit', '~> 3.0'
* pod "Texture"

* pod 'RxSwift',    '~> 4.0'
* pod 'RxCocoa',    '~> 4.0'
* pod 'ImageViewer'
* pod "Timepiece"
* pod 'ResponseDetective'
* pod 'DeviceKit', '~> 1.3'
* pod 'SwiftyUserDefaults', '4.0.0-alpha.1'
* pod 'FileKit', '~> 5.0.0'
* pod 'PermissionScope'



1. DZNEmptyDataSet [UI, 空table view解决方案]

2. PDTSimpleCalendar [UI, 可放入日历组件]

3. MagicalRecord [Core Data帮手实现活动记录模式]

4. ChameleonFramework [UI, 颜色框架]

5. Alamofire [Swift网络]

6. TextFieldEffects [UI, 自定义外观text fields]

7. GPUImage [快速图像处理]

8. iRate [获得用户评价]

9. GameCenterManager [轻松管理Game Center]

10. PKRevealController [UI, 滑动边栏]

11. SlackTextViewController [UI, 高度自定义text field]

12. RETableViewManager [用代码动态创建table view]

13. PermissionScope [UI, 巧妙的提前问用户要系统许可]

14. SVProgressHUD [UI, 自定义等待菊花]

15. FontAwesomeKit [轻松地添加酷字体到你的app中]

16. SnapKit [用代码轻松auto layout]

17. MGSwipeTableCell [UI, 可滑动的table view cells]

18. Quick [Swift 单元测试框架]

19. IAPHelper [app内购封装帮手]

20. ReactiveCocoa [FRP框架]

21. SwiftyJSON [Swift JSON库]

22. Spring [动画框架]

23. FontBlaster [轻松在app中加载自定义字体]

24. TAPromotee [在你的app中交叉提示，置入界面]

25. Concorde [下载和解码进度化JPEGs]

26. KeychainAccess [轻松管理钥匙串]

27. iOS-charts [漂亮的图表库]


# 笔记
 
### 从xib载入Cell，xib中包含多个cell
var cell = Bundle.main.loadNibNamed("PayViewCell", owner: self, options: nil)![0] as! UITableViewCell

###  确保当前不是某个类的子类，一定要是指定类而不是isKindOf(子类)
self !== LoginCodeViewCtrl.self 或 self.classForCoder != LoginCodeViewCtrl.classForCoder() 


###  此方法将指定 ViewController 导航条返回按钮删除，且滑动返回手势失效，需要自行实现 pop.

navigationItem.setLeftBarButton(UIBarButtonItem(), animated: false)


###  Swift 预编译，Swift Compiler - Custom Flags 中 Active Compilation Conditions 增加子选项

#if DEVELOP && !NOLOG
//
#elseif PRODCTN
//
#else
//
#endif

### OC 预编译，增加 Preprocessor Macros

#ifdef DEBUG
// Debug-only code
#endif

### UIStoryboardSegue 反向传值：B -反向-> A，在 A 中定义接收方法，在 B 中 ViewCtrl 按钮向 Exit 按钮联线定义 Segue，选中 A 中定义的接收方法，在 B 界面离开前执行 Segue 即可
@IBAction func popFromAuthenticationViewCtrl(segue: UIStoryboardSegue) {

}

### 闭包中防止循环引用

{   [weak self] button in

    if let strongSelf = self {
            strongSelf.XXX
    }
}

### protocol 只有遵循 class 才能 定义成 weak 才不会被引用计数


### Judy-mark: 将 tableView 置顶，滚动到顶部
if tableView?.visibleCells.count != 0 {
tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
}

### Judy-mark: 拉伸图片
let myInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 58)
// 拉伸中间部分
let newImage = 圆角矩形.image?.resizableImage(withCapInsets: myInsets, resizingMode: UIImage.ResizingMode.stretch)
imageView.image = newImage

### Judy-mark: 不实现tableView Row Height 代理方法
// Judy-mark: 使其使用 sb 中 Cell custom 高度，tableView 要将 RowHeight、Estimate 设为 Automatic
return UITableView.automaticDimension

### Judy-mark: 占位提示代码的使用，将下面连成一行即可
/*@START_MENU_TOKEN@*/"Judy"
/*@END_MENU_TOKEN@*/


## 常见问题及解决方案
- Status bar could not find cached time string image. Rendering in-process.
-> 勾选’Hide status bar'



