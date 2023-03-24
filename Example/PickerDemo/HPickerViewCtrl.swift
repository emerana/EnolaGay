//
//  HPickerViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/7/3.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class HPickerViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "HPciker" }

    let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    
    fileprivate let kItemW: CGFloat = (UIScreen.main.bounds.size.width - 296) / 2 + 118
    fileprivate let kItemH: CGFloat = 85
    
    fileprivate lazy var pickerScollView: HPicker = {
        let scrollView = HPicker.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT - 350, width: SCREEN_WIDTH, height: kItemH))
        scrollView.backgroundColor = .white
        scrollView.itemWidth = kItemW
        scrollView.itemHeight = kItemH
        scrollView.firstItemX = (scrollView.frame.size.width - scrollView.itemWidth) * 0.5
        scrollView.dataSource = self
        scrollView.delegate = self
        return scrollView
    }()
    
    fileprivate lazy var dataArray = [MLDemoModel]()
    fileprivate var currentMonthIndex: NSInteger = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setUpUI()
        
    }
    
    fileprivate func setUpUI() {
        
        // 1.数据源
        let titleArray = ["Judy", "EnolaGay", "emerana", "浙江温州", "江南皮革厂", "倒闭了"]
        for (i,title) in titleArray.enumerated() {
            let model = MLDemoModel()
            model.title = title
            model.index = i
            model.isCurrentMonth = false

            dataArray.append(model)
        }
        
        // 2.初始化
        view.addSubview(pickerScollView)
        
        // 3.刷新数据
        pickerScollView.reloadData()
        
        pickerScollView.seletedIndex = 0
        pickerScollView.scollToSelectdIndex(0)
        
    }
    
}

extension HPickerViewCtrl: MLPickerScrollViewDataSource,MLPickerScrollViewDelegate {
    
    func numberOfItemAtPickerScrollView(_ pickerScrollView: HPicker) -> NSInteger {
        return dataArray.count
    }
    
    func pickerScrollView(pickerScrollView: HPicker, itemAtIndex index: NSInteger) -> MLPickerItem {
        // creat
        let item = MLDemoItem.init(frame: CGRect.init(x: 0, y: 0, width: pickerScollView.itemWidth, height: pickerScollView.itemHeight))
        
        // assignment
        let model = dataArray[index]
        model.index = index
        item.title = model.title
        item.setGrayTitle()
        
        // tap
        item.pickerItemSelectBlock = { [weak self](selIndex) in
            self?.pickerScollView.scollToSelectdIndex(selIndex)
        }
        
        return item
    }
    
    func pickerScrollView(menuScrollView: HPicker, didSelecteItemAtIndex index: NSInteger) {
        print("当前选中item---\(index)")
    }
    
    func itemForIndexBack(item: MLPickerItem) {
       item.backSizeOfItem()
    }
    
    func itemForIndexChange(item: MLPickerItem) {
        item.changeSizeOfItem()
    }
    
}


class MLDemoItem: MLPickerItem {


    public var title: String? {
        didSet{
            btn.setTitle(title, for: .normal)
        }
    }
    
    public lazy var btn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.isEnabled = false
        return button
    }()
    
    fileprivate let kITEM_W: CGFloat = (UIScreen.main.bounds.size.width - 296) / 2 + 118
    fileprivate let kITEM_H: CGFloat = 38
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    fileprivate func setUI() {
        let itemW: CGFloat = kITEM_W
        let itemH: CGFloat = kITEM_H
        let itemX: CGFloat = (frame.width - itemW) * 0.5
        let itemY: CGFloat = (frame.height - itemH) * 0.5
        btn.frame = CGRect.init(x: itemX, y: itemY, width: itemW, height: itemH)
        
        addSubview(btn)
    }
    
    // MARK: - Public method
    open func setBlackTitle() {
        btn.setTitleColor(.black, for: .normal)
    }
    
    open func setGrayTitle() {
        btn.setTitleColor(.lightGray, for: .normal)
    }
    
    override func changeSizeOfItem() {
        setBlackTitle()
    }
    
    override func backSizeOfItem() {
        setGrayTitle()
    }
}

class MLDemoModel: NSObject {
    var title: String?
    var index: NSInteger = 0
    var isCurrentMonth: Bool = false
}
