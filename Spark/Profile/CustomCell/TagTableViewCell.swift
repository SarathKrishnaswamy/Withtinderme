//
//  TagTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 17/05/22.
//

import UIKit
import UIView_Shimmer

class TagTableViewCell: UITableViewCell, ShimmeringViewProtocol {
    
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
    
    @IBOutlet weak var notagLbl: UILabel!

    @IBOutlet weak var postedSparkTagHeadLbl: UILabel!
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
        self.notagLbl.isHidden = true
        self.postedSparkTagHeadLbl.isHidden = true
        
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
        self.notagLbl.isHidden = false
        self.postedSparkTagHeadLbl.isHidden = false
    }

}
