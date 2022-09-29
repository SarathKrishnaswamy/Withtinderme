//
//  SearchBar.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 27/05/22.
//

import Foundation
import UIKit
class SearchBar: UISearchBar {

    private enum SubviewKey: String {
        case searchField, clearButton, cancelButton,  placeholderLabel
    }

    // Button/Icon images
    public var clearButtonImage: UIImage?
    public var resultsButtonImage: UIImage?
    public var searchImage: UIImage?

    // Button/Icon colors
    public var searchIconColor: UIColor?
    public var clearButtonColor: UIColor?
    public var cancelButtonColor: UIColor?
    public var capabilityButtonColor: UIColor?

    // Text
    public var textColor: UIColor?
    public var placeholderColor: UIColor?
    public var cancelTitle: String?

    // Cancel button to change the appearance.
    public var cancelButton: UIButton? {
        guard showsCancelButton else { return nil }
        return self.value(forKey: SubviewKey.cancelButton.rawValue) as? UIButton
    }

    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.

    override func layoutSubviews() {
        super.layoutSubviews()

        if let cancelColor = cancelButtonColor {
            self.cancelButton?.setTitleColor(cancelColor, for: .normal)
        }
        if let cancelTitle = cancelTitle {
            self.cancelButton?.setTitle(cancelTitle, for: .normal)
        }

        guard let textField = self.value(forKey: SubviewKey.searchField.rawValue) as? UITextField else { return }

        if let clearButton = textField.value(forKey: SubviewKey.clearButton.rawValue) as? UIButton {
            update(button: clearButton, image: clearButtonImage, color: clearButtonColor)
        }
        if let resultsButton = textField.rightView as? UIButton {
            update(button: resultsButton, image: resultsButtonImage, color: capabilityButtonColor)
        }
        if let searchView = textField.leftView as? UIImageView {
            searchView.image = (searchImage ?? searchView.image)?.withRenderingMode(.alwaysTemplate)
            if let color = searchIconColor {
                searchView.tintColor = color
            }
        }
        if let placeholderLabel =  textField.value(forKey: SubviewKey.placeholderLabel.rawValue) as? UILabel,
            let color = placeholderColor {
            placeholderLabel.textColor = color
        }
        if let textColor = textColor  {
            textField.textColor = textColor
        }
    }

    private func update(button: UIButton, image: UIImage?, color: UIColor?) {
        let image = (image ?? button.currentImage)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        if let color = color {
            button.tintColor = color
        }
    }
}
