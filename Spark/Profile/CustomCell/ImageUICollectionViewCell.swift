//
//  ImageUICollectionViewCell.swift
//  CHTWaterfallSwift
//
//  Created by Sophie Fader on 3/21/15.
//  Copyright (c) 2015 Sophie Fader. All rights reserved.
//

import UIKit
import UIView_Shimmer

class ImageUICollectionViewCell: UICollectionViewCell,ShimmeringViewProtocol {

    @IBOutlet weak var image: customImageView!
    @IBOutlet weak var docImageView: customImageView!
    @IBOutlet weak var imageBgImage: customImageView!
    @IBOutlet weak var txtBgView: UIView!
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
   // @IBOutlet weak var postTypeImgView: customImageView!
    
    @IBOutlet weak var viewBtn: UIButton!
    //@IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var NftImage: UIImageView!
    
    //shimmerView
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var repostImage: UIImageView!
    @IBOutlet weak var monetizeView: UIView!
    @IBOutlet weak var monetizeLbl: UILabel!
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView
            
        ]
    }
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
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
        bgView.isHidden = true
        image.isHidden = true
        docImageView.isHidden = true
        txtBgView.isHidden = true
        txtLbl.isHidden = true
       // postTypeImgView.isHidden = true
        imageBgImage.isHidden = true
    }
    
    func hideDummy(){
        self.dummyView.isHidden = true
        bgView.isHidden = false
        image.isHidden = false
        docImageView.isHidden = false
        txtBgView.isHidden = false
        txtLbl.isHidden = false
       // postTypeImgView.isHidden = false
        imageBgImage.isHidden = false
    }

    
    
}
