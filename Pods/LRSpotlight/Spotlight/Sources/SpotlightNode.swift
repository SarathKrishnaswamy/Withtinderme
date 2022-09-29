//
//  SpotlightNode.swift
//  Spotlight
//
//  Created by Lekshmi Raveendranathapanicker on 2/5/18.
//  Copyright © 2018 Lekshmi Raveendranathapanicker. All rights reserved.
//

import Foundation
import UIKit

public struct SpotlightNode {
    var text: String
    var target: SpotlightTarget
    var roundedCorners: Bool
    var imageName : String

    public init(text: String, target: SpotlightTarget, roundedCorners: Bool = true, imageName: String) {
        self.text = text
        self.target = target
        self.roundedCorners = roundedCorners
        self.imageName = imageName
    }
}
