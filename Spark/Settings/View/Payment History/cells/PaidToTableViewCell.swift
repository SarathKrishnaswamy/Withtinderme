//
//  PaidToTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import UIKit

/**
 This class is used to set the payment details of wallet and history
 */

class PaidToTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var paidTopersonLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var paidToOrReceivedLbl: UILabel!
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = 4.0
        self.profileImage.contentMode = .scaleAspectFill
        self.statusView.layer.cornerRadius = 4.0
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
