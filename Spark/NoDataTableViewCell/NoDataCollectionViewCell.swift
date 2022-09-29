//
//  NoDataCollectionViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 13/09/21.
//

import UIKit


/**
 This cell is used to show no data label and no data imageview with the collectionview
 */
class NoDataCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imgView.clipsToBounds = true
    }

}
