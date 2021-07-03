//
//  PickerViewOverlay.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import UIKit

/// 覆盖层。
class PickerViewOverlay: UIView {

    let view: UIView

    /// 三角形。
    let triangleView = PickerViewOverlayTriangleView()

    // Computed Properties
    var triangleSize = CGSize(width: 10, height: 5) {
        didSet {
            let rect = CGRect(origin: .zero, size: triangleSize)
            triangleView.snp.updateConstraints { make in
                make.size.equalTo(triangleSize)
            }
            triangleView.frameToFill = rect
        }
    }

    var maindoBorderColor = UIColor.green {
        didSet {
            view.layer.borderColor = maindoBorderColor.cgColor
            triangleView.color = maindoBorderColor
        }
    }

    var mandoBorderWidth: CGFloat = 2.0 {
        didSet {
            view.layer.borderWidth = mandoBorderWidth
        }
    }

    override init(frame: CGRect) {
        view = UIView(frame: .zero)
        super.init(frame: frame)
        setupSubviews()
    }

    func setupSubviews() {
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        view.layer.borderWidth = mandoBorderWidth
        view.layer.borderColor = maindoBorderColor.cgColor

        addSubview(triangleView)
        triangleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(triangleSize)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// This is the downward pointing arrow in the OverlayView
class PickerViewOverlayTriangleView: UIView {

    // We have to override the init just because we need to set isOpaque to false
    override init(frame: CGRect) {
        super.init(frame: .zero)
        isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var color = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    var frameToFill: CGRect? {
        didSet {
            setNeedsLayout()
        }
    }

    override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        let frame = frameToFill ?? layer.frame
        UIBezierPath(rect: frame).fill()
        color.setFill()

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: frame.width, y: 0))
        bezierPath.addLine(to: CGPoint(x: frame.width / 2, y: frame.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
        bezierPath.fill()
    }
}
