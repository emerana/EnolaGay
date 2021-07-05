//
//  PickerViewOverlay.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import UIKit

/// 覆盖层。
public class PickerViewOverlay: UIView {
    
    /// 三角形所在位置上或下。
    public enum TriangleLocation {
        case up
        case down
    }
    
    /// 三角形方向。
    public var triangleViewLocation = TriangleLocation.up {
        didSet {
            updateConstraints()
            triangleView.triangleLocation = triangleViewLocation
        }
    }

    /// 三角形。
    public let triangleView = PickerViewOverlayTriangleView()
    
    // Computed Properties
    public var triangleSize = CGSize(width: 10, height: 5) {
        didSet {
            let rect = CGRect(origin: .zero, size: triangleSize)
            triangleView.frame = rect
            triangleView.frameToFill = rect
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    private func setupSubviews() {
        addSubview(triangleView)
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    public override func updateConstraints() {
        if triangleViewLocation == .up {
            // 在顶部。
            self.addConstraint(
                NSLayoutConstraint(item: triangleView, attribute: .top,
                                   relatedBy: .equal, toItem: self,
                                   attribute: .top, multiplier: 1, constant: 0))
        } else {
            // 在底部。
            self.addConstraint(
                NSLayoutConstraint(item: triangleView, attribute: .bottom,
                                   relatedBy: .equal, toItem: self,
                                   attribute: .bottom, multiplier: 1, constant: 0))
        }
        
        super.updateConstraints()
    }
}

// This is the downward pointing arrow in the OverlayView
/// OverlayView 中的向下箭头。
public class PickerViewOverlayTriangleView: UIView {
    
    var triangleLocation = PickerViewOverlay.TriangleLocation.up {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // We have to override the init just because we need to set isOpaque to false
    // 我们必须重写 init，因为我们需要将 isOpaque 设为 false.
    override init(frame: CGRect) {
        super.init(frame: .zero)
        isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var color = UIColor.blue {
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
    public override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        let frame = frameToFill ?? layer.frame
        UIBezierPath(rect: frame).fill()
        color.setFill()
        let bezierPath = UIBezierPath()
        // 画三角形。
        if triangleLocation == .up {
            downwardTriangleView(bezierPath: bezierPath)
        } else {
            upwardTriangleView(bezierPath: bezierPath)
        }
        bezierPath.close()
        bezierPath.fill()
    }
    
    /// 画向下的箭头。
    private func downwardTriangleView(bezierPath: UIBezierPath) {
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: frame.width, y: 0))
        bezierPath.addLine(to: CGPoint(x: frame.width / 2, y: frame.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
    }
    
    /// 画向上的箭头。
    private func upwardTriangleView(bezierPath: UIBezierPath) {
        bezierPath.move(to: CGPoint(x: frame.width / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.width / 2, y: 0))
    }

}
