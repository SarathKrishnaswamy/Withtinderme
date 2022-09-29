//
//  ActivityIndicatorCollectionViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 13/05/22.
//

import UIKit

/**
 This cell is used to set the loader in below or top the page in collectionview cell
 */
class ActivityIndicatorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
