//
//  ClappedTagSparkTableViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 14/08/21.
//

import UIKit
import AVKit
import EasyTipView
import SwiftyGif


/// Set the protocol here to get the video player index delegate with the object
protocol getPlayerVideoAudioIndexForMyPostDelegate : AnyObject{
    func getPlayVideoIndex(index:Int)
}

/// Clapped tag spark tableview cell is used to set in the class for existing spark tableview
class ClappedTagSparkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: CardView!
    
    @IBOutlet weak var iconImageView: customImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var contentsImageView: customImageView!
    @IBOutlet weak var pdfImgView: UIImageView!
    @IBOutlet weak var tagBtn: UIButton!
    @IBOutlet weak var viewCountBtn: UIButton!
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var connectionCountBtn: UIButton!
    @IBOutlet weak var clapCountBtn: UIButton!
    @IBOutlet weak var nftImage: UIImageView!
    
    weak var delegate:getPlayerVideoAudioIndexForMyPostDelegate?
    
    @IBOutlet weak var videoBgView: UIView!
    @IBOutlet weak var tagBgView: UIView!
    @IBOutlet weak var bgViewForText: UIView!
    
    @IBOutlet weak var txtView: UITextView!
    
    @IBOutlet weak var postTypeImgView: UIImageView!
    
    @IBOutlet weak var contentImageViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentImageBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var textBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var videoBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var pdfViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var contentBgImgView: UIImageView!
    @IBOutlet weak var AudioAnimation: UIImageView!
    
    var avplayer : AVPlayer?
    var playerController : AVPlayerViewController? = nil
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    var timer: Timer?
    var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    var isSeekInProgress = false
  
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    /// View model cell is used to get from view model api call and set in each indexPath for name, profile, gender and posteed time with media type
    var viewModelCell:ClappedTagSparkCellViewModel?{
      
        didSet {
            
            if viewModelCell?.allowAnonymous == true {
                titleLabel.text = "Anonymous User"
                iconImageView.image = UIImage.init(named: "ananomous_user")
            }else{
                titleLabel.text = viewModelCell?.getProfileName
                iconImageView.setImage(
                    url: URL.init(string: viewModelCell?.getProfileImage ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModelCell?.gender == 1 ?  "no_profile_image_male" : viewModelCell?.gender == 2 ? "no_profile_image_female" : "others"))
                
            }
            
            dateLabel.text = viewModelCell?.getPostedTime
            tagBtn.setTitle(viewModelCell?.getTagName, for: .normal)
            viewCountBtn.setTitle("\(viewModelCell?.getViewCount ?? 0)", for: .normal)
            clapCountBtn.setTitle("\(viewModelCell?.getClapCount ?? 0)", for: .normal)
            connectionCountBtn.setTitle("\(viewModelCell?.getThreadCount ?? 0)", for: .normal)
            
            postContentLabel.text = viewModelCell?.getPostedText
            postContentLabel.isHidden = false
            
            switch viewModelCell?.getPostType {
            case 1:
                postTypeImgView.image = #imageLiteral(resourceName: "globalGray")
            case 2:
                postTypeImgView.image = #imageLiteral(resourceName: "localGray")
            case 3:
                postTypeImgView.image = #imageLiteral(resourceName: "SocialGray")
            case 4:
                postTypeImgView.image = #imageLiteral(resourceName: "closedGray")
            default:
                break
            }
            
            if viewModelCell?.getPostedText.isEmpty ?? false {
                postContentLabel.isHidden = true
                videoBgViewHeightConstraints.constant = 225
                contentImageViewHeightConstraints.constant = 225
                contentImageBgViewHeightConstraints.constant = 225
                pdfViewHeightConstraints.constant = 225

            }else{
                postContentLabel.isHidden = false
                videoBgViewHeightConstraints.constant = 180
                contentImageViewHeightConstraints.constant = 180
                contentImageBgViewHeightConstraints.constant = 180
                pdfViewHeightConstraints.constant = 180
            }
            
            let isNft = viewModelCell?.getNFTstatus ?? 0
            
            switch viewModelCell?.getMediaType {
            
            case MediaType.Text.rawValue:
                
                contentBgImgView.isHidden = true
                bgViewForText.isHidden = false
                videoBgView.isHidden = true
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                postContentLabel.isHidden = true
                AudioAnimation.isHidden = true
                
                textBgViewHeightConstraints.constant = 210
                txtView.backgroundColor = .clear
                txtView.textAlignment = .center
                txtView.font = UIFont.MontserratRegular(.large)
                
                if viewModelCell?.getTextViewBgColor != ""{
                    Helper.sharedInstance.loadTextIntoCell(text: viewModelCell?.getPostedText ?? "", textColor: viewModelCell?.getTextViewTxtColor ?? "", bgColor: viewModelCell?.getTextViewBgColor ?? "" , label: txtView, bgView: bgViewForText)
                }else{
                    Helper.sharedInstance.loadTextIntoCell(text: viewModelCell?.getPostedText ?? "", textColor: "FFFFFF", bgColor: "358383", label: txtView, bgView: bgViewForText)
                }
                
                
                if isNft == 0{
                    nftImage.isHidden = true
                }
                else{
                    nftImage.isHidden = false
                }
                
            
            case MediaType.Video.rawValue:
               
                bgViewForText.isHidden = true
                videoBgView.isHidden = false
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                contentBgImgView.isHidden = false
                
                AudioAnimation.isHidden = true
                
                contentBgImgView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedThumbnailUrl ?? "") ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                
               // let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoBgTap(_:)))
                //self.videoBgView.addGestureRecognizer(videoTap)
                playOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "")
                
                if isNft == 0{
                    nftImage.isHidden = true
                }
                else{
                    nftImage.isHidden = false
                }
                
            case MediaType.Image.rawValue:
                
                bgViewForText.isHidden = true
                videoBgView.isHidden = true
                contentsImageView.isHidden = false
                pdfImgView.isHidden = true
                contentBgImgView.isHidden = false
                AudioAnimation.isHidden = true
                
                contentBgImgView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                contentsImageView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                
//                if !(viewModelCell?.getPostedMediaUrl.isEmpty ?? false) {
//                    contentsImageView.loadImageUsingCacheWithUrlString(urlString: viewModelCell?.getPostedMediaUrl ?? "", isFromProfile: false)
//
//                } else {
//                    contentsImageView.image = UIImage(named: "NoImage")
//                }
//
                if isNft == 0{
                    nftImage.isHidden = true
                }
                else{
                    nftImage.isHidden = false
                }
            case MediaType.Audio.rawValue:
              
                bgViewForText.isHidden = true
                videoBgView.isHidden = false
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                contentBgImgView.isHidden = false
               
                AudioAnimation.isHidden = false
                
               
                //let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoBgTap(_:)))
                //self.videoBgView.addGestureRecognizer(videoTap)

                playOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "")
                
                if isNft == 0{
                    nftImage.isHidden = true
                }
                else{
                    nftImage.isHidden = false
                }

            case MediaType.Document.rawValue:
            
                bgViewForText.isHidden = true
                videoBgView.isHidden = true
                contentsImageView.isHidden = true
                contentBgImgView.isHidden = true
                pdfImgView.isHidden = false
                
                AudioAnimation.isHidden = true
                pdfImgView.contentMode = .scaleAspectFill
                
            let imageName = viewModelCell?.getPostedMediaUrl.components(separatedBy: ".")
            
//            if imageName?.last == "pdf" {
//                pdfImgView.image = #imageLiteral(resourceName: "pdf")
//            }else if imageName?.last == "ppt" {
//                pdfImgView.image = #imageLiteral(resourceName: "ppt")
//            }else if imageName?.last == "docs" {
//                pdfImgView.image = #imageLiteral(resourceName: "doc")
//            }else if imageName?.last == "doc" || imageName?.last == "docx" {
//                pdfImgView.image = #imageLiteral(resourceName: "doc")
//            }else if imageName?.last == "xlsx" {
//                pdfImgView.image = #imageLiteral(resourceName: "xls")
//            }else if imageName?.last == "xls" {
//                pdfImgView.image = #imageLiteral(resourceName: "xls")
//            }else  {
//                pdfImgView?.image = #imageLiteral(resourceName: "text")
//            }
                if viewModelCell?.getPostedText.isEmpty ?? false {
                    postContentLabel.isHidden = true
                    pdfViewHeightConstraints.constant = 225
                }
                else{
                    postContentLabel.isHidden = false
                    pdfViewHeightConstraints.constant = 180
                }
//
                pdfImgView?.image = #imageLiteral(resourceName: "document_image")
                
                if isNft == 0{
                    nftImage.isHidden = true
                }
                else{
                    nftImage.isHidden = false
                }
            
            default:
                break
            }
            
            contentsImageView.setImage(
                url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
              placeholder: #imageLiteral(resourceName: "NoImage"))
        }
    }
    
    /// Tag button is used to show the pop tip of that current tag
    @IBAction func tagButtonTapped(sender: UIButton) {
        
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: viewModelCell?.getTagName ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: self.contentView)
    
      
    }
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playerController = AVPlayerViewController()
        easyTipViewSetUp()
        
        tagBgView.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0,1],
            size: CGSize(width: 50, height:50))
        
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentBgImgView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentBgImgView.addSubview(blurView)
        self.contentBgImgView.contentMode = .scaleAspectFill
    }
    
    /// Set the player instance to play the video with passing the url
    /// - Parameter url: Set the url here to play the video
    func playOrPauseVideo(url:String) {
        
        DispatchQueue.main.async {
//

            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            //let playerViewController = AVPlayerViewController()
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.playerController?.player = self.avplayer
            //self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.view.backgroundColor = .clear
            self.videoBgView.backgroundColor = .clear
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
           // self.playerController?.didMove(toParent: parent)
            
            
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }

        
    }
    
    
    /// Informs the observing object when the value at the specified key path relative to the observed object has changed.
    /// - Parameters:
    ///   - keyPath: The key path, relative to object, to the value that has changed.
    ///   - object: The source object of the key path keyPath.
    ///   - change: A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in Change Dictionary Keys.
    ///   - context: The value that was provided when the observer was registered to receive key-value observation notifications.
    ///    - For an object to begin sending change notification messages for the value at keyPath, you send it an addObserver(_:forKeyPath:options:context:) message, naming the observing object that should receive the messages. When you are done observing, and in particular before the observing object is deallocated, you send the observed object a removeObserver(_:forKeyPath:) or removeObserver(_:forKeyPath:context:) message to unregister the observer, and stop sending change notification messages.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if avplayer?.rate ?? 0.0 > 0 {
                print("video started")
                delegate?.getPlayVideoIndex(index: videoBgView.tag)
                
            }
        }
    }
    
    
    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerItem = nil
        self.playerController?.player?.pause()
        //self.playerLayer?.removeFromSuperlayer()
        
        //timer?.invalidate()
        //self.showControls()
    }
    
    
    /// Lays out subviews.
    ///  - T he default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews. Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly. You should not call this method directly. If you want to force a layout update, call the setNeedsLayout() method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded() method.
    override func layoutSubviews() {
        tagBtn.clipsToBounds = true
        tagBtn.layer.cornerRadius = 6
        
//        cellBackgroundView.layer.cornerRadius = 0
//        cellBackgroundView.clipsToBounds = true
        
        contentsImageView.contentMode = .scaleAspectFill
        contentsImageView.clipsToBounds = true
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 6.0
        iconImageView.layer.borderWidth = 0.5
        iconImageView.layer.borderColor = UIColor.clear.cgColor
        tagBtn.backgroundColor = UIColor.clear
    }
    
    static func isType() -> Bool {
        return true
    }

    /// Sets the selected state of the cell, optionally animating the transition between states.
    /// - Parameters:
    ///   - selected: true to set the cell as selected, false to set it as unselected. The default is false.
    ///   - animated: true to animate the transition between selected states, false to make the transition immediate.
    ///    - The selection affects the appearance of labels, image, and background. When the selected state of a cell is true, it draws the background for selected cells (Reusing cells) with its title in white.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    /// Set the pop tip setup here with the instance are noted
    func easyTipViewSetUp() {
        
        preferences.drawing.font = UIFont.MontserratMedium(.normal)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.textAlignment = NSTextAlignment.center
        preferences.drawing.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0,1],
            size: CGSize(width: 80, height:80)
        )
        
        preferences.drawing.arrowPosition = .bottom
        
        preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
        preferences.animating.showInitialAlpha = 0
        preferences.animating.showDuration = 1
        preferences.animating.dismissDuration = 1
        preferences.animating.dismissOnTap = true
    }
    
    
    
    /// Set a gradient color to use in background buttons and views
    /// - Parameters:
    ///   - colors: Multiple colors can be declared inside colors
    ///   - locations: From value of 0 - 1 to set the position of colors
    ///   - size: set the coolor for width and height for any of the view
    /// - Returns: It returns the UIColor to set on the view or buttons
    func linearGradientColor(from colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIColor {
        let image = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)).image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locations
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y:size.width),
                options:[]
            )
        }
        return UIColor(patternImage: image)
    }
}
