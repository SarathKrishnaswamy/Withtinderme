//
//  UIImage + Extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 03/12/20.
//

import UIKit

extension UIImage {
    static func createSelectionIndicator(color: UIColor, size: CGSize, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x:0, y:size.height - lineWidth, width:size.width, height:lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension UIImage {
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// Returns a image that fills in newSize
    
    func resizedImage(newSize: CGSize) -> UIImage {
        
        // Guard newSize is different
        
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
        
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    
    /// Note that the new image size is not rectSize, but within it.
    
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        
        let widthFactor = size.width / rectSize.width
        
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        
        if size.height > size.width {
            
            resizeFactor = heightFactor
            
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        
        let resized = resizedImage(newSize: newSize)
        
        return resized
        
    }
}

extension UIImage {

    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }

    func getSizeIn(_ type: DataUnits)-> String {

        guard let data = self.pngData() else {
            return ""
        }

        var size: Double = 0.0

        switch type {
        case .byte:
            size = Double(data.count)
        case .kilobyte:
            size = Double(data.count) / 1024
        case .megabyte:
            size = Double(data.count) / 1024 / 1024
        case .gigabyte:
            size = Double(data.count) / 1024 / 1024 / 1024
        }

        return String(format: "%.2f", size)
    }
}

