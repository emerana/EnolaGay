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
    
    func titles(for pickerView: PickerView) -> [String] {
        return ["浙江温州", "江南皮革厂", "哈哈哈", "倒闭了"]
    }

    func pickerView(_ pickerView: PickerView, widthForItemAt index: Int) -> CGFloat { 128 }

    func reload(cell: UICollectionViewCell, for index: Int, with source: [String]) {
        // guard let datedCell = cell as? ScrollableCell else { return }
    }
    
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int) {
//        Judy.log("选中了\(index)")
    }
    
}
