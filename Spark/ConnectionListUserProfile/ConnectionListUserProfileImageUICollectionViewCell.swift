//
//  ImageUICollectionViewCell.swift
//  CHTWaterfallSwift
//
//  Created by Sophie Fader on 3/21/15.
//  Copyright (c) 2015 Sophie Fader. All rights reserved.
//

import UIKit
import UIView_Shimmer


/// This cell is ued to set the collectionview cell as waterfall layout model
class ConnectionListUserProfileImageUICollectionViewCell: UICollectionViewCell,ShimmeringViewProtocol {

    @IBOutlet weak var image: customImageView!
    @IBOutlet weak var imageBgImage: customImageView!
    @IBOutlet weak var txtBgView: UIView!
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var postTypeImgView: customImageView!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var docImageView: customImageView!
    @IBOutlet weak var connectionProfileNFTimage: UIImageView!
    
    @IBOutlet weak var monetizeView: Gradient!
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var monetizeLbl: UILabel!
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView
            
        ]
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = imageBgImage.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageBgImage.addSubview(blurView)
        self.monetizeView.layer.cornerRadius = self.monetizeView.frame.width/2
        
    }
    
    func showDummy(){
        self.dummyView.isHidden = false
    }
    
    func hideDummy(){
        self.dummyView.isHidden = true
    }

}
