//
//  UITextField + Extensions.swift
//  Spark
//
//  Created by Gowthaman P on 25/06/21.
//

import Foundation
import UIKit

extension UITextField {
  func useUnderline() -> Void {
    let border = CALayer()
    let borderWidth = CGFloat(1.0) // Border Width
    border.borderColor = UIColor.TextFieldBottomBorderColor.cgColor
    border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
    border.borderWidth = borderWidth
    self.layer.addSublayer(border)
    self.layer.masksToBounds = true
  }
}

extension UITextField {

    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }

    func addPadding(_ padding: PaddingSide) {

        self.leftViewMode = .always
        self.layer.masksToBounds = true


        switch padding {

        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always

        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always

        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}
extension UITextField {

enum Direction {
    case Left
    case Right
}

// add image to textfield
func withImage(direction: Direction, image: UIImage){
    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))

    let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    view.backgroundColor = #colorLiteral(red: 0.9491456151, green: 0.9487512708, blue: 0.9661383033, alpha: 1)
    view.clipsToBounds = true
    mainView.addSubview(view)

    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 0, y: 4, width: 20.0, height: 20.0)
    view.addSubview(imageView)

    if(Direction.Left == direction){ // image left
        self.leftViewMode = .always
        self.leftView = mainView
    } else { // image right
        self.rightViewMode = .always
        self.rightView = mainView
    }

}

}

extension UITextView {
    func centerText() {
        self.textAlignment = .center
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            view.addSubview(imageView)
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = view
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
}
