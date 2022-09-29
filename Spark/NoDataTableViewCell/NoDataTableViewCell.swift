//
//  NoDataTableViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit

/**
 This cell is used to set the no data table with will illustration that no image and no data found will be shown

 */
class NoDataTableViewCell: UITableViewCell {

    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
