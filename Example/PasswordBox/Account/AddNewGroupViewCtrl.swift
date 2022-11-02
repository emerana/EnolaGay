//
//  AddNewGroupViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

/// 添加分组界面
class AddNewGroupViewCtrl: JudyBaseCollectionViewCtrl {
    override var viewTitle: String? { "添加分组" }

    // MARK: - let property and IBOutlet
    
    /// 显示图标的按钮
    @IBOutlet weak private var iconButton: UIButton!
    /// 组名
    @IBOutlet weak private var groupNameTextField: JudyBaseTextField!
    @IBOutlet weak private var iconCollectionView: UICollectionView!
    /// 添加按钮
    @IBOutlet weak private var addButton: JudyBaseButton!
    
    // MARK: - public var property
    
    override var itemSpacing: CGFloat { 16 }

    // MARK: - private var property
    private let disposeBag = DisposeBag()
    /// 用于构建新组的模型
    private(set) var group: Group?

    /// 记录当前选中的 indexPath，单选方案。
    private(set) var selectedIndexPath = IndexPath(item: 0, section: 0)
    /// 记录 icon 选择的 indexPath.
    private(set) var iconSelectedIndexPath = IndexPath(item: 0, section: 0)
    /// 可监听的 iconSelectedIndexPath
    private(set) var iconSelectedIndex = BehaviorSubject<IndexPath>(value: IndexPath(item: 0, section: 0))
    
    /// 组图标数据源
    private var iconNameList: [String] { ICONCtrl.judy.names(iconBundle: .icons_group) }
    
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = AddNewGroupViewModel(groupNameTextField: groupNameTextField.rx.text.orEmpty.asObservable())
        viewModel.groupNameValid.bind(to: addButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 添加按钮点击事件
        addButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            
            /// 得到10进制的颜色数值，需要转成16进制。
            let color10 = Group.backgroundColorValues[self.selectedIndexPath.row]
            self.group = Group(id: 0,
                               name: self.groupNameTextField.text!,
                               // 这里颜色需要转成16进制存储才行。十进制转十六进制,返回的是字符串格式。
                               backgroundColor: String(color10,radix:16))
            self.group?.icon = self.iconNameList[self.iconSelectedIndexPath.row]
            
            // 触发 unwind 事件
            self.performSegue(withIdentifier: "completeAndDismissAction", sender: nil)
        }.disposed(by: disposeBag)
        
        // 选中的图标绑定到按钮显示
        iconSelectedIndex.map { [weak self] indexPath in
            guard let self = self else { return UIImage(named: "placeholder")! }
            return UIImage(named: self.iconNameList[indexPath.row],
                    in: ICONCtrl.judy.bundle(iconBundle: .icons_group),
                    compatibleWith: nil)
        }
        .bind(to: iconButton.rx.backgroundImage(for: .normal))
        .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    // MARK: - override
    
    // MARK: - event response

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - private methods

private extension AddNewGroupViewCtrl {

}


// MARK: - UICollectionViewDataSource
extension AddNewGroupViewCtrl {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == iconCollectionView {
            return iconNameList.count
        }

        return Group.backgroundColorValues.count
    }
    
    /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        if collectionView == iconCollectionView {
            (cell.viewWithTag(101) as? UIImageView)?.image = UIImage(named: iconNameList[indexPath.row],
                    in: ICONCtrl.judy.bundle(iconBundle: .icons_group),
                    compatibleWith: nil)
            
            if iconSelectedIndexPath == indexPath {
                cell.judy.viewBorder(border: 6, color: .purple)
            } else {
                cell.judy.viewBorder(border: 0, color: nil)
            }
            
        } else {
            cell.backgroundColor = UIColor(rgbValue: Group.backgroundColorValues[indexPath.row])
            
            if selectedIndexPath == indexPath {
                cell.judy.viewBorder(border: 6, color: .white)
            } else {
                cell.judy.viewBorder(border: 0, color: nil)
            }
        }
        return cell
    }

}


// MARK: - UICollectionViewDelegate
extension AddNewGroupViewCtrl {
    /// 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconCollectionView {
            iconSelectedIndexPath = indexPath
            iconSelectedIndex.onNext(indexPath)
            
        } else {
            selectedIndexPath = indexPath
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AddNewGroupViewCtrl {
    /// 询问 cell 大小，在此函数中计算好对应的 size.
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let lineWidthOfCell = collectionView.frame.height
        return CGSize(width: lineWidthOfCell, height: lineWidthOfCell)
    }
    
}


class AddNewGroupViewModel {
    let groupNameValid: Observable<Bool>
    
    init(groupNameTextField: Observable<String>) {
        groupNameValid = groupNameTextField.map { $0.count >= 1 }
            .share(replay: 1)
    }
}
