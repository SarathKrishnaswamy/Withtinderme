//
//  FooterCollectionReusableView.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 28/04/22.
//

import UIKit

/// Footer cell is used to set the loader with activity indicator
class FooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
