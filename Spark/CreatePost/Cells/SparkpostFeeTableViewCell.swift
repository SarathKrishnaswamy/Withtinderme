//
//  SparkpostFeeTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/07/22.
//

import UIKit

class SparkpostFeeTableViewCell: UITableViewCell {

    /**
     This class is used to set the monetize fee and listing fee
     */
    @IBOutlet weak var sparkpostLbl: UILabel!
    @IBOutlet weak var sparkPostPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
