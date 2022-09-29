//
//  Spotlight.swift
//  Spotlight
//
//  Created by Lekshmi Raveendranathapanicker on 2/5/18.
//  Copyright © 2018 Lekshmi Raveendranathapanicker. All rights reserved.
//

import Foundation
import UIKit

public protocol SpotlightDelegate: AnyObject {
    func didAdvance(to node: Int, of total: Int)
    func didDismiss()
}

public final class Spotlight {
    public static var delay: TimeInterval = 5.0
    public static var animationDuration: TimeInterval = 0.25
    public static var alpha: CGFloat = 0.7
    public static var backgroundColor: UIColor = .darkGray
    public static var textColor: UIColor = .white
    public static var font: UIFont = UIFont(name: "Montserrat-Medium", size: 18)!
    public static var showInfoBackground: Bool = true
    public static var infoBackgroundEffect: UIBlurEffect.Style = .dark
    public static var backButtonTitle = ""
    public static var nextButtonTitle = ""
    public static var spotLightImage = ""

    public weak var delegate: SpotlightDelegate?

    public init() {}

    public func startIntro(from controller: UIViewController, withNodes nodes: [SpotlightNode]) {
        guard !nodes.isEmpty else { return }
        spotlightVC.spotlightNodes = nodes
        spotlightVC.delegate = delegate
        controller.present(spotlightVC, animated: true, completion: nil)
    }

    private let spotlightVC = SpotlightViewController()
}
