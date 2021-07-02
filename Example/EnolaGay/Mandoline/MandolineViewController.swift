//
//  ViewController.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import SnapKit
import EnolaGay

class MandolineViewController: UIViewController, PickerViewDataSource {
    
    var selectableCells: [Selectable] = ScrollableCellViewModel.list()

    @IBOutlet weak var pickerView: PickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //        pickerView.register(cellType: ScrollableCell.self)
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let randomIndexPath = IndexPath(row: Int(arc4random_uniform(UInt32(selectableCells.count))),section: 0)
//        pickerView.scrollToCell(at: randomIndexPath)
//        pickerView.scrollToCell(at: IndexPath(row: 0, section: 0))

    }

}

extension MandolineViewController: PickerViewDelegate {
    
    func registerCell(for collectionView: UICollectionView) -> String {
        collectionView.register(ScrollableCell.self, forCellWithReuseIdentifier: "DayCell")
        return "DayCell"
    }

    
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let datedCell = cell as? ScrollableCell else { return }
        datedCell.viewModel = selectableCells[indexPath.row] as? ScrollableCellViewModel
    }
    
    
    func collectionView(_ view: PickerView, didSelectItemAt indexPath: IndexPath) {
//        Judy.log("滚动到:\(indexPath)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        Judy.log("scrollViewDidScroll")
    }
}
