//
//  MMAppFont.swift
//  MuslimMatch
//
//  Created by Melki on 01/01/20.
//  Copyright © 2020 Matrimony.com. All rights reserved.
//

import Foundation
import UIKit

/**
 This is used to set all the type of font size inside all the pages
 */
enum fontSize : CGFloat {
    case verySmall = 10.0,lessSmall = 11.0, small = 12.0, appNormalSize = 13.0, normal = 14.0 , large = 16.0, veryLarge = 18.0, ultraLarge = 20.0
}

extension UIFont {

    class func getMontserratBlack(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Black", size: size.rawValue)!
    }

    class func MontserratBlackItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-BlackItalic", size: size.rawValue)!
    }

    class func MontserratBold(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Bold", size: size.rawValue)!
    }
    
    class func MontserratBoldItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-BoldItalic", size: size.rawValue)!
    }
    
    class func MontserratExtraBold(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-ExtraBold", size: size.rawValue)!
    }
    
    class func MontserratExtraBoldItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-ExtraBoldItalic", size: size.rawValue)!
    }
    
    class func MontserratExtraLight(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-ExtraLight", size: size.rawValue)!
    }
    
    class func MontserratItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Italic", size: size.rawValue)!
    }
    
    class func MontserratLight(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Light", size: size.rawValue)!
    }
    
    class func MontserratLightItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-LightItalic", size: size.rawValue)!
    }
    
    class func MontserratMedium(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Medium", size: size.rawValue)!
    }
    
    class func MontserratMediumItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-MediumItalic", size: size.rawValue)!
    }
    
    class func MontserratRegular(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Regular", size: size.rawValue)!
    }
    
    class func MontserratSemiBold(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-SemiBold", size: size.rawValue)!
    }
    
    class func MontserratSemiBoldItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-SemiBoldItalic", size: size.rawValue)!
    }
    
    class func MontserratThin(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-Thind", size: size.rawValue)!
    }
    
    class func MontserratThinItalic(_ size : fontSize) -> UIFont
    {
        return UIFont(name: "Montserrat-ThinItalic", size: size.rawValue)!
    }
    

}
