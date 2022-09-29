//
//  CGFloat + extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 30/11/20.
//

import CoreGraphics.CGGeometry

extension CGFloat {
    ///Show the degress of doubke value
    static func degrees(_ degree: Double)->Self {
        return Self(degree * .pi / 180)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
