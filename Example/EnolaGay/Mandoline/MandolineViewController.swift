//
//  ViewController.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import EnolaGay

class MandolineViewController: UIViewController {

    @IBOutlet weak var pickerView: PickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectedItemOverlay.triangleView.color = .yellow

        pickerView.selectedItemOverlay.layer.borderWidth = 1
        pickerView.selectedItemOverlay.layer.borderColor = UIColor.cyan.cgColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         pickerView.select(at: 3)
    }

}

extension MandolineViewController: PickerViewDataSource, PickerViewDelegate {
    func titles(for pickerView: PickerView) -> [String] {
        return ["上传视频", "快拍", "长拍", "开直播"]
    }
    func width(for pickerView: PickerView) -> CGFloat { 60 }
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int) {
        Judy.log("选中了\(index)")
    }
}
