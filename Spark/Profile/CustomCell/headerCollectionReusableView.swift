//
//  headerCollectionReusableView.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 17/05/22.
//

import UIKit
import UIView_Shimmer

class headerCollectionReusableView: UICollectionReusableView, ShimmeringViewProtocol {
        
    @IBOutlet weak var headLbl: UILabel!
    
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var socialBtn: UIButton!
    @IBOutlet weak var closedbtn: UIButton!
    
    var globalButtonAction : (() -> ())?
    var localButtonAction : (() -> ())?
    var socialButtonAction : (() -> ())?
    var closedButtonAction : (() -> ())?
    
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        
        resetBtn()
        globalBtn.tintColor = .white
        globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        globalBtn.setTitleColor(.white, for: .normal)
        globalBtn.layer.borderWidth = 0
        globalBtn.layer.cornerRadius = 3
        
        
    }
    
    func resetBtn(){
        globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        localBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        socialBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        closedbtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        
        globalBtn?.layer.masksToBounds = true
        localBtn?.layer.masksToBounds = true
        socialBtn?.layer.masksToBounds = true
        closedbtn?.layer.masksToBounds = true
        
        globalBtn.layer.borderColor = UIColor.lightGray.cgColor
        localBtn.layer.borderColor = UIColor.lightGray.cgColor
        socialBtn.layer.borderColor = UIColor.lightGray.cgColor
        closedbtn.layer.borderColor = UIColor.lightGray.cgColor
        
        globalBtn.layer.borderWidth = 1.0
        localBtn.layer.borderWidth = 1.0
        socialBtn.layer.borderWidth = 1.0
        closedbtn.layer.borderWidth = 1.0
        
        globalBtn.layer.cornerRadius = 3.0
        localBtn.layer.cornerRadius = 3.0
        socialBtn.layer.cornerRadius = 3.0
        closedbtn.layer.cornerRadius = 3.0
        
        globalBtn.tintColor = .lightGray
        localBtn.tintColor = .lightGray
        socialBtn.tintColor = .lightGray
        closedbtn.tintColor = .lightGray
        
        globalBtn.setTitleColor(.lightGray, for: .normal)
        localBtn.setTitleColor(.lightGray, for: .normal)
        socialBtn.setTitleColor(.lightGray, for: .normal)
        closedbtn.setTitleColor(.lightGray, for: .normal)
        
        
        globalBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        localBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        socialBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        closedbtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    }
    
    
    
    /// Set a gradient color to use in background buttons and views
    /// - Parameters:
    ///   - colors: Multiple colors can be declared inside colors
    ///   - locations: From value of 0 - 1 to set the position of colors
    ///   - size: set the coolor for width and height for any of the view
    /// - Returns: It returns the UIColor to set on the view or buttons
    func linearGradientColor(from colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIColor {
        let image = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)).image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locations
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y:size.width),
                options:[]
            )
        }
        return UIColor(patternImage: image)
    }
    
    @IBAction func globalBtnOnPressed(_ sender: Any) {
        globalButtonAction?()
    }
    
    @IBAction func localBtnOnPressed(_ sender: Any) {
        localButtonAction?()
    }
    @IBAction func socialBtnOnPressed(_ sender: Any) {
        socialButtonAction?()
    }
    @IBAction func closedBtnOnPressed(_ sender: Any) {
        closedButtonAction?()
    }
}
