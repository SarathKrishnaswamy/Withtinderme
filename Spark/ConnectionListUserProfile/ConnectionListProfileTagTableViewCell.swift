//
//  ConnectionListProfileTagTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 23/05/22.
//

import UIKit
import UIView_Shimmer


/**
 This cell is used to set the connection list tags with header and tags with dummy views animation delecared here
 */

class ConnectionListProfileTagTableViewCell: UITableViewCell,ShimmeringViewProtocol {
    
    @IBOutlet var bgViewOne:CardView?
    @IBOutlet var bgViewTwo:CardView?
    @IBOutlet var bgViewThree:CardView?
    
    @IBOutlet var tagBtnOne:UIButton?
    @IBOutlet var tagBtnTwo:UIButton?
    @IBOutlet var tagThree:UIButton?
    @IBOutlet var seeMoreBtn:UIButton?
    
    @IBOutlet var tagOnebgView:UIView?
    @IBOutlet var tagTwobgView:UIView?
    @IBOutlet var tagThreebgView:UIView?
    
    @IBOutlet weak var bgStackview: UIStackView!
    
    @IBOutlet weak var headerLbl: UILabel!
    
    @IBOutlet weak var noTagsLbl: UILabel!
    //shimmerdummyView
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!
    @IBOutlet weak var dummyView4: UIView!
    @IBOutlet weak var dummyView5: UIView!
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3,
            dummyView4,
            dummyView5
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDummy(){
        self.dummyView1.isHidden = false
        self.dummyView2.isHidden = false
        self.dummyView3.isHidden = false
        self.dummyView4.isHidden = false
        self.dummyView5.isHidden = false
        self.bgViewOne?.isHidden = true
        self.bgViewTwo?.isHidden = true
        self.bgViewThree?.isHidden = true
        self.tagBtnOne?.isHidden = true
        self.tagBtnTwo?.isHidden = true
        self.tagThree?.isHidden = true
        self.seeMoreBtn?.isHidden = true
        self.tagOnebgView?.isHidden = true
        self.tagTwobgView?.isHidden = true
        self.tagThreebgView?.isHidden = true
        self.bgStackview.isHidden = true
        self.headerLbl.isHidden = true
        self.noTagsLbl.isHidden = true
        
        
    }
    
    func hideDummy(){
        self.dummyView1.isHidden = true
        self.dummyView2.isHidden = true
        self.dummyView3.isHidden = true
        self.dummyView4.isHidden = true
        self.dummyView5.isHidden = true
        self.bgViewOne?.isHidden = false
        self.bgViewTwo?.isHidden = false
        self.bgViewThree?.isHidden = false
        self.tagBtnOne?.isHidden = false
        self.tagBtnTwo?.isHidden = false
        self.tagThree?.isHidden = false
        self.seeMoreBtn?.isHidden = false
        self.tagOnebgView?.isHidden = false
        self.tagTwobgView?.isHidden = false
        self.tagThreebgView?.isHidden = false
        self.bgStackview.isHidden = false
        self.headerLbl.isHidden = false
        self.noTagsLbl.isHidden = true
    }


}
