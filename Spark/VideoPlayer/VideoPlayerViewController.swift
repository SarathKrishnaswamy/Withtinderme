//
//  VideoPlayerViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 02/03/22.
//

import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var videoBgView: UIView!
    @IBOutlet weak var contentImageBgView: UIImageView!
    @IBOutlet weak var videoSecondsView: UIView!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var videoPlayBtn: UIButton!
    @IBOutlet weak var fullscreenBtn: UIButton!
    
    var playerItem : AVPlayerItem?
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    var timer: Timer?
    var timeObserver: Any?
    var url : String?
    var thumNail : String?
    var playerDelegate : getPlayerVideoDelegate?
    var currentSeconds : Double?
    var isSeekInProgress = false
    var activityView = UIActivityIndicatorView(style: .large)
    var isBuffering : Bool = false
    var playerTryCount = -1 // this should get set to 0 when the AVPlayer starts playing
    let playerTryCountMaxLimit = 20
    
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        self.videoPlayBtn.layer.cornerRadius = self.videoPlayBtn.frame.width/2
        self.contentImageBgView.setImage(
            url: URL.init(string: thumNail ?? "") ?? URL(fileURLWithPath: ""),
            placeholder: UIImage(named: "NoImage"))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        self.player?.pause()
    }
                                       
                                       
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        self.player?.pause()
        //self.showActivityIndicatory()
        self.playToggle = 1
        self.videoPlayBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.videoPlayBtn.backgroundColor = .black
        //self.playToggle = 1
        
    }
                                       
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        self.player?.play()
        self.hideActivityIndicator()
        self.playToggle = 2
        self.videoPlayBtn.setImage(UIImage(systemName: "pause"), for: .normal)
        self.videoPlayBtn.tintColor = .white
        self.videoPlayBtn.backgroundColor = .clear
        
       
    }

    func setupVideoPlayer(){
        
        self.playerItem = AVPlayerItem(url:URL(string: url ?? "") ?? URL(fileURLWithPath: ""))
        self.playerItem?.preferredPeakBitRate = 6000000
        print("Playing in Bit Rate \(String(describing: player?.currentItem?.preferredPeakBitRate))")
        self.player = AVPlayer(playerItem: self.playerItem!)
        self.playerLayer = AVPlayerLayer(player: self.player!)
        self.playerLayer?.frame = self.videoBgView?.bounds ?? CGRect()
        self.playerLayer!.frame = CGRect(x:0,y:0,width: self.view?.frame.width ?? CGFloat(), height: self.view?.frame.height ?? CGFloat())
      //  self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoBgView?.layer.addSublayer(self.playerLayer!)
        self.videoBgView?.layer.backgroundColor = UIColor.clear.cgColor
        let newTime = CMTime(seconds: Double(currentSeconds ?? Double()), preferredTimescale: 600)
        player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        self.player?.play()
        self.playToggle = 2
        self.videoPlayBtn.setImage(UIImage(systemName: "pause"), for: .normal)
        self.videoPlayBtn.tintColor = .white
        self.videoPlayBtn.backgroundColor = .clear
        self.resetTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoBgTap(_:)))
        self.videoBgView.addGestureRecognizer(videoTap)
        let interval = CMTime(value: 1, timescale: 2)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval,
                                                       queue: DispatchQueue.main) { [unowned self] time in
            let timeElapsed = Float(time.seconds)
            self.videoSlider.value = timeElapsed
            self.currentTimeLbl.text = self.createTimeString(time: timeElapsed)
            
//            NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemPlaybackStalled(_:)),
//                                                   name: NSNotification.Name.AVPlayerItemPlaybackStalled,
//                                                   object: playerItem)
            player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)

//            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
//            if playbackLikelyToKeepUp == false{
//                // print(self.player?.rate)
//                print("IsBuffering")
//                self.showActivityIndicatory()
//                self.isBuffering = true
//                self.videoPlayBtn.isHidden = true
//                self.videoSecondsView.isHidden = true
//            } else {
//                //stop the activity indicator
//                print("Buffering completed")
//                self.hideActivityIndicator()
//                self.player?.play()
//                self.isBuffering = false
////                //                //self.videoPlayBtn.isHidden = false
         //}
        }
        
        
        playerItemStatusObserver = player?.observe(\AVPlayer.currentItem?.status, options: [.new, .initial]) { [unowned self] _, _ in
            DispatchQueue.main.async {
                //self.bufferState()
                self.updateUIforPlayerItemStatus()
                /*
                 Configure the user interface elements for playback when the
                 player item's `status` changes to `readyToPlay`.
                 */
                
            }
            
            playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            player!.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        }
        
     
        
        videoSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(playbackSlider: event:)), for: .valueChanged)
    }
//    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
//            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
//            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
//            if newStatus != oldStatus {
//                DispatchQueue.main.async {[weak self] in
//                    if newStatus == .playing || newStatus == .paused {
//                        self?.hideActivityIndicator()
//                        self?.showControls()
//                        //self?.loaderView.isHidden = true
//                    } else {
//                        self?.showActivityIndicatory()
//                        self?.hideControls()
//                        print("Buffering")
//                        //self?.loaderView.isHidden = false
//                    }
//                }
//            }
//        }
//    }
    
   
    @objc func videoBgTap(_ sender: UITapGestureRecognizer) {
        // handling code
        
        if self.isBuffering == true{
            self.videoPlayBtn.isHidden = true
            self.timer?.invalidate()
            
        }
        else{
            if self.player?.timeControlStatus == .playing{
                self.showControls()
                self.resetTimer()
                
            }
            else{
                self.showControls()
            }
        }
        
        
    }
    @objc func playbackSliderValueChanged(playbackSlider:UISlider, event: UIEvent)
      {
          
          
          if let touchEvent = event.allTouches?.first {
                 switch touchEvent.phase {
                 case .began:
                     self.isSeekInProgress = true
                     self.player?.pause()
                     self.videoPlayBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
                     self.videoPlayBtn.backgroundColor = .black
                     self.playToggle = 1
                     print(isSeekInProgress)
                     self.timer?.invalidate()
                 case .ended:
                     self.isSeekInProgress = false
                     print(isSeekInProgress)
                     let newTime = CMTime(seconds: Double(playbackSlider.value), preferredTimescale: 600)
                     player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
                     self.videoPlayBtn.setImage(UIImage(systemName: "pause"), for: .normal)
                     self.videoPlayBtn.tintColor = .white
                     self.videoPlayBtn.backgroundColor = .clear
                     self.playToggle = 2
                     self.player?.play()
                     self.resetTimer()
                 default:
                     break
                 }
             }
      }
    // MARK: - Utilities
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    @IBAction func videoPlayBtnOnPressed(_ sender: Any) {
        if playToggle == 1{
            self.player?.play()
            self.playToggle = 2
            //self.videoPlayBtn.isHidden = true
            self.videoPlayBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            self.videoPlayBtn.tintColor = .white
            self.videoPlayBtn.backgroundColor = .clear
           
        }
        else{
            self.player?.pause()
            self.playToggle = 1
            self.videoPlayBtn.tintColor = .white
            self.videoPlayBtn.backgroundColor = .black
            self.videoPlayBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
           
           
        }
    }
    
    
    //Play state
    @IBAction func fullscreenDismiss(_ sender: Any) {
        
        self.player?.pause()
        let currentTime = player?.currentTime() ?? CMTime()
        let currentSeconds = CMTimeGetSeconds(currentTime)
        self.playerDelegate?.fullVideoScreenDismiss(currentSeconds: Double(currentSeconds))
        self.dismiss(animated: true, completion: nil)
        
        
        
        
    }
    func updateUIforPlayerItemStatus() {
        guard let currentItem = player?.currentItem else { return }
        
        switch currentItem.status {
        case .failed:
            /*
             Display an error if the player item status property equals
             `.failed`.
             */
            //playPauseButton.isEnabled = false
            videoSlider.isEnabled = false
            currentTimeLbl.isEnabled = false
            totalTimeLbl.isEnabled = false
            //handleErrorWithMessage(currentItem.error?.localizedDescription ?? "", error: currentItem.error)
            
        case .readyToPlay:
            /*
             The player item status equals `readyToPlay`. Enable the play/pause
             button.
             */
            //playPauseButton.isEnabled = true
            
            /*
             Update the time slider control, start time and duration labels for
             the player duration.
             */
            let newDurationSeconds = Float(currentItem.duration.seconds)
            
            let currentTime = Float(CMTimeGetSeconds(player?.currentTime() ?? CMTime()))
            
            videoSlider.maximumValue = newDurationSeconds
            videoSlider.value = currentTime
            videoSlider.isEnabled = true
            currentTimeLbl.isEnabled = true
            currentTimeLbl.text = createTimeString(time: currentTime)
            totalTimeLbl.isEnabled = true
            totalTimeLbl.text = createTimeString(time: newDurationSeconds)
            
        default:
            //playPauseButton.isEnabled = false
            videoSlider.isEnabled = false
            currentTimeLbl.isEnabled = false
            totalTimeLbl.isEnabled = false
        }
    }
    
    @objc private func videoDidPlayToEnd(_ notification: Notification) {
        
        // Compare an asset URL.
        self.videoPlayBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.videoPlayBtn.backgroundColor = .black
        self.videoSlider.value = 0.0
        player?.seek(to: CMTimeMakeWithSeconds(Float64(0.0), preferredTimescale: 1) )
        videoPlayBtn.tintColor = .white
        videoPlayBtn.isHidden = false
        self.timer?.invalidate()
        self.playToggle = 1
    
    }
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    @objc func hideControls() {
        self.videoSecondsView.isHidden = true
        self.videoPlayBtn.isHidden = true
        //self.fullscreenBtn.isHidden = true
    }
    
    func showControls(){
        self.videoSecondsView.isHidden = false
        self.videoPlayBtn.isHidden = false
        //self.fullscreenBtn.isHidden = false
    }
    
    func showActivityIndicatory() {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear

        activityView.style = .white
        activityView.center = self.view.center

        container.addSubview(activityView)
        self.videoBgView.addSubview(container)
        activityView.startAnimating()
    }
    
    func hideActivityIndicator(){
        activityView.stopAnimating()
        activityView.isHidden = true
    }
    
    
    
    /// Informs the observing object when the value at the specified key path relative to the observed object has changed.
    /// - Parameters:
    ///   - keyPath: The key path, relative to object, to the value that has changed.
    ///   - object: The source object of the key path keyPath.
    ///   - change: A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in Change Dictionary Keys.
    ///   - context: The value that was provided when the observer was registered to receive key-value observation notifications.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = player
        {
            if player.rate != 0 && player.currentItem?.status == AVPlayerItem.Status.readyToPlay
            {
                //print("delegate call")
               // delegate?.videoReadyToPlay(videoUrl?.description)

            }
            else if player.status == AVPlayer.Status.failed  //Changes made by
            {
                print("Error occured playing video")
            }
        }
        
        //Changes made by
        if object is AVPlayerItem
        {
            switch keyPath
            {
            case "playbackBufferEmpty":
            
                // Show loader
                self.showActivityIndicatory()
                //spinner.startAnimating()
               // self.bringSubview(toFront: spinner)
                print("Show loader")
                break;
                
                
            case "playbackLikelyToKeepUp":
            
                // Hide loader
                self.hideActivityIndicator()
                //self.playerItem?.preferredPeakBitRate = 700000
                //spinner.stopAnimating()
                //self.bringSubview(toFront: spinner)
                print("Hide loader playbackLikelyToKeepUp")
                print("Playing in Bit Rate \(String(describing: player?.currentItem?.preferredPeakBitRate))")
                break;
                
                
            case "playbackBufferFull":
            
                // Hide loader
                self.hideActivityIndicator()
                //spinner.stopAnimating()
               // self.bringSubview(toFront: spinner)
                print("Hide loader playbackBufferFull")
                break;
                
                
            case .none:
            
                //  SVProgressHUD.dismiss()
                print("Hide loader none")
                break;
                
            case .some(_):
            
                // SVProgressHUD.dismiss()
                //print("Hide loader some")
              //  spinner.startAnimating()
                // self.bringSubview(toFront: spinner)
                print("Show loader some")
                
                break;
                
            }
    }
    
}

}



