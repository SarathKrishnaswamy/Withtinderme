//
//  sparkPostTaxFeeTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/07/22.
//

import UIKit

class sparkPostTaxFeeTableViewCell: UITableViewCell {

    /**
     This class is used to set the tax fee for each of the items when user posting
     */
    @IBOutlet weak var feeLbl: UILabel!
    @IBOutlet weak var feePrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
