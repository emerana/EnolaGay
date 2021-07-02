//
//  PickerViewModel.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import Foundation
import EnolaGay

class PickerViewModel {
    var cells: [Selectable]

    var selectedCell: Selectable? {
        didSet {
//            guard let model = selectedCell as? ScrollableCellViewModel else { return }
//            Judy.log("selectedCell 被改变了：\(model.title)")
        }
    }

    func select(cell: Selectable) {
        selectedCell = cell
    }

    init(cells: [Selectable]) {
        self.cells = cells
    }
}

