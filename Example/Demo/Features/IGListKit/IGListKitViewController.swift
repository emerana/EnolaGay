//
//  IGListKitViewController.swift
//  emerana
//
//  Created by 王仁洁 on 2019/12/19.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import IGListKit

/// IGListKit 使用样例。
class IGListKitViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    let loader = ContentLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.loadLatest()

        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.collectionView?.alwaysBounceVertical = true

        adapter.collectionView?.layoutIfNeeded()
    }
    
}


// MARK: - ListAdapterDataSource

extension IGListKitViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return loader.entries
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
         let sectionCtrl = SectionController()

        return sectionCtrl
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
}

