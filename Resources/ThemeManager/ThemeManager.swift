//
//  ThemeManager.swift
//  Life Hope
//
//  Created by Gowthaman P on 27/10/20.
//

import UIKit

/**
 This class is a singleton class to save the theme manager with uicolor
 */
class ThemeManager: NSObject {
    
    static let sharedInstance = ThemeManager()

}

extension UIColor {
    
    static var profileStartColor : UIColor {
        return UIColor.init(red: 61.0/255.0, green: 61.0/255.0, blue: 109/255.0, alpha: 1.0)
        }
    
    static var profileEndColor : UIColor {
        return UIColor.init(red: 53.0/255.0, green: 131.0/255.0, blue: 131.0/255.0, alpha: 1.0)
        }

    static var splashStartColor : UIColor {
        return UIColor.init(red: 61.0/255.0, green: 64.0/255.0, blue: 110.0/255.0, alpha: 1.0)
        }
    
    static var splashEndColor : UIColor {
        return UIColor.init(red: 54.0/255.0, green: 133.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        }
    
    static var TextFieldBottomBorderColor: UIColor {
        return UIColor(red: 152.0/255.0, green: 150.0/255.0, blue: 154.0/255.0, alpha: 1)
    }
    
    static var TextFieldPlaceholderColor: UIColor {
        return UIColor(red: 137.0/255.0, green: 135.0/255.0, blue: 139.0/255.0, alpha: 1)
    }
    
    static var CellPlaceholderColor: UIColor {
        return UIColor(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1)
    }
    static var defaultTintColor: UIColor {
        return UIColor(red: 80.0/255.0, green: 177.0/255.0, blue: 237.0/255.0, alpha: 1)
    }
    
    static var termsAndCondtionColor : UIColor {
            return UIColor.init(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        }
   
    static var setAppTitleColor : UIColor {
            return UIColor.init(red: 17.0/255.0, green: 20.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        }
    
    static var gradientColor1 : UIColor {
            return UIColor.init(red: 102.0/255.0, green: 45.0/255.0, blue: 145.0/255.0, alpha: 1.0)
        }
    
    static var gradientColor2 : UIColor {
            return UIColor.init(red: 237.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1.0)
        }
    
    static var navigationTitleColor : UIColor {
            return UIColor.init(red: 59.0/255.0, green: 66.0/255.0, blue: 109.0/255.0, alpha: 1.0)
        }
    
    //Post
    static var categorySelectiobBgColor : UIColor {
        return UIColor.init(red: 43.0/255.0, green: 36.0/255.0, blue: 103.0/255.0, alpha: 0.5)
        }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
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

}

