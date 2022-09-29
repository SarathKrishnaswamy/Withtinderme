//
//  ThreadMemberListCollectionViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 13/08/21.
//

import UIKit
import UIView_Shimmer

/**
 This collectionView cell is used to show the member list in the feed detail page.
 */

class ThreadMemberListCollectionViewCell: UICollectionViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageView: customImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var grayView: UIView!
    
    //DummyView
    @IBOutlet weak var dummyView: UIView!
    

    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView

        ]
    }
    
    var viewModelCell:ThreadMemberCellViewModel?{
        didSet {
//            nameLbl.text = viewModelCell?.getName
//            imageView.setImage(
//                url: URL.init(string: viewModelCell?.getImage ?? "") ?? URL(fileURLWithPath: ""),
//              placeholder: #imageLiteral(resourceName: "no_profile_image_male"))
            
           
        }
    }
    
    
    
    func showDummy(){
        self.dummyView.isHidden = false
        self.bgView.isHidden = true
        self.nameLbl.isHidden = true
    }
    
    func hideDummy(){
        self.dummyView.isHidden = true
        self.bgView.isHidden = false
        self.nameLbl.isHidden = false
    }
  
}
