//
//  NotificationTableViewCell.swift
//  Spark me
//
//  Created by adhash on 14/08/21.
//

import UIKit
import UIView_Shimmer

protocol acceptDeclineDelegate : AnyObject {
    /// This method is used to accept the request or decline it
    /// - Parameters:
    ///   - sender: Tag for accept button for each indexPath
    ///   - acceptOrReject: 0 or 1 to decline or accept the request
    func acceptDeclineTapped(sender:UIButton,acceptOrReject:Int)
}

/// Notification tableview cell is used to shown in the notification view controller with shimmer
class NotificationTableViewCell: UITableViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var userThumbImgView: UIImageView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var acceptRejectStackView: UIStackView!
    @IBOutlet weak var acceptRejectStackViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var monetizeView: Gradient!
    
    @IBOutlet weak var currencySymbol: UILabel!
    
    //DummyView
    @IBOutlet weak var dummyView_1: UIView!
    @IBOutlet weak var dummyView_2: UIView!
    @IBOutlet weak var dummyView_3: UIView!
    
    /// Show the shimmer animated items
    var shimmeringAnimatedItems: [UIView] {
            [
                dummyView_1,
                dummyView_2,
                dummyView_3
            ]
        }
    
    
    weak var acceptDeclineDelegate : acceptDeclineDelegate?
    
    
    ///Initialise the view Model cell to get the all the notification view model and set the variables.
    var viewModelCell:NotificationCellViewModel? {
        
        didSet {
            
            if viewModelCell?.allowAnonymousUser ?? false {
                contentLbl.text = "Anonymous User \(viewModelCell?.getNotificationMessage ?? "")"
                userProfileImgView.image = UIImage.init(named: "ananomous_user")
            }else{
                contentLbl.text = "\(viewModelCell?.displayName ?? "") \(viewModelCell?.getNotificationMessage ?? "")"
                userProfileImgView.setImage(
                    url: URL.init(string: viewModelCell?.getNotificationImage ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModelCell?.getGender == 1 ?  "no_profile_image_male" : viewModelCell?.getGender == 2 ? "no_profile_image_female" : "others"))
            }
            
            
            
            dateLbl.text = viewModelCell?.getNotificationTime
            
            switch viewModelCell?.getTypeOfNotify {
            case 3://Thread // accepted
                self.monetizeView.isHidden = true
                userThumbImgView.image = #imageLiteral(resourceName: "accepted")
            case 1://clap
                self.monetizeView.isHidden = true
                userThumbImgView.image = #imageLiteral(resourceName: "notificationClap")
            case 2://View
                self.monetizeView.isHidden = true
                userThumbImgView.image = #imageLiteral(resourceName: "notificationView")
            case 6://Reveal Identity
                self.monetizeView.isHidden = true
                userThumbImgView.image = UIImage.init(named: "notification_identity_reveal")
            case 5://Waiting approval
                self.monetizeView.isHidden = true
                userThumbImgView.image = UIImage.init(named: "notification_waiting_user")
            case 7:
                self.monetizeView.isHidden = true
                userThumbImgView.image = #imageLiteral(resourceName: "notificationThread")
                
            case 8:
                if SessionManager.sharedInstance.saveCountryCode == "+91"{
                    self.currencySymbol.text = "₹"
                }
                else{
                    self.currencySymbol.text = "$"
                }
                self.monetizeView.isHidden = false
                
            default:
                self.monetizeView.isHidden = true
                break
            }
            
            if viewModelCell?.getTypeOfNotify == 5 || viewModelCell?.getTypeOfNotify == 6 {
                acceptRejectStackViewHeightConstraints.constant = viewModelCell?.getAcceptRejectStatus == true ? 30 : 0
                declineBtn.isHidden = viewModelCell?.getAcceptRejectStatus == true ? false : true
            }else {
                acceptRejectStackViewHeightConstraints.constant = 0
                declineBtn.isHidden = true
            }
        }
    }
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.monetizeView.isHidden = true
        acceptBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toBottomRight, for: .normal)
        self.monetizeView.layer.cornerRadius = self.monetizeView.frame.width/2
    }
    
    
    
    ///It is used to load the animation of shimmer
    func showDummy(){
        self.dummyView_1.isHidden = false
        self.dummyView_2.isHidden = false
        self.dummyView_3.isHidden = false
        self.userProfileImgView.isHidden = true
        self.userThumbImgView.isHidden = true
        self.contentLbl.isHidden = true
        self.dateLbl.isHidden = true
        self.acceptBtn.isHidden = true
        self.declineBtn.isHidden = true
        self.acceptRejectStackView.isHidden = true
        self.monetizeView.isHidden = true
    }
    
    
    
    ///It is used to hide the animation of shimmer
    func hideDummy(){
        self.dummyView_1.isHidden = true
        self.dummyView_2.isHidden = true
        self.dummyView_3.isHidden = true
        self.userProfileImgView.isHidden = false
        self.userThumbImgView.isHidden = false
        self.contentLbl.isHidden = false
        self.dateLbl.isHidden = false
        self.acceptBtn.isHidden = false
        self.declineBtn.isHidden = false
        self.acceptRejectStackView.isHidden = false
        self.monetizeView.isHidden = false
    }
    
    
    
    
    ///Lays out subviews.
    /// - The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.
    /// - Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.
    /// - You should not call this method directly. If you want to force a layout update, call the setNeedsLayout() method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded() method.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.userProfileImgView.layer.borderWidth = 1
        
        self.userProfileImgView.layer.masksToBounds = true
        
        self.userProfileImgView.layer.cornerRadius = 10
        
        self.acceptBtn.layer.cornerRadius = 6.0
        acceptBtn.clipsToBounds = true
        
    }
    
    
    
    ///Accept button tapping call the accept notifying api call.
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        
        acceptDeclineDelegate?.acceptDeclineTapped(sender: sender, acceptOrReject: 1)
    }
    
    ///Declind button tapping call the decline notifying api call.
    @IBAction func declineButtonTapped(_ sender: UIButton) {
        
        acceptDeclineDelegate?.acceptDeclineTapped(sender: sender, acceptOrReject: 0)
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
    
    
    /// Load the image from cache using url and from profile page.
    func loadImageUsingCacheWithUrlStrings(urlString: String,isFromProfile:Bool) {
        
        var imageUrlString : String?
        
        imageUrlString = urlString
        
        userProfileImgView.image = isFromProfile == true ? #imageLiteral(resourceName: "no_profile_image_male") : #imageLiteral(resourceName: "NoImage")
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            userProfileImgView.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url ?? URL(fileURLWithPath: ""), completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    if imageUrlString == urlString {
                        self.userProfileImgView.image = downloadedImage
                    }
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    return
                }
            })
            
        }).resume()
    }
}
