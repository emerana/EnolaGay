//
//  ViewController.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import SnapKit

class MandolineViewController: UIViewController, PickerViewDataSource {
    var selectableCells: [Selectable] = ScrollableCellViewModel.list()

    @IBOutlet weak var pickerView: PickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.register(cellType: ScrollableCell.self)
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let randomIndexPath = IndexPath(row: Int(arc4random_uniform(UInt32(selectableCells.count))),section: 0)
        pickerView.scrollToCell(at: randomIndexPath)
    }

}

extension MandolineViewController: PickerViewDelegate {
    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let datedCell = cell as? ScrollableCell else { return }
        datedCell.viewModel = selectableCells[indexPath.row] as? ScrollableCellViewModel
    }
}
