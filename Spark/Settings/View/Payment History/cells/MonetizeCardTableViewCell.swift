//
//  MonetizeCardTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 13/07/22.
//

import UIKit

/**
 This class is used set the detail of monetize feed about listing cost
 */

class MonetizeCardTableViewCell: UITableViewCell {

    @IBOutlet weak var postPriceLbl: UILabel!
    @IBOutlet weak var platfdormfeePriceLbl: UILabel!
    @IBOutlet weak var tacPriceLbl: UILabel!
    @IBOutlet weak var postListingCostPriceLbl: UILabel!
    
    @IBOutlet weak var SparkPostCOntentLbl: UILabel! //Loop content fee
    @IBOutlet weak var totalCostContentLbl: UILabel! // Loop List cost
    
    @IBOutlet weak var paymentIdLbl: UILabel!
    
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var line3: UILabel!
   
    @IBOutlet weak var paymentIdStackView: UIStackView!
    @IBOutlet weak var paymentLine: UILabel!
    @IBOutlet weak var paymentIdValue: UILabel!
    
    @IBOutlet weak var paymentMethodStackView: UIStackView!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var paymentMethodValue: UILabel!
    @IBOutlet weak var paymentMethodLine: UILabel!
    
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
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
