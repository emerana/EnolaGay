//
//  ViewController.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

//import SnapKit
import EnolaGay

class MandolineViewController: UIViewController, PickerViewDataSource {

    var selectableCells: [Selectable] = ScrollableCellViewModel.list()

    @IBOutlet weak var pickerView: PickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // pickerView.select(at: 2)
    }

}

extension MandolineViewController: PickerViewDelegate {
    
    func registerCell(for collectionView: UICollectionView) -> String {
        collectionView.register(ScrollableCell.self, forCellWithReuseIdentifier: "DayCell")
        return "DayCell"
    }

    func pickerView(_ pickerView: PickerView, widthForItemAt index: Int) -> CGFloat { 128 }

    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let datedCell = cell as? ScrollableCell else { return }
        datedCell.viewModel = selectableCells[indexPath.row] as? ScrollableCellViewModel
    }
    
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int) {
        Judy.log("选中了\(index)")
    }
    
}
