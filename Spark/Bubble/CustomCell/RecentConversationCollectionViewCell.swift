//
//  RecentConversationCollectionViewCell.swift
//  Spark me
//
//  Created by adhash on 17/08/21.
//

import UIKit
import UIView_Shimmer

/// Set conversation list update delegate to update the recent loops list
protocol conversationListUpdateDelegate : AnyObject {
    
    func conversationListFunction(senderTag:Int)
}

/**
 This class is used for recent collectionview cell to set in bubble view controller
 */
class RecentConversationCollectionViewCell: UICollectionViewCell, ShimmeringViewProtocol{

    @IBOutlet weak var viewMoreBgView: CardView!
    @IBOutlet weak var conversationPostThumb: UIImageView!
    @IBOutlet weak var playIconImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var dateAndTimeLbl: UILabel!
    @IBOutlet weak var currencyCodeView: Gradient!
    @IBOutlet weak var currencyCodeLbl: UILabel!
    
    //Dummy View
    @IBOutlet weak var dummyView_1: UIView!
    @IBOutlet weak var dummyView_2: UIView!
    @IBOutlet weak var dummyView_3: UIView!

    
    weak var delegate : conversationListUpdateDelegate?
    
    /// Set the view model cell with recent conversation model with visible tag name, display name, media type
    var viewModelCell:RecentConversationCellViewModel? {
        
        didSet {
            
            userNameLbl.text = viewModelCell?.tagName
            descLbl.text = viewModelCell?.displayName
            dateAndTimeLbl.text = viewModelCell?.getVisibleDate
            if viewModelCell?.recentConversationListData?.isMonetize == 0{
                self.currencyCodeView.isHidden = true
            }
            else{
                self.currencyCodeView.isHidden = false
                self.currencyCodeLbl.text = viewModelCell?.recentConversationListData?.currencySymbol
                self.currencyCodeLbl.textColor = .white
            }
            playIconImgView.isHidden = true
            
            switch viewModelCell?.mediaType {
            
            case MediaType.Text.rawValue:
                
                conversationPostThumb.image = #imageLiteral(resourceName: "textIcon")
                
            case MediaType.Video.rawValue:
        
                playIconImgView.isHidden = false
                conversationPostThumb.setImage(
                    url: URL.init(string: viewModelCell?.getVideoThumpNailImage ?? "") ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                
                
            case MediaType.Image.rawValue:
                
                conversationPostThumb.setImage(
                    url: URL.init(string: viewModelCell?.getPostImage ?? "") ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                
            case MediaType.Audio.rawValue:
              
                conversationPostThumb.image = #imageLiteral(resourceName: "audioIcon")

            case MediaType.Document.rawValue:
            
                conversationPostThumb.image = #imageLiteral(resourceName: "docIcon")
            
            default:
                break
            }
            
        }
    }
    
    /// Set the shimmering animated views here in the array of UIViews
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView_1,
            dummyView_2,
            dummyView_3
        ]
    }
    
    /// Show the view that going animate
    func showDummy(){
        self.dummyView_1.isHidden = false
        self.dummyView_2.isHidden = false
        self.dummyView_3.isHidden = false
        self.viewMoreBgView.isHidden = true
        self.conversationPostThumb.isHidden = true
        self.playIconImgView.isHidden = true
        self.userNameLbl.isHidden = true
        self.descLbl.isHidden = true
        self.dateAndTimeLbl.isHidden = true
        self.currencyCodeView.isHidden = true
    }
    
    /// Hide the animating view here
    func hideDummy(){
        self.dummyView_1.isHidden = true
        self.dummyView_2.isHidden = true
        self.dummyView_3.isHidden = true
        self.viewMoreBgView.isHidden = false
        self.conversationPostThumb.isHidden = false
        self.playIconImgView.isHidden = false
        self.userNameLbl.isHidden = false
        self.descLbl.isHidden = false
        self.dateAndTimeLbl.isHidden = false
        self.currencyCodeView.isHidden = true
    }
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.viewMoreBgView.isHidden = true
        currencyCodeView.layer.cornerRadius = self.currencyCodeView.frame.width/2
        viewMoreBgView.translatesAutoresizingMaskIntoConstraints = false
        viewMoreBgView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 32).isActive = true
    }
}
