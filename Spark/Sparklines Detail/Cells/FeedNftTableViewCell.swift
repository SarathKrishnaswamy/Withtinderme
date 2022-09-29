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


protocol feedNftTableDelegate : AnyObject {
//    func rightButtonDetailsTapped(sender: UIButton)
//    func leftButtonDetailsTapped(sender: UIButton)
    func homeClap(sender: UIButton)
    func homeView(sender: UIButton)
    func tagButtonTapped(sender: UIButton)
    func profileButtonTapped(sender: UIButton)
    func profileButtonTapped(sender: UITapGestureRecognizer)
   // func contentViewDidSelect(sender: Int)
    
}

protocol getPlayerVideoAudioIndexDelegateNftForDetailPage : AnyObject{
    func videoPlayerFullScreenDismiss()
    
}

class FeedNftTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var iconImageView: customImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postContentLabel: UITextView!
    @IBOutlet weak var contentsImageView: customImageView!
    @IBOutlet weak var pdfImgView: UIImageView!
    @IBOutlet weak var tagBtn: UIButton!
    @IBOutlet weak var viewCountBtn: UIButton!
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var connectionCountBtn: UIButton!
    @IBOutlet weak var clapCountBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    @IBOutlet weak var videoBgView: UIView!
    
    @IBOutlet weak var bgViewForText: UIView!
   // @IBOutlet weak var txtViewForPost: UITextView!
    @IBOutlet weak var txtViewForPost: VerticallyCenteredTextView!
    
    @IBOutlet weak var txtLabl: UILabel!
    
    @IBOutlet weak var nfTImage: UIImageView!
    @IBOutlet weak var postTypeImgView: UIImageView!
    
    @IBOutlet weak var contentImageViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentImageBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var textBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var videoBgViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var viewImgBtn: UIButton!
    @IBOutlet weak var connectionImgBtn: UIButton!
    
    weak var feedNftTableDelegate : feedNftTableDelegate?
    @IBOutlet weak var contentBgImgView: UIImageView!
    
    
    
    @IBOutlet weak var monetizeView: Gradient!
    @IBOutlet weak var AudioAnimation: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var currencySymbol: UILabel!
    
    
    
    var avplayer : AVPlayer?
    var playerController : AVPlayerViewController? = nil
    
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    var timer: Timer?
    var timeObserver: Any?
    var isBuffering : Bool = false
    
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    var isSeekInProgress = false
    var activityView = UIActivityIndicatorView(style: .large)
    
    weak var videoFullScreenDelegate : getPlayerVideoAudioIndexDelegateForDetailPage?
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    
    /// Viewmodel cell setup with
    var viewModelCell:FeedDetailNftCellViewModel? {
        
        didSet {
            
//            if viewModelCell?.getClapCount ?? 0 > 0 && viewModelCell?.userId != SessionManager.sharedInstance.getUserId {
//                clapBtn.setImage(#imageLiteral(resourceName: "Clapped"), for: .normal)
//            }else {
                clapBtn.setImage(#imageLiteral(resourceName: "clap_gray"), for: .normal)
//            }
            
            if viewModelCell?.getViewCount ?? 0 > 0 {
                viewImgBtn.setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
            }else {
                viewImgBtn.setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
            }
        
            
            if viewModelCell?.getThreadCount ?? 0 > 0 {
                connectionImgBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
            }else {
                connectionImgBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
            }
            
            dateLabel.text = viewModelCell?.getPostedTime
            tagBtn.setTitle(viewModelCell?.getTagName, for: .normal)
            //viewcount
            if viewModelCell?.getViewCount ?? 0 > 0{
                
                viewCountBtn.setTitle("\(formatPoints(num: Double(viewModelCell?.getViewCount ?? 0)))", for: .normal)
            }
            else{
                viewCountBtn.setTitle("0", for: .normal)
            }
            //clap
            if viewModelCell?.getClapCount ?? 0 > 0{
                clapCountBtn.setTitle("\(formatPoints(num: Double(viewModelCell?.getClapCount ?? 0)))", for: .normal)
            }
            else{
                clapCountBtn.setTitle("0", for: .normal)
            }
            //connection
            if viewModelCell?.getThreadCount ?? 0 > 0{
                connectionCountBtn.setTitle("\(formatPoints(num: Double(viewModelCell?.getThreadCount ?? 0)))", for: .normal)
            }
            else{
                connectionCountBtn.setTitle("0", for: .normal)
            }
           
            if viewModelCell?.monetize == 1{
                
                if SessionManager.sharedInstance.saveCountryCode == "+91"{
                    self.currencySymbol.text = "₹"
                }
                else{
                    self.currencySymbol.text = "$"
                }
                monetizeView.isHidden = false
            }
            else{
                monetizeView.isHidden = true
            }
            
            
            
            tagBtn.addTarget(self, action: #selector(tagButtonTapped(sender: )), for: .touchUpInside)
            
            if viewModelCell?.isAnonymousUser == true {
                iconImageView.image = #imageLiteral(resourceName: "ananomous_user")
                titleLabel.text = "Anonymous User"
                
            }else {
                iconImageView.setImage(
                    url: URL.init(string: viewModelCell?.getProfileImage ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModelCell?.getGender == 1 ?  "no_profile_image_male" : viewModelCell?.getGender == 2 ? "no_profile_image_female" : "others"))
                
                
                titleLabel.text = viewModelCell?.getProfileName
            }
            
           // postContentLabel.text = viewModelCell?.getPostedText
            postContentLabel.isHidden = false
            
            if viewModelCell?.getPostedText.contains("http") ?? false || viewModelCell?.getPostedText.contains("https") ?? false || viewModelCell?.getPostedText.contains("www") ?? false {
                postContentLabel.isUserInteractionEnabled = true
            } else {
                postContentLabel.isUserInteractionEnabled = false
            }
            
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
                videoBgViewHeightConstraints.constant = 285//self.contentBgImgView.frame.height
                contentImageViewHeightConstraints.constant = 285
                contentImageBgViewHeightConstraints.constant = 285
            }else{
                postContentLabel.isHidden = true
                videoBgViewHeightConstraints.constant = 285 //self.contentBgImgView.frame.height
                contentImageViewHeightConstraints.constant = 285
                contentImageBgViewHeightConstraints.constant = 285
            }
            
            switch viewModelCell?.getMediaType {
                
            case MediaType.Text.rawValue:
                
              //  adjustContentSize(tv: txtViewForPost)
                contentBgImgView.isHidden = true
                bgViewForText.isHidden = false
                videoBgView.isHidden = true
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                postContentLabel.isHidden = true
                textBgViewHeightConstraints.constant = 285
                txtViewForPost.font = UIFont.MontserratMedium(.large)
                nfTImage.isHidden = true
                
                
                if viewModelCell?.getTextViewBgColor != ""{
                    
                    Helper.sharedInstance.loadTextIntoCells(text: viewModelCell?.getPostedText ?? "", textColor: viewModelCell?.getTextViewTxtColor ?? "", bgColor: viewModelCell?.getTextViewBgColor ?? "" , label: txtViewForPost, bgView: bgViewForText)
                }else{
                    Helper.sharedInstance.loadTextIntoCells(text: viewModelCell?.getPostedText ?? "", textColor: "FFFFFF", bgColor: "358383", label: txtViewForPost, bgView: bgViewForText)
                }
                
                
            case MediaType.Video.rawValue:
                
                contentBgImgView.isHidden = false
                bgViewForText.isHidden = true
                videoBgView.isHidden = false
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                AudioAnimation.isHidden = true
                
                videoBgViewHeightConstraints.constant = self.contentBgImgView.frame.height
                let isNft = viewModelCell?.getNft ?? 0
                if isNft == 0{
                    nfTImage.isHidden = true
                }
                else{
                    nfTImage.isHidden = false
                }
                contentBgImgView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedThumbnailUrl ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: UIImage(named: "NoImage"))
              
                playOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "")
                
            case MediaType.Image.rawValue:
                
                contentBgImgView.isHidden = false
                bgViewForText.isHidden = true
                videoBgView.isHidden = true
                contentsImageView.isHidden = false
                pdfImgView.isHidden = true
                AudioAnimation.isHidden = true
                
                
                let isNft = viewModelCell?.getNft ?? 0
                if isNft == 0{
                    nfTImage.isHidden = true
                }
                else{
                    nfTImage.isHidden = false
                }
                
                contentsImageView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: "NoImage"))
                
                contentBgImgView.setImage(
                    url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: UIImage(named: "NoImage"))
//
                
            case MediaType.Audio.rawValue:
                
                contentBgImgView.isHidden = false
                bgViewForText.isHidden = true
                videoBgView.isHidden = false
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                
                AudioAnimation.isHidden = false
                contentBgImgView.isHidden = true
                
                let isNft = viewModelCell?.getNft ?? 0
                if isNft == 0{
                    nfTImage.isHidden = true
                }
                else{
                    nfTImage.isHidden = false
                }
               
                playOrPauseAudio(url: viewModelCell?.getPostedMediaUrl ?? "")
                
            case MediaType.Document.rawValue:
                
                contentBgImgView.isHidden = true
                bgViewForText.isHidden = true
                videoBgView.isHidden = true
                contentsImageView.isHidden = true
                pdfImgView.isHidden = false
                
                AudioAnimation.isHidden = true
                
                
                let imageName = viewModelCell?.getPostedMediaUrl.components(separatedBy: ".")
                let isNft = viewModelCell?.getNft ?? 0
                if isNft == 0{
                    nfTImage.isHidden = true
                }
                else{
                    nfTImage.isHidden = false
                }
//                if imageName?.last == "pdf" {
//                    pdfImgView.image = #imageLiteral(resourceName: "pdf")
//                }else if imageName?.last == "ppt" {
//                    pdfImgView.image = #imageLiteral(resourceName: "ppt")
//                }else if imageName?.last == "docs" {
//                    pdfImgView.image = #imageLiteral(resourceName: "doc")
//                }else if imageName?.last == "doc" || imageName?.last == "docx" {
//                    pdfImgView.image = #imageLiteral(resourceName: "doc")
//                }else if imageName?.last == "xlsx" {
//                    pdfImgView.image = #imageLiteral(resourceName: "xls")
//                }else if imageName?.last == "xls" {
//                    pdfImgView.image = #imageLiteral(resourceName: "xls")
//                }else  {
//                    pdfImgView?.image = #imageLiteral(resourceName: "text")
//                }
                
                pdfImgView?.image = #imageLiteral(resourceName: "document_image")
                
            default:
                break
            }
            contentsImageView.setImage(
                url: URL.init(string: viewModelCell?.getPostedMediaUrl ?? "") ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: "NoImage"))
        }
    }
    
    
    /// Tag button tapped to set the poptip in the page
    @objc func tagButtonTapped(sender:UIButton) {
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: viewModelCell?.getTagName ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: contentView)
    }
    
    
   
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // playerController = AVPlayerViewController()
        
        easyTipViewSetUp()
        self.monetizeView.layer.cornerRadius = self.monetizeView.frame.width/2
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentBgImgView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentBgImgView.addSubview(blurView)
        
        self.contentBgImgView.contentMode = .scaleAspectFill
        let Lbltap = UITapGestureRecognizer(target: self, action: #selector(self.profileLblTap(_:)))
        titleLabel.addGestureRecognizer(Lbltap)
        self.titleLabel.isUserInteractionEnabled = true
        //self.fullScreenBtn.isHidden = true
    }
    
    
    
    /// It will show the count if its greater than '1000' and less than  '1000000' it will show K if its greater than 1000000 it will show M
    /// - Parameter num: Here we need to pass the double value of the count
    /// - Returns: It will return as string to append in the label
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))K")
            }
            return("\(thousandNum.roundToPlaces(places: 1))K")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))K")
            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }

    }
    
    
    /// Adjust the content size of ui text view with the view
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    
    
    // MARK: - Utilities
    
    /// Create a time as float and pass as string
    /// - Parameter time: Show the time as float method
    /// - Returns: It returns as string type.
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    
    
    /// Play or pause the video
    func playOrPauseVideo(url:String) {
        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            //let playerViewController = AVPlayerViewController()
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.playerController?.player = self.avplayer
            self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.view.backgroundColor = .clear
            self.videoBgView.backgroundColor = .clear
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }

       
    }
    
    
    /// Play or pause the audio
    func playOrPauseAudio(url:String) {
        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            //let playerViewController = AVPlayerViewController()
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.playerController?.player = self.avplayer
            self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.view.backgroundColor = .clear
            self.videoBgView.backgroundColor = .black
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
           // self.playerController?.didMove(toParent: parent)
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }

       
    }
    
    
    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerItem = nil
        self.playerController?.player?.pause()
       
        self.AudioAnimation.stopAnimatingGif()
        timer?.invalidate()
        
    }
    
    
    ///Lays out subviews.
    ///The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.
    ///Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.
    override func layoutSubviews() {
        tagView.clipsToBounds = true
        tagView.layer.cornerRadius = 6
        
       // contentsImageView.backgroundColor = .black
        
        contentsImageView.contentMode = .scaleAspectFit
        contentsImageView.clipsToBounds = true
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 6.0
        iconImageView.layer.borderWidth = 0.5
        iconImageView.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    /// Informs the observing object when the value at the specified key path relative to the observed object has changed.
    /// - Parameters:
    ///   - keyPath: The key path, relative to object, to the value that has changed.
    ///   - object: The source object of the key path keyPath.
    ///   - change: A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in Change Dictionary Keys.
    ///   - context: The value that was provided when the observer was registered to receive key-value observation notifications.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player?.rate ?? 0.0 > 0 {
                print("video started")
                //delegate?.getPlayVideoIndex(index: videoBgView.tag)
                
                
                
            }
        }
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
    
    /// It is a type to return boolean value
    /// - Returns: Here we will set the boolean value
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
    
    
    
    /// It is used to poptip the view to show the tag name in tip
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
    
    
    /// Calp button pressed to show the number of members clapped
    @IBAction func clapButtontapped(sender: UIButton) {
        feedNftTableDelegate?.homeClap(sender: sender)
        //print("Pressed")
        
       
    }
    
    
    /// View button is tapped to show the number of view count is updated here
    @IBAction func viewButtontapped(sender: UIButton) {
        feedNftTableDelegate?.homeView(sender: sender)
        
        
    }
    
//    @IBAction func tagButtontapped(sender: UIButton) {
//
//
//
//       }
    
    /// Profile image button tapped to open the current profile
    @IBAction func profileBtnTapped(sender:UIButton) {
        feedNftTableDelegate?.profileButtonTapped(sender: sender)
        
    }
    
    
    /// Profile image button tapped to open the current profile
    @objc func profileLblTap(_ sender: UITapGestureRecognizer? = nil){
       // let tag = sender?.view?.tag ?? 0
        feedNftTableDelegate?.profileButtonTapped(sender: sender ?? UITapGestureRecognizer())

    }
    
}
extension FeedNftTableViewCell: AVPlayerViewControllerDelegate {
    
    /// Tells the delegate when the player view controller is about to start full-screen display.
    /// - Parameters:
    ///   - playerViewController: The player view controller.
    ///   - coordinator: The transition coordinator to use when coordinating animations.

    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.videoFullScreenDelegate?.videoPlayerFullScreenDismiss()
    }

}


