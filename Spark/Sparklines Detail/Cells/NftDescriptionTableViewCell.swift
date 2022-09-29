//
//  NftDescriptionTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/02/22.
//

import UIKit
import UICircularProgressRing

/**
 This table view cell is used to set in NFT Spark lines details and set for description
 */
class NftDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptiontextView: UILabel!
    @IBOutlet weak var ContractAddressLbl: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var TokenIdLbl: UILabel!
    @IBOutlet weak var TokenStandard: UILabel!
    @IBOutlet weak var BLockChainLbl: UILabel!
    @IBOutlet weak var DescriptionView: UIView!
    @IBOutlet weak var DescBottomLine: UILabel!
    @IBOutlet weak var DescTopLine: UILabel!
    @IBOutlet weak var titleOneBgView: UILabel!
    @IBOutlet weak var titleTwoBgView: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var propertieslbl: UILabel!
    @IBOutlet weak var propertyView1: UIView!
    @IBOutlet weak var propertyView2: UIView!
    @IBOutlet weak var propertyView3: UIView!
    @IBOutlet weak var descbgView: UIView!
    @IBOutlet weak var detailsBgView: UIView!
    @IBOutlet weak var propertiesView: UIView!
    @IBOutlet weak var bosstView: UIView!
    @IBOutlet weak var calendarBgView: UIView!
    
   // @IBOutlet weak var dateCharacterLbl: UILabel!
    @IBOutlet weak var property1Lbl: UILabel!
    @IBOutlet weak var traitType1Lbl: UILabel!
    @IBOutlet weak var property2Lbl: UILabel!
    @IBOutlet weak var traitType2Lbl: UILabel!
    @IBOutlet weak var property3Lbl: UILabel!
    @IBOutlet weak var traitType3Lbl: UILabel!
    @IBOutlet weak var propertiesBaseView: UIView!
    
    @IBOutlet weak var bosstCircle1: UICircularProgressRing!
    @IBOutlet weak var bosstCircle2: UICircularProgressRing!
    @IBOutlet weak var bosstCircle3: UICircularProgressRing!
    @IBOutlet weak var boost1Lbl: UILabel!
    @IBOutlet weak var boost2Lbl: UILabel!
    @IBOutlet weak var boost3Lbl: UILabel!
    @IBOutlet weak var boostBaseView: UIView!
    
    @IBOutlet weak var boost1StackView: UIStackView!
    @IBOutlet weak var boost2StackView: UIStackView!
    @IBOutlet weak var boost3StackView: UIStackView!
    
    
    @IBOutlet weak var dateLbl1: UILabel!
    @IBOutlet weak var dateValueLbl: UILabel!
    @IBOutlet weak var calendarBaseView: UIView!
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // self.descriptiontextView.isHidden = true
        
        self.propertyView1.layer.cornerRadius = 6.0
        self.propertyView2.layer.cornerRadius = 6.0
        self.propertyView3.layer.cornerRadius = 6.0
        
        self.propertyView1.layer.borderColor = UIColor.lightGray.cgColor
        self.propertyView2.layer.borderColor = UIColor.lightGray.cgColor
        self.propertyView3.layer.borderColor = UIColor.lightGray.cgColor
        
        self.propertyView1.layer.borderWidth = 1.0
        self.propertyView2.layer.borderWidth = 1.0
        self.propertyView3.layer.borderWidth = 1.0
    }

    

}

