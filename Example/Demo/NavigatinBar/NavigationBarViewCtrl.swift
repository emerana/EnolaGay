//
//  NavigationBarViewCtrl.swift
//  Demo
//
//  Created by EnolaGay on 2023/8/10.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay
import IGListKit

/// 导航条功能根界面
class NavigationBarViewCtrl: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    let loader = NavigationBarDataSourceLoader()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "导航条功能验证"

        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.collectionView?.alwaysBounceVertical = true

        adapter.collectionView?.layoutIfNeeded()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - ListAdapterDataSource

extension NavigationBarViewCtrl: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return loader.entries
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
         let sectionCtrl = NavigationBarSectionCtrl()

        return sectionCtrl
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

