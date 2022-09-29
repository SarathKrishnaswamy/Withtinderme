//
//  ConnectionListTableViewCell.swift
//  Spark me
//
//  Created by adhash on 24/08/21.
//

import UIKit
/**
 
 View profile delegate is used to tap the profile button  oin connection List page
 */
protocol viewProfileDelegate : AnyObject {
    func connectionListViewProfileButtonTapped(sender:Int)
}

/// This class is used to set the tableview cell for connection list profile shown in this page.
class ConnectionListTableViewCell: UITableViewCell {

    weak var viewProfileDelegate : viewProfileDelegate?

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var userImgViewForConnectionList: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnViewProfile: UIButton!
    
    /// viewmodel cell is used to set the api calls in this cell
    var viewModelCell:ConnectionListCellViewModel? {
        
        didSet {
            lblName.text = viewModelCell?.getUserName
            lblDesc.text = viewModelCell?.getConnectionCount
            
            userImgViewForConnectionList.setImage(
                url: URL.init(string: viewModelCell?.getNotificationImage ?? "") ?? URL(fileURLWithPath: ""),
              placeholder: #imageLiteral(resourceName: viewModelCell?.getGender == 1 ?  "no_profile_image_male" : viewModelCell?.getGender == 2 ? "no_profile_image_female" : "others"))
            
            
        }
    }
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImgViewForConnectionList.layer.cornerRadius = 6.0
        userImgViewForConnectionList.clipsToBounds = true
        
        btnViewProfile.titleLabel?.font = UIFont.MontserratMedium(.appNormalSize)
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
    
    
    /**
     When view profile is tapped it will call delegate method in the class and open the connectionList view profile page.
     */
    @IBAction func ViewProfileButtonTapped(_ sender: Any) {
        viewProfileDelegate?.connectionListViewProfileButtonTapped(sender: btnViewProfile.tag)
    }

}
