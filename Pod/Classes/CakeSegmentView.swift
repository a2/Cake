//
//  CakeSegmentView.swift
//  Cake
//
//  Created by Alexsander Akers on 2/26/2016.
//  Copyright (c) 2016 Alexsander Akers. All rights reserved.
//

import UIKit

class CakeSegmentView: UIView {
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    var bezierPath: UIBezierPath {
        get {
            return shapeLayer.path.map(UIBezierPath.init) ?? UIBezierPath()
        }
        set {
            shapeLayer.path = newValue.CGPath
        }
    }

    var fillColor: UIColor {
        get {
            return shapeLayer.fillColor.map(UIColor.init) ?? .blackColor()
        }
        set {
            shapeLayer.fillColor = newValue.CGColor
        }
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return bezierPath.containsPoint(point)
    }

    override var accessibilityPath: UIBezierPath? {
        get {
            return UIAccessibilityConvertPathToScreenCoordinates(bezierPath, self)
        }
        set {}
    }
}
