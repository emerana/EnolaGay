//
//  ViewController.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

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
        
         pickerView.select(at: 3)
    }

}

extension MandolineViewController: PickerViewDelegate {
    
    func titles(for pickerView: PickerView) -> [String] {
        return ["上传视频", "快拍", "长拍", "开直播"]
    }

    func reload(cell: UICollectionViewCell, for index: Int, with source: [String]) {
        // guard let datedCell = cell as? ScrollableCell else { return }
    }
    
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int) {
//        Judy.log("选中了\(index)")
    }
    
}
