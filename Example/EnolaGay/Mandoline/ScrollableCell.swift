//
//  ScrollableCell.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import SnapKit

class ScrollableCell: UICollectionViewCell {

    let titleLabel = UILabel()

    var viewModel: ScrollableCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.text = viewModel.title
        }
    }
//    static let cellSize = CGSize(width: 68, height: 28)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.borderWidth = 1.0

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
//            make.top.bottom.equalTo(8)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ScrollableCellViewModel: Selectable {

    let threeLetterWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE"
        return formatter
    }()

    let singleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "d"
        return formatter
    }()

    var date: Date? {
        didSet {
            guard let date = date else { return }
            dateLabelText = singleDateFormatter.string(from: date)
            dayLabelText = threeLetterWeekdayFormatter.string(from: date)
        }
    }

    var dayLabelText: String?
    
    var title: String?

    var dateLabelText: String?

    var isSelectable: Bool

    init(isSelectable: Bool) {
        self.isSelectable = isSelectable
    }

}

extension ScrollableCellViewModel {
    
    static func dummyCells() -> [ScrollableCellViewModel] {
        let today = Date()
        return (0...10).map { index in
            let cellVM = ScrollableCellViewModel(isSelectable: arc4random_uniform(2) == 1)
            cellVM.date = Calendar.current.date(byAdding: .day, value: index, to: today)
            return cellVM
        }
    }
    
    static func list() -> [ScrollableCellViewModel] {
        let list = ["浙江温州", "江南皮革厂", "哈哈哈", "倒闭了"]
        
        return list.map { string in
            let rs = ScrollableCellViewModel(isSelectable: true)
            rs.title = string
            return rs
        }
    }
}

