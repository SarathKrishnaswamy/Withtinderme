//
//  LoaderTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 13/05/22.
//

import UIKit
/**
 This cell is used to load the cell with activity indicator
 */
class LoaderTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingViewsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
