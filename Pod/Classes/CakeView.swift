//
//  CakeView.swift
//  Cake
//
//  Created by Alexsander Akers on 2/26/2016.
//  Copyright (c) 2016 Alexsander Akers. All rights reserved.
//

import UIKit

public protocol CakeViewDataSource: class {
    func numberOfSegmentsInCakeView(cakeView: CakeView) -> Int
    func cakeView(cakeView: CakeView, valueForSegmentAtIndex index: Int) -> Double
    func cakeView(cakeView: CakeView, fillColorForSegmentAtIndex index: Int) -> UIColor
}

public protocol CakeViewDelegate: class {
    func cakeView(cakeView: CakeView, willDeselectSegmentAtIndex index: Int)
    func cakeView(cakeView: CakeView, didDeselectSegmentAtIndex index: Int)

    func cakeView(cakeView: CakeView, willSelectSegmentAtIndex index: Int)
    func cakeView(cakeView: CakeView, didSelectSegmentAtIndex index: Int)
}

class CakeSegmentView: UIView {
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }

    var shapeLayer: CAShapeLayer {
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

@IBDesignable
public class CakeView: UIView {
    public weak var dataSource: CakeViewDataSource? {
        didSet {
            reloadData()
        }
    }
    public weak var delegate: CakeViewDelegate?

    var segments = [CakeSegmentView]()
    var segmentValues = [Double]()
    var segmentPool = Set<CakeSegmentView>()
    var totalValue: Double = 0

    @IBInspectable public var segmentRadius: CGFloat = 70 {
        didSet {
            reloadUI()
        }
    }

    @IBInspectable public var segmentWidth: CGFloat = 30 {
        didSet {
            reloadUI()
        }
    }

    var circleInnerRadius: CGFloat {
        return segmentRadius
    }

    var circleOuterRadius: CGFloat {
        return segmentRadius + segmentWidth
    }

    @IBInspectable public var selectedSegmentDistance: CGFloat = 10

    public var selectedSegmentIndex: Int? {
        willSet {
            if selectedSegmentIndex == newValue {
                return
            }

            if let newValue = newValue {
                delegate?.cakeView(self, willSelectSegmentAtIndex: newValue)
            }

            if let index = selectedSegmentIndex {
                delegate?.cakeView(self, willDeselectSegmentAtIndex: index)
            }
        }
        didSet {
            if oldValue == selectedSegmentIndex {
                return
            }

            if let index = selectedSegmentIndex {
                delegate?.cakeView(self, didDeselectSegmentAtIndex: index)
            }

            let newValue = selectedSegmentIndex
            if let newValue = newValue {
                delegate?.cakeView(self, didSelectSegmentAtIndex: newValue)
            }

            UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
                if let oldValue = oldValue {
                    self.segments[oldValue].transform = CGAffineTransformIdentity
                }

                if let index = newValue {
                    let range = self.angleRangeForSegment(atIndex: index)
                    let angle = (range.start + range.end) / 2 + M_PI / 2
                    self.segments[index].transform = CGAffineTransformMakeTranslation(-self.selectedSegmentDistance * cos(CGFloat(angle)), -self.selectedSegmentDistance * sin(CGFloat(angle)))
                }
            }, completion: nil)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        let tap = UITapGestureRecognizer(target: self, action: "tapped:")
        addGestureRecognizer(tap)

        isAccessibilityElement = false
    }

    func reloadUI() {
        segmentPool.unionInPlace(segments)
        segments.forEach { $0.removeFromSuperview() }
        segments.removeAll()

        let frame = CGRect(
            x: bounds.width / 2 - circleOuterRadius,
            y: bounds.height / 2 - circleOuterRadius,
            width: 2 * circleOuterRadius,
            height: 2 * circleOuterRadius
        )

        for i in segmentValues.indices {
            let startPercent = CGFloat(segmentValues[0..<i].reduce(0, combine: +) / totalValue)
            let endPercent = startPercent + CGFloat(segmentValues[i] / totalValue)
            let segment = segmentPool.popFirst() ?? CakeSegmentView()
            segments.append(segment)

            let bezierPath = UIBezierPath(startPercent: startPercent, endPercent: endPercent, innerRadius: circleInnerRadius, outerRadius: circleOuterRadius)
            segment.bezierPath = bezierPath
            segment.fillColor = dataSource?.cakeView(self, fillColorForSegmentAtIndex: i) ?? .blackColor()
            segment.frame = frame
            segment.isAccessibilityElement = true
            addSubview(segment)
        }
    }

    func angleRangeForSegment(atIndex i: Int) -> ClosedInterval<Double> {
        precondition(segmentValues.indices.contains(i))

        let startAngle = 2 * M_PI * segmentValues[0..<i].reduce(0, combine: +) / totalValue
        let endAngle = startAngle + 2 * M_PI * segmentValues[i] / totalValue
        return startAngle...endAngle
    }

    func indexOfSegment(atPoint point: CGPoint) -> Int? {
        return segments.indexOf { segment in
            let relativePoint = convertPoint(point, toView: segment)
            return segment.bezierPath.containsPoint(relativePoint)
        }
    }

    func tapped(gesture: UITapGestureRecognizer) {
        let position = gesture.locationInView(self)
        if let index = indexOfSegment(atPoint: position) {
            if selectedSegmentIndex != index {
                selectedSegmentIndex = index
            } else {
                selectedSegmentIndex = nil
            }
        } else if selectedSegmentIndex != nil {
            selectedSegmentIndex = nil
        }
    }

    public func reloadData() {
        let numberOfSegments = dataSource?.numberOfSegmentsInCakeView(self) ?? 0
        segmentValues = (0..<numberOfSegments).map { i in dataSource?.cakeView(self, valueForSegmentAtIndex: i) ?? 0 }
        totalValue = segmentValues.reduce(0, combine: +)

        reloadUI()
    }

    public override var bounds: CGRect {
        didSet {
            reloadUI()
        }
    }

    public override var frame: CGRect {
        didSet {
            reloadUI()
        }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        dataSource = CakeViewSampleDataSource.sharedInstance
    }
}
