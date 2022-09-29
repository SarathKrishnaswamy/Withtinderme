//
//  ProfileTopTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 16/05/22.
//

import UIKit
import UIView_Shimmer

class ProfileTopTableViewCell: UITableViewCell,ShimmeringViewProtocol {
    
    
    @IBOutlet var nameLbl:UILabel?
    @IBOutlet var emailLbl:UILabel?
    @IBOutlet var viewLblCount:UILabel?
    @IBOutlet var scroreLblCount:UILabel?
    @IBOutlet var claoLblCount:UILabel?
    @IBOutlet var connectionLblCount:UILabel?
    @IBOutlet var profileImageView:customImageView?
    @IBOutlet var editBtn:UIButton?
    @IBOutlet weak var connectionListBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var scoreBtn: UIButton!
    @IBOutlet var aboutMeLbl:UILabel?
    @IBOutlet var aboutSeeMoreBtn:UIButton?
    @IBOutlet weak var nftImage: UIImageView!
    @IBOutlet weak var camerbtn: UIButton!
   
    //DummyView
    @IBOutlet weak var dummyView_1: UIView!
    @IBOutlet weak var dummyView_2: UIView!
    @IBOutlet weak var dummyView_3: UIView!
    @IBOutlet weak var dummyView_4: UIView!
    @IBOutlet weak var dummyView_5: UIView!
    @IBOutlet weak var dummyView_6: UIView!
    @IBOutlet weak var dummyView_7: UIView!
    
    weak var connectionDelegate : connectionListDelegate?
    
    var viewModel = ProfileViewModel()
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView_1,
            dummyView_2,
            dummyView_3,
            dummyView_4,
            dummyView_5,
            dummyView_6,
            dummyView_7
            
        ]
    }
    
   
    
    override class func awakeFromNib() {
        
    }
    
    
    
    func showDummy(){
        self.dummyView_1.isHidden = false
        self.dummyView_2.isHidden = false
        self.dummyView_3.isHidden = false
        self.dummyView_4.isHidden = false
        self.dummyView_5.isHidden = false
        self.dummyView_6.isHidden = false
        self.dummyView_7.isHidden = false
        self.nameLbl?.isHidden = true
        self.emailLbl?.isHidden = true
        self.viewLblCount?.isHidden = true
        self.scroreLblCount?.isHidden = true
        self.claoLblCount?.isHidden = true
        self.connectionLblCount?.isHidden = true
        self.profileImageView?.isHidden = true
        self.editBtn?.isHidden = true
        self.connectionListBtn.isHidden = true
        self.submitBtn.isHidden = true
        self.scoreBtn.isHidden = true
        self.aboutMeLbl?.isHidden = true
        self.aboutSeeMoreBtn?.isHidden = true
        self.nftImage.isHidden = true
        self.camerbtn.isHidden = true
    }
    
    func hideDummy(){
        
        self.dummyView_1.isHidden = true
        self.dummyView_2.isHidden = true
        self.dummyView_3.isHidden = true
        self.dummyView_4.isHidden = true
        self.dummyView_5.isHidden = true
        self.dummyView_6.isHidden = true
        self.dummyView_7.isHidden = true
        self.nameLbl?.isHidden = false
        self.emailLbl?.isHidden = true
        self.viewLblCount?.isHidden = false
        self.scroreLblCount?.isHidden = false
        self.claoLblCount?.isHidden = false
        self.connectionLblCount?.isHidden = false
        self.profileImageView?.isHidden = false
        self.editBtn?.isHidden = false
        self.connectionListBtn.isHidden = false
        self.submitBtn.isHidden = false
        self.scoreBtn.isHidden = false
        self.aboutMeLbl?.isHidden = false
        self.aboutSeeMoreBtn?.isHidden = false
        self.nftImage.isHidden = false
        self.camerbtn.isHidden = false
        
    }
    
    @IBAction func connectionListBtnTapped(_ sender: Any) {
        connectionDelegate?.connectionListTappedFunction()
    }
    
    @IBAction func readMoreButtonTapped(_ sender: UIButton) {
        connectionDelegate?.readMoreButtonTappedFunction(sender: sender)
    }

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
