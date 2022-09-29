//
//  Dictionary + Extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 08/12/20.
//

import Foundation

/// Dictionary value will be equated
extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
