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
import UIView_Shimmer


/**
 This protocol is used to set the fixed attributes and items for feed table delegate.
 - Call the home clap method in feed,
 - call home view method in the feed detail
 - Call tag button to open the tag in feed
 - Call the profile button tapped to open the connection list profile page
 */
protocol feedTableDelegate : AnyObject {
//    func rightButtonDetailsTapped(sender: UIButton)
//    func leftButtonDetailsTapped(sender: UIButton)
    func homeClap(sender: UIButton)
    func homeView(sender: UIButton)
    func tagButtonTapped(sender: UIButton)
    func profileButtonTapped(sender: UIButton)
    func profileButtonTapped(sender: UITapGestureRecognizer)
   // func contentViewDidSelect(sender: Int)
    
}

/// Call the socket method to listen the socket status, with post id, userid and link postid
protocol callSocketDelegate{
    func callSocket(postId: String, userId:String, linkPostId:String)
}

/// If i have more media get the media list and send here
protocol moreMediaDelegate{
    func openMediaList(sender: UIButton, postType:Int)
}


/// get the audio and playing index in each cell
protocol getPlayerVideoAudioIndexDelegateForDetailPage : AnyObject{
    func videoPlayerFullScreenDismiss()
    
}

/**
 This cell is used to set in the feed detail page with api calls and set the media type with views, claps and connections
 */
class FeedDetailTableViewCell: UITableViewCell,NetworkSpeedProviderDelegate,ShimmeringViewProtocol {
    
    /// Check the network status poor, good, diconnected with activity loader, if poor load the playeritem and playercontroller
    ///  - poor: Hide the activity loader
    ///   - Hide the internet view which integrated to player and it can be quitfullscreen
    ///  - If good: hide the activity loader and internet view is shown
    ///   - Handle the boolean value
    ///  - If disconnected: activity loader start animating, playerItem will be nil, pause the player controller, hide activity loader and show internet view
    func callWhileSpeedChange(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .poor:
            print("poor")
            print(Network.reachability.status)
            print("Reachable:", Network.reachability.isReachable)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.activityLoader.startAnimating()
                self.playerItem = nil
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player?.pause()
                self.playerController?.showsPlaybackControls = false
                self.videoBgView.bringSubviewToFront(self.activityLoader)
                self.videoBgView.bringSubviewToFront(self.NoInternetView)
                self.activityLoader.isHidden = true
                self.NoInternetView.isHidden = false
                self.playerController?.quitFullScreen()
                print(self.mediaUrl)
            }
            
            // self.test.networkSpeedTestStop()
            
            break
        case .good:
            //print("good")
            if isGoodConnectivity == true{
                DispatchQueue.main.async {
                    self.activityLoader.isHidden = true
                    self.NoInternetView.isHidden = false
                    self.isGoodConnectivity = false
                }
                
            }
           
            
            break
        case .disConnected:
            print("disconnected")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.activityLoader.startAnimating()
                self.playerItem = nil
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player?.pause()
                self.playerController?.showsPlaybackControls = false
                self.videoBgView.bringSubviewToFront(self.activityLoader)
                self.videoBgView.bringSubviewToFront(self.NoInternetView)
                self.activityLoader.isHidden = true
                self.NoInternetView.isHidden = false
                self.playerController?.quitFullScreen()
            }
            break
        }
    }
    
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
    @IBOutlet weak var txtViewForPost: VerticalTextView!
    
    @IBOutlet weak var txtLabl: UILabel!
    
    @IBOutlet weak var nfTImage: UIImageView!
    @IBOutlet weak var postTypeImgView: UIImageView!
    
    @IBOutlet weak var contentImageViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentImageBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var textBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var videoBgViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var viewImgBtn: UIButton!
    @IBOutlet weak var connectionImgBtn: UIButton!
    
    weak var feedTableDelegate : feedTableDelegate?
    var morefeedTableDelegate : moreMediaDelegate?
    @IBOutlet weak var contentBgImgView: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    
    
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var AudioAnimation: UIImageView!
    @IBOutlet weak var shareBtn: UIImageView!
    @IBOutlet weak var NoInternetView: UIStackView!
    
    
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!
    @IBOutlet weak var dummyView4: UIView!
    @IBOutlet weak var dummyView5: UIView!
    @IBOutlet weak var dummyView6: UIView!
    @IBOutlet weak var dummyView7: UIView!
    @IBOutlet weak var dummyView8: UIView!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var mosaicView: UIView!
    @IBOutlet weak var mosaicViewCount: UIButton!
    @IBOutlet weak var monetizeView: Gradient!
    @IBOutlet weak var CurrencySymbolLbl: UILabel!
    
    
    
    
    
    var textView : VerticalTextView!
    var avplayer : AVPlayer?
    var playerController : AVPlayerViewController? = nil
    var isGoodConnectivity = false
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    var timer: Timer?
    var timeObserver: Any?
    var mediaUrl = String()
    let test = NetworkSpeedTest()
    var mediaType = Int()
    private var playerItemStatusObserver: NSKeyValueObservation?
    var isFullscreen = false
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    
    weak var videoFullScreenDelegate : getPlayerVideoAudioIndexDelegateForDetailPage?
    var backtoFeedDelegate : backfromFeedDelegate?
    var socketDelagete : callSocketDelegate?
    
    var myPostId = ""
    var myThreadId = ""
    var myUserId = ""
    var isFromLoop = false
    var isFromNotification = false
    var linkPostId = ""
    
    var isSeekInProgress = false
    var isFromNotify = false
    var isFromHomePage = false
    var isFromBubble = false
    var totalMedia = 0
    var isMonetize = 0
    var isThreadId = 0
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3,
            dummyView4,
            dummyView5,
            dummyView6,
            dummyView7,
            dummyView8

        ]
    }
    
    
    /// Viewmodel cell get the view count , get the thread count,
    /// - Get the posted time, Get tag name and get view count, get clap count.
    ///  - If monetize 1 then show monetize icon
    ///  - Else hide monetize icon
    ///  - Set the currency symbol
    ///  - tag button is used to press and open the poptip
    ///  - Set the profile image
    ///  - Set the post type image,
    ///  - Set the mediatype according to the viewmodel cell
    ///  - Set image background as blur view
    var viewModelCell:FeedDetailTableViewCellViewModel? {
        
        didSet {
            //self.textView.verticalAlignment = .Middle
            
//            if viewModelCell?.getClapCount ?? 0 > 0 && viewModelCell?.userId != SessionManager.sharedInstance.getUserId {
//                clapBtn.setImage(#imageLiteral(resourceName: "Clapped"), for: .normal)
//            }else {
                clapBtn.setImage(#imageLiteral(resourceName: "clap_gray"), for: .normal)
//            }
            
            if viewModelCell?.getViewCount ?? 0 > 0 {
                viewImgBtn.setImage(#imageLiteral(resourceName: "viewed"), for: .normal)
            }else {
                viewImgBtn.setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
            }
        
            
            if viewModelCell?.getThreadCount ?? 0 > 0 {
                connectionImgBtn.setImage(#imageLiteral(resourceName: "Connection_Fill"), for: .normal)
            }else {
                connectionImgBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
            }
            
            dateLabel.text = viewModelCell?.getPostedTime
            tagBtn.setTitle(viewModelCell?.getTagName, for: .normal)
            
            if viewModelCell?.getViewCount ?? 0 > 0{
                
                viewCountBtn.setTitle("\(viewModelCell?.getViewCount ?? 0)", for: .normal)
            }
            else{
                viewCountBtn.setTitle("0", for: .normal)
            }
            if viewModelCell?.getClapCount ?? 0 > 0{
                clapCountBtn.setTitle("\(viewModelCell?.getClapCount ?? 0)", for: .normal)
            }
            else{
                clapCountBtn.setTitle("0", for: .normal)
            }
            if viewModelCell?.getThreadCount ?? 0 > 0{
                connectionCountBtn.setTitle("\(viewModelCell?.getThreadCount ?? 0)", for: .normal)
            }
            else{
                connectionCountBtn.setTitle("0", for: .normal)
            }
            
            if viewModelCell?.monetize == 1{
                monetizeView.isHidden = false
            }
            else{
                monetizeView.isHidden = true
            }
            
            self.CurrencySymbolLbl.text = viewModelCell?.currencySymbol
            
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
            
            postContentLabel.text = viewModelCell?.getPostedText
            postContentLabel.isHidden = false
            
            if viewModelCell?.getPostedText.contains("http") ?? false || viewModelCell?.getPostedText.contains("https") ?? false || viewModelCell?.getPostedText.contains("www") ?? false {
                postContentLabel.isUserInteractionEnabled = true
            } else {
                postContentLabel.isUserInteractionEnabled = true
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
                //postContentLabel.isHidden = false
                videoBgViewHeightConstraints.constant = self.contentBgImgView.frame.height
                contentImageViewHeightConstraints.constant = 230
                contentImageBgViewHeightConstraints.constant = 230
            }
            
            switch viewModelCell?.getMediaType {
                
            case MediaType.Text.rawValue:
                
                
                txtViewForPost.verticalAlignment = .Middle
                
              //  adjustContentSize(tv: txtViewForPost)
                //txtViewForPost.centerVerticalText()
                
                contentBgImgView.isHidden = true
                bgViewForText.isHidden = false
                videoBgView.isHidden = true
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                postContentLabel.isHidden = true
                textBgViewHeightConstraints.constant = 285
                txtViewForPost.font = UIFont.MontserratMedium(.large)
                nfTImage.isHidden = true
               
                AudioAnimation.isHidden = true
                
                
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
                self.mediaType = 3
                if viewModelCell?.getPostedText.isEmpty ?? false {
                    videoBgViewHeightConstraints.constant = 285//
                }
                else{
                    videoBgViewHeightConstraints.constant = 230
                }
                print("**************************")
                print(self.contentBgImgView.frame.height)
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
                self.playerItem = nil
                //self.playerController?.view.backgroundColor = .black
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player = nil
                playOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "", parent: FeedDetailsViewController(), play: false)
                
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
                
                contentBgImgView.isHidden = true
                bgViewForText.isHidden = true
                videoBgView.isHidden = false
                contentsImageView.isHidden = true
                pdfImgView.isHidden = true
                AudioAnimation.isHidden = false
                if viewModelCell?.getPostedText.isEmpty ?? false {
                    videoBgViewHeightConstraints.constant = 285//
                }
                else{
                    videoBgViewHeightConstraints.constant = 230
                }
                
                let isNft = viewModelCell?.getNft ?? 0
                if isNft == 0{
                    nfTImage.isHidden = true
                }
                else{
                    nfTImage.isHidden = false
                }
                self.mediaType = 4
                self.playerItem = nil
                //self.playerController?.view.backgroundColor = .black
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player = nil
                //AudioplayOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "", Type: MediaType.Audio.rawValue)
                AudioplayOrPauseVideo(url: viewModelCell?.getPostedMediaUrl ?? "", parent: FeedDetailsViewController(), play: false)
                
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
    
    /// tag button tapped to open the pop tip of tag button
    @objc func tagButtonTapped(sender:UIButton) {
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: viewModelCell?.getTagName ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: contentView)
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
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // playerController = AVPlayerViewController()
        monetizeView.layer.cornerRadius = monetizeView.frame.width/2
        self.NoInternetView.isHidden = true
        self.activityLoader.isHidden = true
        
        easyTipViewSetUp()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentBgImgView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentBgImgView.addSubview(blurView)
        
        
//        let blurEffect1 = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurView1 = UIVisualEffectView(effect: blurEffect1)
//        blurView1.alpha = 0.8
//        blurView1.frame = mosaicView.bounds
//        blurView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        mosaicView.addSubview(blurView1)
        
        mosaicView.layer.cornerRadius = mosaicView.frame.width/2
        mosaicView.layer.borderColor = UIColor.white.cgColor
        mosaicView.layer.borderWidth = 0
        mosaicView.backgroundColor = .clear
        
       
        
        self.contentBgImgView.contentMode = .scaleAspectFill
        let Lbltap = UITapGestureRecognizer(target: self, action: #selector(self.profileLblTap(_:)))
        titleLabel.addGestureRecognizer(Lbltap)
        self.titleLabel.isUserInteractionEnabled = true
        
//
        
    }
    
    
    func showDummy(){
        
        dummyView1.isHidden = false
        dummyView2.isHidden = false
        dummyView3.isHidden = false
        dummyView4.isHidden = false
        dummyView5.isHidden = false
        dummyView6.isHidden = false
        dummyView7.isHidden = false
        dummyView8.isHidden = false
        cellBackgroundView.isHidden = true
        playBtn.isHidden = true
        
        
    }
    
    func hideDummy(){
        dummyView1.isHidden = true
        dummyView2.isHidden = true
        dummyView3.isHidden = true
        dummyView4.isHidden = true
        dummyView5.isHidden = true
        dummyView6.isHidden = true
        dummyView7.isHidden = true
        dummyView8.isHidden = true
        cellBackgroundView.isHidden = false
        playBtn.isHidden = true
    }
    
    
    
    
   
    
    
    /// Adjust the content size with textview to be vertical
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    
    
    /// create a time string with float value to be return as string
    // MARK: - Utilities
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    /// Play or pause the video using url with parent view controller and play ising bool value
    func playOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            //let playerViewController = AVPlayerViewController()
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.playerController?.player = self.avplayer
            self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.view.backgroundColor = .clear
            self.playerController?.showsPlaybackControls = false
            self.playBtn.isHidden = false
            (self.playerController?.view.subviews.first?.subviews.first as? UIImageView)?.image = nil
            self.videoBgView.backgroundColor = .clear
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
            if play{
                self.playerController?.player?.play()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController?.player?.currentItem)
            self.avplayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    
    ///  Audio player to pause or play the audio using url string with parent view controller and play
    func AudioplayOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async {
//

            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            //let playerViewController = AVPlayerViewController()
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.playerController?.player = self.avplayer
            self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.view.backgroundColor = .clear
            self.playerController?.showsPlaybackControls = false
            self.playBtn.isHidden = false
           // self.avplayer?.currentItem?.preferredPeakBitRate = 100000.000000
            self.videoBgView.backgroundColor = .black
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
            //self.playerController?.didMove(toParent: parent)
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController?.player?.currentItem)
            self.avplayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    
    /// After video or audio ended it starts from 0 seconds
    @objc func videoDidEnded (){
        playerController?.dismiss(animated: true,completion: nil)
        self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
    }
    
    
    /// Retry button used to reload the player to play and check whether inter is there or not.
    @IBAction func retryBtnOnPressed(_ sender: Any) {
        if mediaType == 3{
            // false is making good connectivity
            if isGoodConnectivity == false{
                print(NetworkStatus.good)
                self.activityLoader.isHidden = true
                self.activityLoader.stopAnimating()
                self.playerController?.showsPlaybackControls = true
                self.NoInternetView.isHidden = true
                self.playOrPauseVideo(url: self.mediaUrl, parent: FeedDetailsViewController(), play: true)
               
                
               
                
            }
            else{
                self.NoInternetView.isHidden = true
                self.activityLoader.isHidden = false
                self.activityLoader.startAnimating()
                self.test.networkSpeedTestStop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
                }
                //
            }
        }
        else if mediaType == 4{
            // false is making good connectivity
            if isGoodConnectivity == false{
                print(NetworkStatus.good)
                self.activityLoader.isHidden = true
                self.activityLoader.stopAnimating()
                self.playerController?.showsPlaybackControls = true
                self.NoInternetView.isHidden = true
                self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
                self.AudioplayOrPauseVideo(url: mediaUrl, parent: HomeViewController(), play: true)
                
            }
            else{
                self.NoInternetView.isHidden = true
                self.activityLoader.isHidden = false
                self.activityLoader.startAnimating()
                self.test.networkSpeedTestStop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
                }
                //
            }
        }
    }
    
   
    
    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerItem = nil
        self.player?.pause()
        
    }
    
    
    /// Lays out subviews.
    ///  - The default implementation of this method does nothing on iOS 5.1 and earlier. Otherwise, the default implementation uses any constraints you have set to determine the size and position of any subviews.
    /// Subclasses can override this method as needed to perform more precise layout of their subviews. You should override this method only if the autoresizing and constraint-based behaviors of the subviews do not offer the behavior you want. You can use your implementation to set the frame rectangles of your subviews directly.
    /// You should not call this method directly. If you want to force a layout update, call the setNeedsLayout() method instead to do so prior to the next drawing update. If you want to update the layout of your views immediately, call the layoutIfNeeded() method.
    override func layoutSubviews() {
        
        txtViewForPost.verticalAlignment = .Middle
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
            if avplayer?.rate ?? 0.0 > 0 {
                print("video started")
                self.playerController?.showsPlaybackControls = true
            }
            else{
                
            }
        }
        
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            if #available(iOS 10.0, *) {
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                if newStatus != oldStatus {
                    DispatchQueue.main.async {[weak self] in
                        if newStatus == .paused{
                            if self?.totalMedia ?? 0 > 0 && self?.isMonetize == 3{
                                self?.mosaicView.isHidden = false
                            }
                            else{
                                self?.mosaicView.isHidden = true
                            }
                        }
                        else if newStatus == .playing{
                            self?.mosaicView.isHidden = true
                        }
                        
                        if newStatus == .playing || newStatus == .paused {
                            print("stop animating")
                            if self?.isFullscreen == true{
                               
                                Spinner.stop()
                                
                            }
                            else{
                                self?.activityLoader.isHidden = true
                            }
                            
                            
                        
                        } else {
                            print("Start animating")
                            if self?.isFullscreen == true{
                                Spinner.start()
//
                            }
                            else{
                                self?.activityLoader.isHidden = false
                                self?.activityLoader.startAnimating()
                            }
                            

                        }
                    }
                }
            } else {
                if self.isFullscreen == true{
                    Spinner.stop()
                   
                }
                else{
                    self.activityLoader.isHidden = true
                }
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
    
    ///
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
    
    
    /// Clap tapped to call clapped members
    @IBAction func clapButtontapped(sender: UIButton) {
        feedTableDelegate?.homeClap(sender: sender)
        //print("Pressed")
        
       
    }
    
    /// View Button tapped to open the members views the post
    @IBAction func viewButtontapped(sender: UIButton) {
        feedTableDelegate?.homeView(sender: sender)
        
        
    }
    
    @IBAction func tagButtontapped(sender: UIButton) {
        
           
        
       }
    
    /// Profile button is tapped to open the prrofile image
    @IBAction func profileBtnTapped(sender:UIButton) {
        feedTableDelegate?.profileButtonTapped(sender: sender)
        
    }
    
    
    /// Play button is tapped to play the video
    @IBAction func playBtnOnPressed(_ sender: Any) {
        
        if Connection.isConnectedToNetwork(){
            self.playBtn.isHidden = true
            self.activityLoader.isHidden = false
            self.activityLoader.startAnimating()
            self.mosaicView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.avplayer?.play()
                //self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            }
        }
        else{
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
        }
    }
    
    
    /// Profile Lbl name tapped to open connectionlist user
    @objc func profileLblTap(_ sender: UITapGestureRecognizer? = nil){
       // let tag = sender?.view?.tag ?? 0
        feedTableDelegate?.profileButtonTapped(sender: sender ?? UITapGestureRecognizer())

    }
    
    
    /// If we have more medias we can by pressing ;list all feeds
    @IBAction func ListAllFeedsmonetizeBtnOnPressed(_ sender: UIButton) {
        morefeedTableDelegate?.openMediaList(sender:sender, postType: viewModelCell?.getPostType ?? 0)
    }
    
    
}
extension FeedDetailTableViewCell: AVPlayerViewControllerDelegate {

    /// Will begin for full sscreen page
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.isFullscreen = true
        self.videoFullScreenDelegate?.videoPlayerFullScreenDismiss()
    }

    /// Will end the fullscreen in video audio player
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { transitionContext in
            self.isFullscreen = false
            
            //self.socketDelagete?.callSocket(postId: self.myPostId, userId: self.myUserId, linkPostId:self.linkPostId)
            self.backtoFeedDelegate?.back(postId: self.myPostId, threadId: self.myThreadId, userId: self.myUserId, memberList: [MembersList](), messageListApproved: false, isFromLoopConversation: self.isFromLoop, isFromNotify: self.isFromNotification, isFromHome: self.isFromHomePage, isFromBubble: self.isFromBubble, isThread: self.isThreadId, linkPostId: self.linkPostId)
            //self.playerController?.player?.play()
        }
        
    }
    
}



