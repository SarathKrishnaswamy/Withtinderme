//
//  SettingsTableViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit

/**
 This class is used to set the settings label, icon and background.
 */
class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titlelbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.cornerRadius = 6.0
        bgView.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        bgView.layer.borderWidth = 0.6
        bgView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
