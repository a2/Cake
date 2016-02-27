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

public protocol CakeViewAccessibilityDataSource: CakeViewDataSource {
    func cakeView(cakeView: CakeView, accessibilityLabelForSegmentAtIndex index: Int) -> String?
    func cakeView(cakeView: CakeView, accessibilityValueForSegmentAtIndex index: Int) -> String?
}

public let CakeViewWillSelectSegmentNotification = "CakeViewWillSelectSegmentNotification"
public let CakeViewDidSelectSegmentNotification = "CakeViewDidSelectSegmentNotification"

public let CakeViewNewSegmentIndexUserInfoKey = "newSegmentIndex"
public let CakeViewOldSegmentIndexUserInfoKey = "oldSegmentIndex"

public let CakeViewNoSegment = -1

@IBDesignable
public class CakeView: UIView {
    public weak var dataSource: CakeViewDataSource? {
        didSet {
            reloadData()
        }
    }

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

    public var selectedSegmentIndex: Int = CakeViewNoSegment {
        willSet {
            if selectedSegmentIndex == newValue {
                return
            }

            NSNotificationCenter.defaultCenter().postNotificationName(CakeViewWillSelectSegmentNotification, object: self, userInfo: [CakeViewNewSegmentIndexUserInfoKey: newValue, CakeViewOldSegmentIndexUserInfoKey: selectedSegmentIndex])
        }
        didSet {
            if oldValue == selectedSegmentIndex {
                return
            }

            NSNotificationCenter.defaultCenter().postNotificationName(CakeViewDidSelectSegmentNotification, object: self, userInfo: [CakeViewNewSegmentIndexUserInfoKey: selectedSegmentIndex, CakeViewOldSegmentIndexUserInfoKey: oldValue])

            let newValue = selectedSegmentIndex
            UIView.animateWithDuration(0.3, delay: 0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
                if oldValue != CakeViewNoSegment {
                    self.segments[oldValue].transform = CGAffineTransformIdentity
                }

                if newValue != CakeViewNoSegment {
                    let range = self.angleRangeForSegment(atIndex: newValue)
                    let angle = (range.start + range.end) / 2 + M_PI / 2
                    self.segments[newValue].transform = CGAffineTransformMakeTranslation(-self.selectedSegmentDistance * cos(CGFloat(angle)), -self.selectedSegmentDistance * sin(CGFloat(angle)))
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
            insertSubview(segment, atIndex: 0)

            if let accessibilityDataSource = dataSource as? CakeViewAccessibilityDataSource {
                segment.accessibilityLabel = accessibilityDataSource.cakeView(self, accessibilityLabelForSegmentAtIndex: i)
                segment.accessibilityValue = accessibilityDataSource.cakeView(self, accessibilityValueForSegmentAtIndex: i)
            }
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
                selectedSegmentIndex = CakeViewNoSegment
            }
        } else if selectedSegmentIndex != CakeViewNoSegment {
            selectedSegmentIndex = CakeViewNoSegment
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
