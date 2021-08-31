//
//  VersionCheckViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/8/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class VersionCheckViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "版本查询" }

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak private var bundleIDTextField: JudyAkiraTextField!
    @IBOutlet weak private var versionTextField: JudyAkiraTextField!
    @IBOutlet weak private var infoLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bundleIDTextField.text = Judy.bundleIdentifier
        versionTextField.text = Judy.versionShort
        infoLabel.text = ""
    }
    
    @IBAction private func checkAction(_ sender: Any) {
        infoLabel.text = "查询中……"
        view.endEditing(true)

        let bundleID = bundleIDTextField.text ?? Judy.bundleIdentifier
        let version = versionTextField.text ?? Judy.versionShort

        Judy.queryVersionInfoAtAppStore(bundleIdentifier: bundleID,
                                        version: version) { [weak self] (versionStatus, AppStoreURL) in
            var infoString = "查询结果：\n"
            infoString += "Bundle ID: \(bundleID)\n"
            infoString += "Version: \(version)\n"
            infoString += versionStatus.rawValue

            DispatchQueue.main.async {
                self?.infoLabel.text = infoString
                self?.infoLabel.judy.setHighlighted(text: "查询结果", color: .darkText, font: UIFont(name: FontName.HlvtcNeue, size: 16))
                self?.infoLabel.judy.setHighlighted(text: "Bundle ID:", color: .darkText, font: UIFont(name: FontName.HlvtcNeue, size: 16))
                self?.infoLabel.judy.setHighlighted(text: "Version:", color: .darkText, font: UIFont(name: FontName.HlvtcNeue, size: 16))

            }
        }
    }

}
