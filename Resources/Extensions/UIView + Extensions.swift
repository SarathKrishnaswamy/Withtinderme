//
//  UIView + Extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 24/11/20.
//

import UIKit
import AVKit

/**
 This class is used to set the bordercolor view borderwidth and corener radius
 */
extension UIView {
    
    @IBInspectable var borderColorView:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidthView:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    func makeCircle(){
        layer.cornerRadius = max(frame.height, frame.width) / 2
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow() {
        dropShadow(color: .black, opacity: 0.16, offSet: .init(width: 0, height: 4), radius: 8)
    }
    
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle(for: Self.self))
    }
    
    static func instantiateFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
}

extension UIApplication {
    class var topViewController: UIViewController? { return getTopViewController() }
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }

    private class func _share(_ data: [Any],
                              applicationActivities: [UIActivity]?,
                              setupViewControllerCompletion: ((UIActivityViewController) -> Void)?) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        setupViewControllerCompletion?(activityViewController)
        UIApplication.topViewController?.present(activityViewController, animated: true, completion: nil)
    }

    class func share(_ data: Any...,
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
    class func share(_ data: [Any],
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
}
extension UIView {

    func addShadowView(width:CGFloat=0.2, height:CGFloat=0.2, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=0.5){
        self.layer.shadowColor = UIColor.gray.cgColor
         self.layer.shadowOffset = CGSize(width: width, height: height)
         self.layer.shadowRadius = radius
         self.layer.shadowOpacity = Opacidade
         self.layer.masksToBounds = maskToBounds
    }

}

extension AVPlayer {
    func addProgressObserver(action:@escaping ((Double) -> Void)) -> Any {
        return self.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { time in
            if let duration = self.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                let progress = (time/duration)
                action(progress)
            }
        })
    }
}

extension UILabel {

    func setTextWithShadow(_ string: String) {

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 3, height: 3)
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)

        let attributes = [ NSAttributedString.Key.shadow: shadow ]
        let attributedString = NSAttributedString(string: string, attributes: attributes)

        self.attributedText = attributedString
    }

}
