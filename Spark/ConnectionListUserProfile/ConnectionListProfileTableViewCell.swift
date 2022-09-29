//
//  ConnectionListProfileTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 23/05/22.
//

import UIKit
import UIView_Shimmer

/**
 This cell is used to show the connection list profile top items like name,  profile image, views count, wallet count, connections count
 */
class ConnectionListProfileTableViewCell: UITableViewCell,ShimmeringViewProtocol {
  
    @IBOutlet var emailLbl:UILabel?
    @IBOutlet var viewLblCount:UILabel?
    @IBOutlet var scroreLblCount:UILabel?
    @IBOutlet var claoLblCount:UILabel?
    @IBOutlet var connectionLblCount:UILabel?
    @IBOutlet var profileImageView:customImageView?
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var nameLbl:UILabel?
    @IBOutlet weak var scoreBtn: UIButton!
    @IBOutlet var aboutMeLbl:UILabel?
    @IBOutlet var aboutSeeMoreBtn:UIButton?
    @IBOutlet var nftImage: UIImageView!
    
    //DummyView
    @IBOutlet weak var dummyView_1: UIView!
    @IBOutlet weak var dummyView_2: UIView!
    @IBOutlet weak var dummyView_3: UIView!
    @IBOutlet weak var dummyView_4: UIView!
    @IBOutlet weak var dummyView_5: UIView!
    @IBOutlet weak var dummyView_6: UIView!
    @IBOutlet weak var dummyView_7: UIView!
    
    var viewModel = ProfileViewModel()
    
    weak var connectionDelegate : connectionListUserprofileDelegate?
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
        self.scoreBtn.isHidden = true
        self.aboutMeLbl?.isHidden = true
        self.aboutSeeMoreBtn?.isHidden = true
        self.nftImage.isHidden = true
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
        self.scoreBtn.isHidden = false
        self.aboutMeLbl?.isHidden = false
        self.aboutSeeMoreBtn?.isHidden = false
        self.nftImage.isHidden = false
        
    }
    
    @IBAction func readMoreButtonTapped(_ sender: UIButton) {
        connectionDelegate?.readMoreButtonTappedFunction(sender: sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
