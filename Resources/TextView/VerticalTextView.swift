//
//  VerticalTextView.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 27/04/22.
//

import Foundation
import UIKit

class VerticalTextView: UITextView {
    
    enum VerticalAlignment: Int {
        case Top = 0, Middle, Bottom
    }
    
    var verticalAlignment: VerticalAlignment = .Middle
    
    ///override contentSize property and observe using didSet
    override var contentSize: CGSize {
        didSet {
            let height = self.bounds.size.height
            let contentHeight: CGFloat = contentSize.height
            var topCorrect: CGFloat = 0.0
            
            switch (self.verticalAlignment) {
            case .Top:
                self.contentOffset = CGPoint.zero //set content offset to top
                
            case .Middle:
                topCorrect = (height - contentHeight * self.zoomScale) / 2.0
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                self.contentOffset = CGPoint(x: 0, y: -topCorrect)
                
            case .Bottom:
                topCorrect = self.bounds.size.height - contentHeight
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                self.contentOffset = CGPoint(x: 0, y: -topCorrect)
            }
            
            if contentHeight >= height { // if the contentSize is greater than the height
                topCorrect = contentHeight - height // set the contentOffset to be the
                topCorrect = topCorrect < 0 ? 0 : topCorrect // contentHeight - height of textView
                self.contentOffset = CGPoint(x: 0, y: topCorrect)
            }
        }
    }
    
    // MARK: - UIView
    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.contentSize // forces didSet to be called
        self.contentSize = size
    }
    
}
