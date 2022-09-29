//
//  BlockUserTableViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit
import UIView_Shimmer


protocol blockUserDelegate:AnyObject {
    func blockUser(sender:UIButton)
}

/**
 This class is used to set the tableview cell with shimmer animation
 */

class BlockedUserListTableViewCell: UITableViewCell,ShimmeringViewProtocol {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var connectionCountLbl: UILabel!
    @IBOutlet weak var blockBtn: UIButton!
    
    weak var blockDelegate:blockUserDelegate?
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!
    
    /// Set the shimmering animated items
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3
            
        ]
    }
    
    
    ///Set the view Model cell to set the variables.
    var viewModelCell:BlockedUserListTableViewCellViewModel? {
        
        didSet {
            
            nameLbl.text = viewModelCell?.getName
            imgView.setImage(
                url: URL.init(string: viewModelCell?.getProfileImage ?? "") ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: viewModelCell?.gender == 1 ?  "no_profile_image_male" : viewModelCell?.gender == 2 ? "no_profile_image_female" : "others"))
            
            
            
            connectionCountLbl.text = viewModelCell?.getConnectionCount
        }
    }
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layoutIfNeeded()
        imgView.layer.cornerRadius = 6.0
        imgView.clipsToBounds = true
        
        contentView.clipsToBounds = true
        
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
    
    
    ///It is used to load the animation of shimmer
    func showDummy(){
        self.dummyView1.isHidden = false
        self.dummyView2.isHidden = false
        self.dummyView3.isHidden = false
        self.imgView?.isHidden = true
        self.nameLbl.isHidden = true
        self.connectionCountLbl.isHidden = true
        self.blockBtn.isHidden = true
        self.bgView.isHidden = true
    }
    
    ///It is used to hide the animation of shimmer
    func hideDummy(){
        self.dummyView1.isHidden = true
        self.dummyView2.isHidden = true
        self.dummyView3.isHidden = true
        self.imgView?.isHidden = false
        self.nameLbl.isHidden = false
        self.connectionCountLbl.isHidden = false
        self.blockBtn.isHidden = false
        self.bgView.isHidden = false
    }
    
    
    /// Tapped the unblock button to communicate the class to show  popup of block and cancel
    @IBAction func blockUnblockButtonTapped(_ sender: UIButton) {
        
        blockDelegate?.blockUser(sender: sender)
    }
}
