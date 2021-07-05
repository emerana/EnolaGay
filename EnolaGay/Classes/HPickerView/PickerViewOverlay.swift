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
            triangleView.frame = rect
            triangleView.frameToFill = rect
        }
    }

    override init(frame: CGRect) {
        view = UIView(frame: .zero)
        super.init(frame: frame)
        setupSubviews()
    }

    func setupSubviews() {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraint(
            NSLayoutConstraint(item: view, attribute: .left,
                               relatedBy: .equal, toItem: self,
                               attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: view, attribute: .right,
                               relatedBy: .equal, toItem: self,
                               attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: view, attribute: .top,
                               relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: view, attribute: .bottom,
                               relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0))

//        view.layer.borderWidth = mandoBorderWidth
//        view.layer.borderColor = maindoBorderColor.cgColor

        addSubview(triangleView)
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(
            NSLayoutConstraint(item: triangleView, attribute: .top,
                               relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: triangleView, attribute: .centerX,
                               relatedBy: .equal, toItem: self,
                               attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: triangleView, attribute: .height,
                               relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: triangleSize.height))
        self.addConstraint(
            NSLayoutConstraint(item: triangleView, attribute: .width,
                               relatedBy: .equal, toItem: nil,
                               attribute: .width, multiplier: 1, constant: triangleSize.width))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// This is the downward pointing arrow in the OverlayView
/// OverlayView 中的向下箭头。
class PickerViewOverlayTriangleView: UIView {

    // We have to override the init just because we need to set isOpaque to false
    // 我们必须重写 init，因为我们需要将 isOpaque 设为 false.
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
    
    // 重写此函数来画三角形。
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
