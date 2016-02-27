//
//  UIBezierPath+Segment.swift
//  Cake
//
//  Created by Alexsander Akers on 2/26/2016.
//  Copyright (c) 2016 Alexsander Akers. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(startPercent: CGFloat, endPercent: CGFloat, innerRadius: CGFloat, outerRadius: CGFloat) {
        self.init()

        let pi = CGFloat(M_PI)
        let startAngle = 2 * pi * startPercent - pi / 2
        let endAngle = 2 * pi * endPercent - pi / 2

        let center = CGPoint(x: outerRadius, y: outerRadius)
        self.addArcWithCenter(center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.addArcWithCenter(center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        self.closePath()
    }
}
