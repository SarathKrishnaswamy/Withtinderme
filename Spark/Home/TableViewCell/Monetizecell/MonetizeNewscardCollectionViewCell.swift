//
//  MonetizeNewscardCollectionViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 04/08/22.
//

import UIKit
import Lottie
import AVKit
import LRSpotlight
import SwiftyGif
import UIView_Shimmer
import Reachability
import ProgressHUD
import RSLoadingView

/**
 This cell is used to set the monetize post in home view page and feed search page which is mentioned as monetize symbol and nft
 */
class MonetizeNewscardCollectionViewCell: UICollectionViewCell, CAAnimationDelegate,ShimmeringViewProtocol, NetworkSpeedProviderDelegate, UIGestureRecognizerDelegate {

    
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
            print("Upload failed")
            //print("Reachable:", Network.reachability.isReachable)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.activityLoader.startAnimating()
                self.playerItem = nil
                self.playBtn.isHidden = true
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player = nil
                self.playerController?.showsPlaybackControls = false
                self.videoBgView.bringSubviewToFront(self.activityLoader)
                self.videoBgView.bringSubviewToFront(self.noInternetView)
                self.activityLoader.isHidden = true
                self.noInternetView.isHidden = false
                if self.isFullscreen{
                    Spinner.start()
                }
                //self.playerController?.quitFullScreen()
                self.isGoodConnectivity = true
                print(self.mediaUrl)
            }
            
            // self.test.networkSpeedTestStop()
            
            break
        case .good:
            //print("good")
            if isGoodConnectivity == true{
                DispatchQueue.main.async {
                    self.activityLoader.isHidden = true
                    self.noInternetView.isHidden = false
                    self.isGoodConnectivity = false
                }
                
            }
           
            
            break
        case .disConnected:
            print("disconnected")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.activityLoader.startAnimating()
                self.playerItem = nil
                self.playBtn.isHidden = true
                self.playerController?.player?.pause()
                self.playerController?.view.removeFromSuperview()
                self.playerController?.removeFromParent()
                self.playerController?.player = nil
                self.playerController?.showsPlaybackControls = false
                self.videoBgView.bringSubviewToFront(self.activityLoader)
                self.videoBgView.bringSubviewToFront(self.noInternetView)
                self.activityLoader.isHidden = true
                self.noInternetView.isHidden = false
                self.playerController?.quitFullScreen()
                self.isGoodConnectivity = true
                
            }
            break
        }
    }
    
    
    @IBOutlet weak var leftView:UIView!
    @IBOutlet weak var rightView:UIView!
    @IBOutlet weak var retryBtn:UIButton!
    
    // image cell objects
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var contentsImageView: customImageView!
    
    @IBOutlet weak var pdfImgView: customImageView!
    
    
    
    @IBOutlet var animationBgView:UIView!
    
    @IBOutlet weak var videoBgView: UIView!
    
    @IBOutlet weak var bgViewForText: UIView!
    
    @IBOutlet weak var nftImage: UIImageView!
    
    weak var delegate:getPlayerVideoAudioIndexDelegate?
    
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var loopLimitStackView: UIStackView!
    @IBOutlet weak var audioAnimationBg: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var monetizeView: UIView!
    @IBOutlet weak var currencySymbol: UILabel!
    
    
    // @IBOutlet weak var Activityindicator: UIActivityIndicatorView!
    
    var animationHomeView: AnimationView?
    
    var avplayer : AVPlayer?
    var playerController : AVPlayerViewController? = nil
    var playToggle = 1
    var audioPlayToggle = 1
    var timeObserver: Any?
    var timer: Timer?
    
    var mediaUrl = String()
    var isGoodConnectivity = false
    var isFullscreen = false
    var isReuse = false
    var hud: ProgressHUD = ProgressHUD()
    var isviewed = false
    
    
    @IBOutlet weak var contentsImageViewHeightConstraints: NSLayoutConstraint!
    
    //content cell objects
    
    @IBOutlet weak var iconImageView: customImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var postContentLabel: UITextView!
    @IBOutlet weak var tagBtn: UIButton!
    @IBOutlet weak var viewCountBtn: UIButton!
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var connectionCountBtn: UIButton!
    @IBOutlet weak var connectionBtn: UIButton!
    @IBOutlet weak var clapCountBtn: UIButton!
    @IBOutlet weak var viewBtn: UIButton!
    
    @IBOutlet weak var viewImg: UIImageView!
    @IBOutlet weak var connectionImg: UIImageView!
    @IBOutlet weak var clapImg: UIImageView!
    
    @IBOutlet weak var connectionThreadLimitLbl: UILabel!
    @IBOutlet weak var postTypeImgView: UIImageView!
    
    // weak var clapDelegate : homeClapsDelegate?
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var contentBgView: UIView!
    @IBOutlet weak var rightViewBtn: UIButton!
    @IBOutlet weak var rightViewClapImgView: UIImageView!
    @IBOutlet weak var rightViewClapDescLbl: UILabel!
    
    
    @IBOutlet weak var leftViewBtn: UIButton!
    @IBOutlet weak var leftViewClapImgView: UIImageView!
    @IBOutlet weak var leftViewClapDescLbl: UILabel!
    
  
    
    
    weak var collectionDelegate : collectionDelegate?
    
    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var contentLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var contentBgImgView: UIImageView!
    @IBOutlet weak var noInternetView: UIStackView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var loopimage: UIImageView!
    
    
    
    ///DummyView is used to load the shimmering views
    
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!
    @IBOutlet weak var dummyView4: UIView!
    @IBOutlet weak var dummyView5: UIView!
    @IBOutlet weak var dummyView6: UIView!
    @IBOutlet weak var dummyView7: UIView!
    @IBOutlet weak var dummyView8: UIView!
//    @IBOutlet weak var dummyView9: UIView!
//    @IBOutlet weak var dummyView10: UIView!
//    @IBOutlet weak var dummyView11: UIView!
//
    
    let test = NetworkSpeedTest()
    var mediaType = Int()
    var monetize = Int()
    //let network: Network = Network.sharedInstance
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3,
            dummyView4,
            dummyView5,
            dummyView6,
            dummyView7,
            dummyView8,
            cellBackgroundView

        ]
    }
    
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var isSeekInProgress = false
    var activityView = UIActivityIndicatorView(style: .large)
    var isBuffering : Bool = false
    var activityIndicator: UIActivityIndicatorView?
    
    
    
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    var playbackLikelyToKeepUpObserver: NSKeyValueObservation?
    var isAudio = false
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
        self.leftView.isHidden = true
        self.rightView.isHidden = true
        self.activityLoader.isHidden = true
        //self.activityLoader.stopAnimating()
        self.noInternetView.isHidden = true
        self.retryBtn.layer.cornerRadius = 4.0
        self.retryBtn.layer.borderWidth = 1.0
        self.retryBtn.layer.borderColor = UIColor.white.cgColor
        
        leftView.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0, 1],
            size: CGSize(width: 700, height:700)
        )
        
        rightView.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0, 1],
            size: CGSize(width: 700, height:700)
        )
        //self.monetizeView.backgroundColor = linearGradientColor(from: [.splashStartColor, .splashEndColor],locations: [0, 1],size: CGSize(width: 700, height:700))
        
        self.monetizeView.layer.cornerRadius = self.monetizeView.frame.width/2
        
        print("***********************************")
        print(monetize)
        
        
        //if monetize != 1{
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight(gesture:)))
        rightSwipe.direction = .right
        self.contentView.addGestureRecognizer(rightSwipe)
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft(gesture:)))
        leftSwipe.direction = .left
        self.contentView.addGestureRecognizer(leftSwipe)
            //self.contentView.addGestureRecognizer(swipeLeft)
        //}
       
        
        //  playerController = AVPlayerViewController()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.contentViewTapped(_:)))
        contentBgView.addGestureRecognizer(tap)
        
        let Lbltap = UITapGestureRecognizer(target: self, action: #selector(self.profileLblTap(_:)))
        titleLabel.addGestureRecognizer(Lbltap)
        self.titleLabel.isUserInteractionEnabled = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentBgImgView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentBgImgView.addSubview(blurView)
        
        
    }
    
    
    /// Show the activity indicator view here
    func showActivityIndicatory() {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear
        
        activityView.style = .white
        activityView.center = self.videoBgView.center
        
        container.addSubview(activityView)
        self.videoBgView.addSubview(container)
        activityView.startAnimating()
    }
    
    /// Hide the activity indicator view when its loading
    func hideActivityIndicator(){
        activityView.stopAnimating()
        activityView.isHidden = true
    }
    
    
    /// Show all the dummy views and hide all other objects
    func showDummy(){
        self.dummyView1.isHidden = false
        self.dummyView2.isHidden = false
        self.dummyView3.isHidden = false
        self.dummyView4.isHidden = false
        self.dummyView5.isHidden = false
        self.dummyView6.isHidden = false
        self.dummyView7.isHidden = false
        self.dummyView8.isHidden = false

        
        
        self.iconImageView.isHidden = true
        self.viewImg.isHidden = true
        self.connectionImg.isHidden = true
        self.clapImg.isHidden = true
        self.loopimage.isHidden = true
        self.nftImage.isHidden = true
        self.tagBtn.isHidden = true
        self.viewCountBtn.isHidden = true
        self.connectionThreadLimitLbl.isHidden = true
        self.contentLblHeightConstraints.constant = 51
        self.titleLabel.isHidden = true
        self.clapCountBtn.isHidden = true
        self.connectionCountBtn.isHidden = true
        self.dateLabel.isHidden = true
        self.postTypeImgView.isHidden = true
        self.postContentLabel.isHidden = true
        self.playBtn.isHidden = true
        self.activityLoader.isHidden = true
        self.monetizeView.isHidden = true
    
    }

    
    
    /// Hide all the dummy views and show all other objects
    func hideDummy(){

        self.dummyView1.isHidden = true
        self.dummyView2.isHidden = true
        self.dummyView3.isHidden = true
        self.dummyView4.isHidden = true
        self.dummyView5.isHidden = true
        self.dummyView6.isHidden = true
        self.dummyView7.isHidden = true
        self.dummyView8.isHidden = true
        
        self.iconImageView.isHidden = false
        self.viewImg.isHidden = false
        self.connectionImg.isHidden = false
        self.clapImg.isHidden = false
        self.loopimage.isHidden = false
        self.nftImage.isHidden = false
        self.tagBtn.isHidden = false
        self.viewCountBtn.isHidden = false
        self.connectionThreadLimitLbl.isHidden = false
        self.titleLabel.isHidden = false
        self.clapCountBtn.isHidden = false
        self.connectionCountBtn.isHidden = false
        self.dateLabel.isHidden = false
        self.postTypeImgView.isHidden = false
        self.postContentLabel.isHidden = false
        self.playBtn.isHidden = true
        self.activityLoader.isHidden = true
        self.monetizeView.isHidden = false
    }
    
    
    
    
    /// Content view tapped to open the delegate of current view to feed detial page
    
    @objc func contentViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        collectionDelegate?.contentViewDidSelect(sender: contentBgView.tag)
    }
    
    /// After swiping clicked on right button to clap the post
    @IBAction func rightViewButtonTapped(_ sender: UIButton) {
        self.rightView.isHidden = true
        collectionDelegate?.rightButtonDetailsTapped(sender: sender)
    }
    
   
    /// On pressing the profile button open the other user profile page
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        
        collectionDelegate?.profileButtonSelection(sender: sender.tag)
    }
    
    /// On pressing the name label  profile button open the other user profile page
    @objc func profileLblTap(_ sender: UITapGestureRecognizer? = nil){
        let tag = sender?.view?.tag ?? 0
        collectionDelegate?.profileButtonSelection(sender:tag)
        
    }
    
    
    /// Play or pause the video using the url link with initialize the player
    /// - Observe the player to empty buffer, playback buffer, playingkeep up
    func playOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async { [self] in
            self.isAudio = false
            self.test.delegate = self
            self.test.networkSpeedTestStop()
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            self.loadingLbl.text = "Video loading failed"
            //let urls = "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"
            
            //
            
            self.playerItem = AVPlayerItem(url: URL(string: url) ?? URL(fileURLWithPath: ""))
            self.playerController = AVPlayerViewController()
            self.avplayer = AVPlayer(playerItem: self.playerItem)
            self.avplayer?.automaticallyWaitsToMinimizeStalling = true
            self.playerController?.player = self.avplayer
            self.playerController?.allowsPictureInPicturePlayback = true
            self.playerController?.delegate = self
            self.playerController?.view.frame = self.videoBgView.bounds
            self.playerController?.showsPlaybackControls = false
            
            self.playBtn.isHidden = false
           // self.playerController?.allowsPictureInPicturePlayback = true
            self.playerController?.view.backgroundColor = .clear
            (self.playerController?.view.subviews.first?.subviews.first as? UIImageView)?.image = nil
            self.videoBgView.backgroundColor = .clear
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect

            //self.playerItem?.preferredPeakBitRate = 837000
            if play{
                self.playBtn.isHidden = true
                self.playerController?.showsPlaybackControls = true
                self.playerController?.player?.play()
            }
            self.avplayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            playerController?.contentOverlayView!.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//            tapGesture.delegate = self
//            videoBgView.addGestureRecognizer(tapGesture)
            //self.playerController?.didMove(toParent: parent)
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController?.player?.currentItem)
            //NotificationCenter.default.addObserver(self, selector: #selector(playerStalled(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.player?.currentItem)
            //ProgressHUD.showProgress(0.42)
           
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            self.noInternetView.isHidden = true
            
            
            
            
            
            playbackBufferEmptyObserver = self.playerItem?.observe(\.isPlaybackBufferEmpty, options: [.new, .initial ], changeHandler: { [weak self] (player, bufferEmpty) in

                if let self = self {
                    DispatchQueue.main.async {
                        if bufferEmpty.newValue == true {
                            // handle showing loading, player not playing
                            //print("showing loading")
                            self.activityLoader.isHidden = false
                            self.activityLoader.startAnimating()
                        }
                    }
                }
            })

            playbackBufferFullObserver = self.playerItem?.observe(\.isPlaybackBufferFull, options: [.new, .initial], changeHandler: {[weak self] (player, bufferFull) in
                if let self = self {
                    DispatchQueue.main.async {
                        if bufferFull.newValue == true {
                           // print("hide loading")
                            self.activityLoader.isHidden = true
                            //handle when player buffer is full (e.g. hide loading) start player
                        }
                    }
                }
            })

            playbackLikelyToKeepUpObserver = self.playerItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .initial], changeHandler: { [weak self] (player, _) in
                if let self = self {
                    if ((self.playerItem?.status ?? AVPlayerItem.Status.unknown)! == .readyToPlay) {
                        self.activityLoader.isHidden = true
                        //self.playerController?.player?.play()
                        //self.playerController?.showsPlaybackControls = true
                        //print("hide loading keepUp")
                        //  handle that player is  ready to play (e.g. hide loading indicator, start player)
                    } else {
                        //print("Show loading keepUp")
                        self.activityLoader.isHidden = false
                        self.activityLoader.startAnimating()
                        //self.playerController?.player?.pause()
                     //   self.playerController?.showsPlaybackControls = false
                        //  player is not ready to play yet
                    }
                }
            })
            
            //print(self.playerItem?.asset.isPlayable)
            
        }
        
        

    }
    
    
    
    
    
   
    /// Informs the observing object when the value at the specified key path relative to the observed object has changed.
    /// - Parameters:
    ///   - keyPath: The key path, relative to object, to the value that has changed.
    ///   - object: The source object of the key path keyPath.
    ///   - change: A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in Change Dictionary Keys.
    ///   - context: The value that was provided when the observer was registered to receive key-value observation notifications.
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if avplayer?.rate ?? 0.0 > 0 {
                print("video started")
                self.playerController?.showsPlaybackControls = true
                self.playBtn.isHidden = true
                self.noInternetView.isHidden = true
                self.isReuse = false
                ProgressHUD.dismiss()
                
                // print(self.avplayer?.currentItem?.preferredPeakBitRate)
                delegate?.getPlayVideoIndex(index: videoBgView.tag)
                
            }
        }
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            if #available(iOS 10.0, *) {
                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                if newStatus != oldStatus {
                    DispatchQueue.main.async {[weak self] in
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
    
    
    /// Remove the player from the view
    func playerRemove(){
        self.playerItem = nil
        self.playerController?.player?.pause()
        self.playerController?.view.removeFromSuperview()
        self.playerController?.removeFromParent()
        self.playerController?.player = nil
        
    }
    
    
    /// Play button is tapped to play the video
    @IBAction func playBtnOnPressed(_ sender: UIButton) {
        self.playBtn.isHidden = true
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        self.delegate?.playViewed(sender: sender.tag)
        if Connection.isConnectedToNetwork(){
            self.activityLoader.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                self.avplayer?.play()
                //self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            }
        }
        
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
                self.noInternetView.isHidden = true
                print(isReuse)
                self.playOrPauseVideo(url: self.mediaUrl, parent: HomeViewController(), play: true)
               
                
               
                
            }
            else{
                self.noInternetView.isHidden = true
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
                playerRemove()
                self.playerController?.showsPlaybackControls = true
                self.noInternetView.isHidden = true
                self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
                self.AudioplayOrPauseVideo(url: mediaUrl, parent: HomeViewController(), play: true)
                //self.avplayer?.play()
                
            }
            else{
                self.noInternetView.isHidden = true
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
    
    
    /// After video or audio ended it starts from 0 seconds
    @objc func videoDidEnded (){
        playerController?.dismiss(animated: true,completion: nil)
        self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
    }
    
    
    /// Audio player is to play the audio using the media url
    func AudioplayOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async { [self] in
            
            self.test.delegate = self
            self.test.networkSpeedTestStop()
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            self.loadingLbl.text = "Audio loading failed"
            self.isAudio = true
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
            self.activityLoader.isHidden = true
            // self.avplayer?.currentItem?.preferredPeakBitRate = 100000.000000
            self.videoBgView.backgroundColor = .clear
            self.videoBgView.addSubview(self.playerController?.view ?? UIView())
            self.playerController?.videoGravity = .resizeAspect
            self.playerController?.quitFullScreen()
            if play == true{
                self.playBtn.isHidden = true
                self.playerController?.showsPlaybackControls = true
                self.playerController?.player?.play()
            }
            //
            //self.playerController?.didMove(toParent: parent)
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController?.player?.currentItem)
            
            self.avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            self.avplayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            
            
           
        }
    }
    
    
    
    
    
    //    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        //this way once user scrolls player will pause
        
        //  self.playerController?.player?.pause()
        
        
        self.contentsImageView.image = nil
        self.contentBgImgView.image = nil
        
        self.leftView.isHidden = true
        self.rightView.isHidden = true
        self.playerItem = nil
        //self.activityLoader.isHidden = true
        //self.playerController?.view.backgroundColor = .black
        self.playerController?.player?.pause()
        self.playerController?.showsPlaybackControls = false
        self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
        self.playerController?.view.removeFromSuperview()
        self.playerController?.removeFromParent()
        self.playerController?.player = nil
        self.noInternetView.isHidden = true
        self.activityLoader.isHidden = true
        //self.activityLoader.removeFromSuperview()
        //self.isReuse = true
       // print("reuse")
    }
    
    ///Swipe gesture selector function
    @objc func didSwipeLeft(gesture: UIGestureRecognizer) {
        //We can add some animation also
        DispatchQueue.main.async(execute: {
            let animation = CATransition()
            animation.type = CATransitionType.moveIn
            animation.subtype = CATransitionSubtype.fromRight
            animation.duration = 0.5
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            //Add this animation to your view
            self.rightView.layer.add(animation, forKey: nil)
            self.playerController?.player?.pause()
            if !self.leftView.isHidden {
                self.leftView.isHidden = true
            }else{
                self.rightView.isHidden = false
                
            }
            //self.rightView.isHidden = true
        })
    }
    
    
    
    
    
    ///Swipe gesture selector function
    @objc func didSwipeRight(gesture: UIGestureRecognizer) {
        // Add animation here
        
        DispatchQueue.main.async(execute: {
            let animation = CATransition()
            animation.type = CATransitionType.moveIn
            animation.subtype = CATransitionSubtype.fromLeft
            animation.duration = 0.5
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            //Add this animation to your view
//            self.leftView.layer.add(animation, forKey: nil)
            self.playerController?.player?.pause()
            if !self.rightView.isHidden {
                self.rightView.isHidden = true
            }else{
                self.leftView.isHidden = true
            }
        })
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
    
   
    
    
    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.
    override func layoutSubviews() {
        
        contentsImageView.contentMode = .scaleAspectFit
        contentsImageView.clipsToBounds = true
        
        //        let gradient = CAGradientLayer()
        //        gradient.frame = cellBackgroundView.bounds
        //        gradient.colors = [UIColor.splashStartColor.cgColor,UIColor.splashEndColor.cgColor]
        //        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        //        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        //        cellBackgroundView.layer.insertSublayer(gradient, at: 0)
        cellBackgroundView.backgroundColor = .black
        
        //content cell
        tagView.clipsToBounds = true
        tagView.layer.cornerRadius = 6
//        dummyView11.clipsToBounds = true
//        dummyView11.layer.cornerRadius = 6
        
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 6
        iconImageView.layer.borderWidth = 0.5
        iconImageView.layer.borderColor = UIColor.clear.cgColor
        tagBtn.backgroundColor = UIColor.clear
        
        contentBgView.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        //dummyView10.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
        
    }
    
    func loadAnimatedImage(view:UIView) {
        if animationHomeView != nil {
            animationHomeView?.removeFromSuperview()
        }
        animationHomeView = .init(name: "Clapping")
        animationHomeView!.frame = view.bounds
        animationHomeView!.contentMode = .scaleAspectFit
        animationHomeView!.loopMode = .loop
        //  animationView!.animationSpeed = 0.3
        view.addSubview(animationHomeView!)
        animationHomeView!.play()
    }
    
    static func isType() -> Bool {
        return true
    }
    
}

extension MonetizeNewscardCollectionViewCell {
    
    @IBAction func clapButtontapped(sender: UIButton) {
        
        collectionDelegate?.homeClap(sender: sender)
    }
    
    @IBAction func viewButtontapped(sender: UIButton) {
        
        collectionDelegate?.homeView(sender: sender)
    }
    
    @IBAction func tagButtontapped(sender: UIButton) {
        
        collectionDelegate?.tagButtonTapped(sender: sender)
    }
    
    
}


/**
 It helps to with full screen for the player and exits full screens observers will habndle here
 */
extension MonetizeNewscardCollectionViewCell: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if isAudio == true{
           // self.isFullscreen = true
            self.delegate?.videoPlayerFullScreenDismiss()
            
            
        }
        else{
            print("Detect Fullscreen")
            self.isFullscreen = true
    //        if mediaType == 4{
    //            self.playerController?.goFullScreen()
    //        }
            
            coordinator.animate(alongsideTransition: nil) { transitionContext in
                self.playerController?.player?.play()
            }
            
            self.delegate?.videoPlayerFullScreenDismiss()
            if Connection.isConnectedToNetwork(){
                
            }
            else{
                // self.playerController?.dismiss(animated: true, completion: nil)
                //playerViewController.exitsFullScreenWhenPlaybackEnds
            }
        }
        
        
    
        //print(playerViewController.ex)
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { transitionContext in
            self.isFullscreen = false
            self.playerController?.player?.play()
        }
        
    }
    
    

}





