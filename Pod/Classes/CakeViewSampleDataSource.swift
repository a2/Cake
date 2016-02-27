//
//  CakeViewSampleDataSource.swift
//  Cake
//
//  Created by Alexsander Akers on 2/27/2016.
//  Copyright (c) 2016 Alexsander Akers. All rights reserved.
//

import UIKit

public class CakeViewSampleDataSource: CakeViewDataSource {
    public static let sharedInstance = CakeViewSampleDataSource()

    public func numberOfSegmentsInCakeView(cakeView: CakeView) -> Int {
        return 5
    }

    public func cakeView(cakeView: CakeView, fillColorForSegmentAtIndex index: Int) -> UIColor {
        let colors: [(Int, Int, Int)] = [
            (56, 138, 226),
            (251, 99, 90),
            (48, 232, 190),
            (252, 201, 35),
            (128, 143, 158),
        ]

        let (r, g, b) = colors[index]
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }

    public func cakeView(cakeView: CakeView, valueForSegmentAtIndex index: Int) -> Double {
        let segments = [
            158.085133673,
            83.165776024,
            50.952568835,
            37.8828754765,
            29.9136459915,
        ]

        return segments[index]
    }
}
