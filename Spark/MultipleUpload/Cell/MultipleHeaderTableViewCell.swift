//
//  MultipleHeaderTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import UIKit

/**
 This cell is used to set the header in the multiple loading page
 */
class MultipleHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var tagView: Gradient!
    @IBOutlet weak var tagLblBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var postTypeContentView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
