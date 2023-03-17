//
//  HomeViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2018/8/2.
//  Copyright © 2018年 艾美拉娜.王仁洁 All rights reserved.
//

import UIKit
import EnolaGay
//import SDCycleScrollView

/// 首页
class HomeViewCtrl: JudyBaseCollectionViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "首页"
    }
    
    override var itemSpacing: CGFloat {
        return 4
    }
    
    // MARK: - private var property - 私有var
    
    private var cycleScrollView: SDCycleScrollView?

    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = [
            ["headerTitle": "", "buttonTitle": "", "showBanner": true],
            
            ["headerTitle": "江西一区", "buttonTitle": "",
             "data": [
                ["title": "山贼", "icon": "AAA_01", "cell": "cellA"],
                ["title": "土匪", "icon": "AAA_05", "cell": "cellA"],
                ["title": "流氓", "icon": "AAA_07", "cell": "cellA"],
                ["title": "禽兽", "icon": "AAA_09", "cell": "cellA"],
                ["title": "僵尸", "icon": "AAA_11", "cell": "cellA"],
                ["title": "腊肉", "icon": "AAA_24", "cell": "cellA"],
                ["title": "野猪", "icon": "AAA_26", "cell": "cellA"],
                ["title": "蛇皮", "icon": "AAA_29", "cell": "cellA"],
                ]
            ],

            ["headerTitle": "上海二区", "buttonTitle": "",
             "data": [
                ["title": "短裤", "icon": "dog_1", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_2", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_3", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_4", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_5", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_6", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_7", "cell": "cellB"],
                ["title": "短裤", "icon": "dog_8", "cell": "cellB"],
                ]
            ],
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    // MARK: Api相关
    
//    override func setApi() {
//        super.setApi()
//
//        requestConfig.api = ApiActions.TCG.shopSearch
//        requestConfig.parameters = ["userName": "Judy"]
//    }
    /*
    override func reqSuccess() {
        super.reqSuccess()
        Judy.log("请求成功-\(apiData)")
        /*
         if isAddMore {
         <#T##dataSource.append(contentsOf: apiData["data", "list"].arrayValue)#>
         } else {
         <#T##dataSource = apiData["data", "list"].arrayValue#>
         }
         <#T##tableView#>?.reloadSections(IndexSet(integer: <#T##1#>))
         或
         <#T##tableView#>?.reloadData()
         
         */
        
//        collectionView?.performBatchUpdates(<#T##updates: (() -> Void)?##(() -> Void)?##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        
    }
    
    override func reqFailed() {
        super.reqFailed()
        
        Judy.log("请求失败-\(apiData)")
        
    }
     */
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: collectionView 数据源
    
    // MARK: cell数量

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        // 父类已设置为dataSource.count，如需修改请，重写此方法，但要注意cellFor里面DataSource[indexPath.row]越界
        return dataSource[section]["data"].arrayValue.count
    }
    
    // section数量
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return dataSource.count
    }
    
    // cell大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        var widthForCell: CGFloat = 80, heightForCell: CGFloat = 80
        // 一行有多少个cell
        var numForCellInRow: CGFloat = 1
        // cell宽度 = (屏宽 - cell最小间距*(cell数量 - 1)）/cell数量 - section的偏移量一侧即可
        // 如果一行内只显示1个cell，则直接 collectionView.frame.size.width - cell最小间距*2
        
        switch indexPath.section {
        case 1: numForCellInRow = 4
        case 2: numForCellInRow = 2
        case 3:
            numForCellInRow = 2
            widthForCell = (collectionView.frame.size.width - 1*(numForCellInRow - 1)) / numForCellInRow - 1
        case 4:
            numForCellInRow = 1
            widthForCell = collectionView.frame.size.width - 2
        default:
            break
        }
        widthForCell = (collectionView.frame.size.width - 1*(numForCellInRow - 1)) / numForCellInRow - 1

        return CGSize(width: widthForCell, height: heightForCell)
    }
    
    // MARK: 初始化Cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellIdentifier = dataSource[indexPath.section]["data"][indexPath.row]["cell"].stringValue
        // 此方法可以不判断cell == nil
        let cell: JudyBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! JudyBaseCollectionViewCell
        cell.json = dataSource[indexPath.section]["data"][indexPath.row]
        
        return cell
    }
    
    // 设置headerView的Size。一般用不上这个方法，在生成HeaderView中就可以设置高度或者在xib中设置高度即可。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var sizeHeight: CGFloat = 0
        switch section {
        case 0:
            sizeHeight = Judy.getScreenWidth()/2*3
        default:
            sizeHeight = 44
        }
        // 这里设置宽度不起作用
        return CGSize(width: 0, height: sizeHeight)
    }
    
    // 初始化 HeaderView 和 FooterView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            
            return footerView
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
        
        let label: UILabel? = headerView.viewWithTag(101) as? UILabel
        let moreButton: UIButton? = headerView.viewWithTag(102) as? UIButton
        
        if dataSource[indexPath.section]["showBanner"].boolValue {
            label?.isHidden = true
            moreButton?.isHidden = true
            // TODO: - 生成bannerView
            if cycleScrollView == nil {
                cycleScrollView = SDCycleScrollView.init(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height - 1))
                
                cycleScrollView!.placeholderImage = UIImage(named: "全民K歌")
                cycleScrollView?.localizationImageNamesGroup = ["IMG_2481", "IMG_2983", "IMG_3559"]
//                cycleScrollView?.imageURLStringsGroup = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1533291092524&di=e3db73e8e6493c7ad2e970bf7a33d9ee&imgtype=0&src=http%3A%2F%2Fs2.sinaimg.cn%2Fmiddle%2F003uaqfagy6WNixlw0F11%26690"]
                cycleScrollView!.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
                cycleScrollView!.delegate = self
                cycleScrollView!.currentPageDotColor = UIColor(rgbValue: 0xFF3D55)
                cycleScrollView!.backgroundColor = UIColor.white
                cycleScrollView!.bannerImageViewContentMode = .scaleAspectFill
                headerView.addSubview(cycleScrollView!)
            }
        } else {
            label?.isHidden = false
            moreButton?.isHidden = false

            label?.text = dataSource[indexPath.section]["headerTitle"].stringValue

        }

        return headerView
    }
    
    // MARK: collectionView 代理
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)

    }
    
    // 针对Section进行偏移
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets.init(top: 0, left: 1, bottom: 10, right: 1)
    }
    
    // 连续的行或列之间的最小间距
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 1
    }
    
    // 连续的Cell间的最小间距。这个间距决定了一行内有多少个Cell,但Cell的数量确定后,实际的间距可能会向上调整
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 1
    }

    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - SDCycleScrollView代理
extension HomeViewCtrl: SDCycleScrollViewDelegate{
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
//        let type = banner_list[index]["type"].intValue
//        switch type {
//        case 1: //跳链接
//
//            let viewCtrl = BaseWebViewController()
//            viewCtrl.webUrl = banner_list[index]["link"].stringValue
//            navigationController?.pushViewController(viewCtrl, animated: true)
//
//        case 2: //跳帖子
//
//            if banner_list[index]["identity"].stringValue == "1" {
//                //前台
//                let viewCtrl = PostDetailViewController()
//                viewCtrl.is_comment = banner_list[index]["is_comment"].stringValue
//                viewCtrl.article_id = banner_list[index]["article_id"].stringValue
//                navigationController?.pushViewController(viewCtrl, animated: true)
//            } else {
//                //后台
//
//                let viewCtrl = PostWebDetailViewController()
//
//                viewCtrl.webUrl = "\(WebUrl)/h5/page/rating.html?token=\(AccountBean.sharedInstance().currentUser.token)&article_id=\(banner_list[index]["article_id"].stringValue)"
//                //banner_list[index]["is_comment"].stringValue
//                viewCtrl.is_comment = banner_list[index]["is_comment"].stringValue
//                viewCtrl.article_id = banner_list[index]["article_id"].stringValue
//                navigationController?.pushViewController(viewCtrl, animated: true)
//            }
//
//        case 3: //跳h5
//            //跳h5
//            let viewCtrl = BaseWebViewController()
//
//            // TODO: - 记得替换http://hexhome2.qxtest01.cn测试连接
//            viewCtrl.webUrl = "\(WebUrl)/h5/page/detail.html?token=\(AccountBean.sharedInstance().currentUser.token)&id=\(banner_list[index]["id"].stringValue)"
//
//            navigationController?.pushViewController(viewCtrl, animated: true)
//        default:
//            break
//        }
    }

}
