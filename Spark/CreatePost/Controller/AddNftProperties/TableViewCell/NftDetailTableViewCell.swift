//
//  NftDetailTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 18/03/22.
//

import UIKit

/**
 This class is used to set all the objects of property in tablevioew row
 */

class NftDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var characterPro1TF: UITextField!
    @IBOutlet weak var characterPro2TF: UITextField!
    @IBOutlet weak var characterPro3TF: UITextField!
    
    @IBOutlet weak var valuePro1TF: UITextField!
    @IBOutlet weak var valuePro2TF: UITextField!
    @IBOutlet weak var valuePro3TF: UITextField!
    
    @IBOutlet weak var characterBoost1TF: UITextField!
    @IBOutlet weak var characterBoost2TF: UITextField!
    @IBOutlet weak var characterBoost3TF: UITextField!
    
    @IBOutlet weak var valueBoosts1TF: UITextField!
    @IBOutlet weak var valueBoosts2TF: UITextField!
    @IBOutlet weak var valueBoosts3TF: UITextField!
    
    
    @IBOutlet weak var characterDates1TF: UITextField!
    @IBOutlet weak var valueDates1TF: UITextField!
    
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var DateBtn: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    /// Sets the selected state of the cell, optionally animating the transition between states.
    /// - Parameters:
    ///   - selected: true to set the cell as selected, false to set it as unselected. The default is false.
    ///   - animated: true to animate the transition between selected states, false to make the transition immediate.
    ///    - The selection affects the appearance of labels, image, and background. When the selected state of a cell is true, it draws the background for selected cells (Reusing cells) with its title in white.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
