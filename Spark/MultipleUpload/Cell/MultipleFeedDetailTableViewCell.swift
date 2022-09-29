//
//  MultipleFeedDetailTableViewCell.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 29/06/22.
//

import UIKit
import AVKit


protocol GrowingCellProtocol {
    func updateHeightOfRow(_ cell: MultipleFeedDetailTableViewCell, _ textView: UITextView)
}



/**
 This class is used to show the multiple feed detail page to upload the posts
 */

class MultipleFeedDetailTableViewCell: UITableViewCell,NetworkSpeedProviderDelegate {
    
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

    @IBOutlet weak var contentBgImage: UIImageView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var CaptionText: UITextView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var postTypeImage: UIImageView!
    @IBOutlet weak var videoBgView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bgTextView: UIView!
    
    
    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var noInternetView: UIStackView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var retryBtn:UIButton!
    
    var avplayer : AVPlayer?
    var cellDelegate: GrowingCellProtocol?
    var playerController : AVPlayerViewController? = nil
    var isGoodConnectivity = false
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    
    
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    var playbackLikelyToKeepUpObserver: NSKeyValueObservation?
    var isAudio = false
    
    let test = NetworkSpeedTest()
    var mediaType = Int()
    var mediaUrl = String()
    var isFullscreen = false
    
    weak var delegate:getPlayerVideoAudioIndexDelegate?
    
    
  
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.noInternetView.isHidden = true
        self.retryBtn.layer.cornerRadius = 4.0
        self.retryBtn.layer.borderWidth = 1.0
        self.retryBtn.layer.borderColor = UIColor.white.cgColor
        //self.CaptionText.adjustUITextViewHeight()
        playBtn.isHidden = true
        self.noInternetView.isHidden = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentBgImage.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentBgImage.addSubview(blurView)
    }
    
    
    /// Play or pause the video using the url link with initialize the player
    /// - Observe the player to empty buffer, playback buffer, playingkeep up
    func playOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async {
            self.test.delegate = self
            self.test.networkSpeedTestStop()
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            self.loadingLbl.text = "Video loading failed"
            self.isAudio = true
            
            
            self.activityLoader.isHidden = true
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
            
            
            
            self.playbackBufferEmptyObserver = self.playerItem?.observe(\.isPlaybackBufferEmpty, options: [.new, .initial ], changeHandler: { [weak self] (player, bufferEmpty) in

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

            self.playbackBufferFullObserver = self.playerItem?.observe(\.isPlaybackBufferFull, options: [.new, .initial], changeHandler: {[weak self] (player, bufferFull) in
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

            self.playbackLikelyToKeepUpObserver = self.playerItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .initial], changeHandler: { [weak self] (player, _) in
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
        }
    }
    
    
    /// Audio player is to play the audio using the media url
    func AudioplayOrPauseVideo(url:String,parent: UIViewController,play:Bool) {
        
        DispatchQueue.main.async {
            
            self.test.delegate = self
            self.test.networkSpeedTestStop()
            self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
            self.loadingLbl.text = "Audio loading failed"
            self.isAudio = true
//
            self.activityLoader.isHidden = true
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
               // self.isReuse = false
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
    @IBAction func playBtnOnPressed(_ sender: Any) {
        
        self.playBtn.isHidden = true
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        if Connection.isConnectedToNetwork(){
            
            
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
    
    
    /// Video or audio will be ended and after it will start 0.0 seconds
    @objc func videoDidEnded(){
        playerController?.dismiss(animated: true,completion: nil)
        self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
    }
    
    
    
    
    
    
    /// Retry button used to reload the player to play and check whether inter is there or not.
    @IBAction func retryBtnOnPressed(_ sender: Any) {
        if mediaType == 3{
            // false is making good connectivity
            
            if isGoodConnectivity == false{
                self.playBtn.isHidden = true
                print(NetworkStatus.good)
                self.activityLoader.isHidden = true
                self.activityLoader.stopAnimating()
                self.playerController?.showsPlaybackControls = true
                self.noInternetView.isHidden = true
                self.playOrPauseVideo(url: self.mediaUrl, parent: MultipleFeedViewController(), play: true)
               
                
               
                
            }
            else{
                self.playBtn.isHidden = true
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
                self.playBtn.isHidden = true
                print(NetworkStatus.good)
                self.activityLoader.isHidden = true
                self.activityLoader.stopAnimating()
                self.playerController?.showsPlaybackControls = true
                self.noInternetView.isHidden = true
                self.avplayer?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
                self.AudioplayOrPauseVideo(url: mediaUrl, parent: MultipleFeedViewController(), play: true)
                
            }
            else{
                self.playBtn.isHidden = true
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
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


extension MultipleFeedDetailTableViewCell : AVPlayerViewControllerDelegate{
    
}


extension MultipleFeedDetailTableViewCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if let deletate = cellDelegate {
            deletate.updateHeightOfRow(self, textView)
        }
    }
}

extension UITextView {
    func adjustUITextViewHeight() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }
}
