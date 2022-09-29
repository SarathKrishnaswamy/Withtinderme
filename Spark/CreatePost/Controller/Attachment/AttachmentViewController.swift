//
//  AttachmentViewController.swift
//  Spark
//
//  Created by Gowthaman P on 13/07/21.
//

import Combine
import UIKit
import PhotoEditorSDK
import AVFoundation
import AVKit
import Photos
import RAMAnimatedTabBarController
import WebKit
import PDFKit
import AVKit
import AVFAudio
import SoundWave
import QuickLook
import LRSpotlight
import SwiftyGif
import UserNotifications
import Connectivity
import BackgroundTasks
import Toaster


protocol backtoMultipostDelegate {
    func back()
}

/**
 This class is used to attach all the text, photos, videos, music and docs , it can be uploaded with tags and description with NFT properties.
 */

class AttachmentViewController: UIViewController,UITextFieldDelegate, PhotoEditViewControllerDelegate, VideoEditViewControllerDelegate,UIWebViewDelegate, PDFViewDelegate, AVAudioPlayerDelegate,QLPreviewControllerDataSource, attributeDelegate, NetworkSpeedProviderDelegate {
   
    
    /// This is used to detect the network change
    /// - Parameter networkStatus: The status can be poor, good and disconnected
    func callWhileSpeedChange(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .poor:
            print("poor")
            print(Network.reachability.status)
            print("Reachable:", Network.reachability.isReachable)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
           
                //print(self.mediaUrl)
            }
            
            // self.test.networkSpeedTestStop()
            
            break
        case .good:
            //print("good")
            
            break
        case .disConnected:
            print("disconnected")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
            }
            break
        }
    }
    
    
    func passAttribute(attribute: [[String : Any]]) {
        self.attributeArray = attribute
    }
    
    
    /// Returns the number of preview items to include in the preview navigation list.
    /// - Parameter controller: The Quick Look preview controller that’s requesting the number of preview items.
    /// - Returns: The number of items that the Quick Look preview controller should include in its preview navigation list.
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    /// Preview the selected item as docs or image.
    /// - Parameters:
    ///   - controller: Show the preview view controller of the item
    ///   - index: Show the index of the item
    /// - Returns: It returns the item
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedDocUrl as QLPreviewItem
    }
    
   
    @IBOutlet weak var aboutPostTxtViewHeightConstraints:NSLayoutConstraint?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var docThumpNailImgView:UIImageView?
    @IBOutlet weak var videoBgView:UIView?
    @IBOutlet weak var tagTxtField:UITextField?
    @IBOutlet weak var aboutPostTxtView:UITextView?
    @IBOutlet weak var editBtn:UIButton?
    @IBOutlet weak var addBtn:UIButton?
    @IBOutlet var pdfBgView: UIView?
    @IBOutlet weak var audioPlayerBg:UIView?
    @IBOutlet weak var playBtn:UIButton?
    @IBOutlet weak var documentThumpBtn:UIButton?
    @IBOutlet weak var tagBtn:UIButton?
    
    @IBOutlet weak var doneBtn : UIButton?
    @IBOutlet weak var textBgView:UIView?
    @IBOutlet weak var txtView:UITextView?
    @IBOutlet weak var tagListView: TagListView!
    
    @IBOutlet weak var tagView: Gradient!
    
    @IBOutlet weak var tagViewBtn: UIButton!
    
    @IBOutlet weak var documentFileNameLbl: UILabel!
    @IBOutlet weak var contentImageBgView: UIImageView!
    
    
    @IBOutlet weak var AudioAnimation: UIImageView!
    @IBOutlet weak var LblTextViewCount: UILabel!
    
    
    @IBOutlet weak var monetizeTextField : UITextField!
    
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var tagBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var createSparkLbl: UILabel!
    @IBOutlet weak var topCaptionConstraint: NSLayoutConstraint!
    var delegate : backFromPhotomodelDelegate?
    var backtoMultipostDelegate : backtoMultipostDelegate?
       
    @IBOutlet weak var monetizeSummaryView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monetizeSummaryBack: UIButton!
    
    
    var selectedImage = UIImage()
    var thumpNailString = ""
    let viewModel = CreatePostViewModel()
    var uploadedMediaName = ""
    var avplayer = AVPlayer()
    var playerController = AVPlayerViewController()
    var selectedVideoPath = ""
    var typedQuestionDict = [String:Any]()
    var selectedVideoUrl:URL!
    var selectedDocUrl = URL.init(string: "") ?? URL(fileURLWithPath: "")
    var selectedDocData = Data()
    var selectedDocTypeArray = [String]()
    private var audioPlayer: AVAudioPlayer?
    var repostTagValue = ""
    var repostTagId = ""
    var selectedTagValue = ""
    var selectedTagId = ""
    var nodess = [SpotlightNode]()
    var nftParam = Int()
    var monetizeSpark = Int()
    var attachmentViewModel = AttachmentViewModel()
    var isSeekInProgress = false
    var isFromPhotoModel = 0
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var currenyCode = ""
    var currencySymbol = ""
    var monetizeAmount = Int()
    
    let queplayer = AVQueuePlayer()
    var asseturl: URL = URL.init(string: "") ?? URL(fileURLWithPath: "")
    var playerItem : AVPlayerItem?
    let test = NetworkSpeedTest()
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var playToggle = 1
    var timer: Timer?
    var timeObserver: Any?
    var attributeArray = [[String:Any]]()
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var isFromAudio = false
    //var montizeAmount = ""
    fileprivate let connectivity = Connectivity()
    fileprivate var isCheckingConnectivity: Bool = false
    
//    var isMonetize = 0
//    var monetizePostId = ""
    
    var FromLoopMonetize = 0
    
    var multiplePost = 0
    
    var repostId = ""
    var isRepost = false
    var fees = ["Platform fee","Tax","Your Spark listing value"]
    var totalMonetizeAmount = 0
    var monetizePlatformAmount = 0
    var monetizeTax = 0
    var monetizeActualAmount = 0
    
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
    /// Here we are chceking the Internet checking
    /// Set the media type values of  1- text, 2 -image,  3-video,  4-audio, 5-image  as profile updated and contact updated
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Internet Check
        continueBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        continueBtn.layer.cornerRadius = 4
        continueBtn.clipsToBounds = true
        
        self.monetizeSummaryView.isHidden = true
        
        connectivity.framework = .systemConfiguration
        performSingleConnectivityCheck()
        configureConnectivityNotifier()
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        imageView?.image = selectedImage
        contentImageBgView?.image = selectedImage
        contentImageBgView.contentMode = .scaleAspectFill
        
        aboutPostTxtView?.delegate = self
//        aboutPostTxtView?.textContainer.maximumNumberOfLines = 4
//        aboutPostTxtView?.textContainer.lineBreakMode = .byWordWrapping
        self.txtView?.isEditable = false
        self.txtView?.isSelectable = true
        
        setUpUI()
        
        setupCreatePostMediaViewModel()
        
        tagTxtField?.isUserInteractionEnabled = false
        
        tagView.isHidden = true
        tagListView.removeAllTags()
        
        aboutPostTxtView?.layer.cornerRadius = 6.0
        aboutPostTxtView?.layer.borderColor = UIColor.init(hexString: "d6d6d6").cgColor
        aboutPostTxtView?.layer.borderWidth = 1.0
        aboutPostTxtView?.clipsToBounds = true
        aboutPostTxtView?.delegate = self
        aboutPostTxtView?.textColor = UIColor.init(hexString: "A7A7A7").withAlphaComponent(0.8)
        doneButtonKeyboard()
        aboutPostTxtViewHeightConstraints?.constant = 89
        
        self.playBtn?.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.playBtn?.backgroundColor = .black
        self.playBtn?.tintColor = .white
        self.playBtn?.layer.cornerRadius = (self.playBtn?.frame.width ?? CGFloat()) / 2
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        blurView.frame = contentImageBgView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentImageBgView.addSubview(blurView)
        
        editBtn?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toBottom, for: .normal)
        addBtn?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toBottom, for: .normal)
        addBtn?.layer.cornerRadius = 20
        addBtn?.clipsToBounds = true
        
        //From Feed detail page to repost with same tage
        if SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 {
            tagTxtField?.isHidden = true
            tagBtn?.isHidden = true
            tagView.isHidden = false
            tagViewBtn?.setTitle(SessionManager.sharedInstance.getTagNameFromFeedDetails?["tagName"] as? String ?? "", for: .normal)
            repostTagValue = SessionManager.sharedInstance.getTagNameFromFeedDetails?["tagName"] as? String ?? ""
            repostTagId = SessionManager.sharedInstance.getTagNameFromFeedDetails?["tagID"] as? String ?? ""
        }else if SessionManager.sharedInstance.homeFeedsSwippedObject != nil { //From Home page to Re-post
            self.isRepost = true
            tagTxtField?.isHidden = true
            tagBtn?.isHidden = true
            tagView.isHidden = false
            tagViewBtn?.setTitle(SessionManager.sharedInstance.homeFeedsSwippedObject?.tagName ?? "".uppercased(), for: .normal)
            repostTagValue = SessionManager.sharedInstance.homeFeedsSwippedObject?.tagName ?? ""
            repostTagId = SessionManager.sharedInstance.homeFeedsSwippedObject?.tagId ?? ""
        }else{
            tagTxtField?.isHidden = false
            tagBtn?.isHidden = false
            tagView.isHidden = true
        }
        
        if FromLoopMonetize == 1 && multiplePost == 1{
            self.tagBtn?.isHidden = true
            self.tagListView.isHidden = true
            self.tagView.isHidden = true
            self.tagTxtField?.isHidden = true
            self.createSparkLbl.text = "Edit your Spark"
            self.tagListViewHeight.constant = 0
            //self.topCaptionConstraint.constant = 20
            
            
        }
        else{
//            self.tagBtn?.isHidden = false
//            self.tagListView.isHidden = false
//            self.tagView.isHidden = false
//            self.tagTxtField?.isHidden = false
           // self.topCaptionConstraint.constant = 49
            self.tagListViewHeight.constant = 28
            self.createSparkLbl.text = "Create your Spark"
        }
        
        
        
       
        
        if typedQuestionDict["mediaType"] as? Int == MediaType.Text.rawValue {
            
            textBgView?.isHidden = false
            videoBgView?.isHidden = true
            imageView?.isHidden = true
            pdfBgView?.isHidden = true
            audioPlayerBg?.isHidden = true
            txtView?.isUserInteractionEnabled = true
            aboutPostTxtView?.isHidden = true
            contentImageBgView.isHidden = true
            self.LblTextViewCount.isHidden = true
            self.editBtn?.isHidden = true
            self.playBtn?.isHidden = true
            
            aboutPostTxtViewHeightConstraints?.constant = 0
            
            txtView?.text = "\(typedQuestionDict["textViewValue"] as? String ?? "")"
            txtView?.backgroundColor = UIColor.init(hexString: typedQuestionDict["bgColor"] as? String ?? "" )
            txtView?.textColor = UIColor.init(hexString:typedQuestionDict["textColor"] as? String ?? "" )
           
            
            
        } else if typedQuestionDict["mediaType"] as? Int == MediaType.Video.rawValue {
            
            playVideoInPalyer(url: selectedVideoPath)
            textBgView?.isHidden = true
            videoBgView?.isHidden = false
            imageView?.isHidden = true
            pdfBgView?.isHidden = true
            audioPlayerBg?.isHidden = true
            contentImageBgView.isHidden = true
            self.LblTextViewCount.isHidden = false
            
            self.AudioAnimation.isHidden = true
            self.playBtn?.isHidden = true
            
            
            
        }else if typedQuestionDict["mediaType"] as? Int == MediaType.Image.rawValue {
            textBgView?.isHidden = true
            videoBgView?.isHidden = true
            imageView?.isHidden = false
            pdfBgView?.isHidden = true
            audioPlayerBg?.isHidden = true
            contentImageBgView.isHidden = false
            self.LblTextViewCount.isHidden = false
            
            self.AudioAnimation.isHidden = true
            self.playBtn?.isHidden = true
            
            
        }else if typedQuestionDict["mediaType"] as? Int == MediaType.Document.rawValue {
            textBgView?.isHidden = true
            editBtn?.isHidden = true
            pdfBgView?.isHidden = false
            videoBgView?.isHidden = true
            imageView?.isHidden = true
            audioPlayerBg?.isHidden = true
            contentImageBgView.isHidden = true
            self.LblTextViewCount.isHidden = false
            
            self.AudioAnimation.isHidden = true
            self.playBtn?.isHidden = true
            
            documentFileNameLbl.text = selectedDocTypeArray.first?.removingPercentEncoding
            
            if self.selectedDocTypeArray.last ?? "" == "pdf" {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "pdf")
            }else if self.selectedDocTypeArray.last ?? "" == "ppt" {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "ppt")
            }else if self.selectedDocTypeArray.last ?? "" == "doc" || self.selectedDocTypeArray.last ?? "" == "docx" {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "doc")
            }else if self.selectedDocTypeArray.last ?? "" == "xlsx" {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "xls")
            }
            else if self.selectedDocTypeArray.last ?? "" == "xls" {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "xls")
            }
            else  {
                docThumpNailImgView?.image = #imageLiteral(resourceName: "text")
            }
            
            
            //thumpNailGeneratorForDocument()
        }
        else if typedQuestionDict["mediaType"] as? Int == MediaType.Audio.rawValue{
            textBgView?.isHidden = true
            editBtn?.isHidden = true
            pdfBgView?.isHidden = true
            videoBgView?.isHidden = false
            imageView?.isHidden = true
            audioPlayerBg?.isHidden = true
            contentImageBgView.isHidden = true
            self.LblTextViewCount.isHidden = false
            self.playBtn?.isHidden = true
           
            //self.videoSlider.isHidden = true
            //self.currentTimeLbl.isHidden = true
            //self.totalTimeLbl.isHidden = true
            self.AudioAnimation.isHidden = false
            
            loadAudioViewer()
        }
        
        else if typedQuestionDict["mediaType"] as? Int == MediaType.RecordedAudio.rawValue {
            textBgView?.isHidden = true
            editBtn?.isHidden = true
            pdfBgView?.isHidden = true
            videoBgView?.isHidden = true
            imageView?.isHidden = true
            audioPlayerBg?.isHidden = true
            contentImageBgView.isHidden = false
            self.LblTextViewCount.isHidden = false
            self.AudioAnimation.isHidden = false
            self.playBtn?.isHidden = false
            
            self.contentImageBgView.image = UIImage(named: "Band")
            do {
                let gif = try UIImage(gifName: "band.gif", levelOfIntegrity:0.7)
                self.AudioAnimation.setGifImage(gif, loopCount: -1)
                self.AudioAnimation.stopAnimatingGif()
            }
            catch{
                print("error")
            }
            
            playBtn?.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
        }
        if SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot == false {//&& SessionManager.sharedInstance.isProfileUpdatedOrNot == false{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.nodess = [SpotlightNode(text: "Create your unique SparkTag that best defines your content/ Spark post or while reposting when you swipe left this tag will be set and cant be edited", target: .view(self.tagTxtField ?? UITextField()), roundedCorners: true, imageName: "")]
                Spotlight().startIntro(from: self, withNodes: self.nodess)
                SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = true
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChecking), name: Notification.Name("InternetChecking"), object: nil)
        
    }
    
    
    
    
    /// Check the internet  when it is connected or not.
    @objc func internetChecking(){
//        let center = UNUserNotificationCenter.current()
//        center.removeAllDeliveredNotifications() // To remove all delivered notifications
//        center.removeAllPendingNotificationRequests()
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        connectivity.framework = .systemConfiguration
//        performSingleConnectivityCheck()
//        configureConnectivityNotifier()
        isCheckingConnectivity ? stopConnectivityChecks() : startConnectivityChecks()
    
    }
    
    
    /// Update the user interface when internet is connected or not
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            MaininternetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            MaininternetRetry()
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            MaininternetRetry()
            //view.backgroundColor = .green
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    
    /// Set the status manager to update the interface
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    /// When internet is connected it is check with connected to internet and retrive the api.
    func MaininternetRetry(){
        if Connection.isConnectedToNetwork(){
           print("Connected")
            
        
        }
        else{
            let alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)

            

            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
            // ... Do something
                self.navigationController?.popViewController(animated: true)
                self.MaininternetRetry()
               
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true) {
            // ... Do something
            }
            
        }
    }
    
    /// Register for background service
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    
    
    /// End the backgorund task when its ended
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    
    /// App moved to background
    @objc func appMovedToBackground() {
        self.registerBackgroundTask()
        //print("App moved to background!")
        
    }
    
    
    /// App moved to foreground
    @objc func appMovedToForeground() {
        self.endBackgroundTask()
        
    }
    
   
    /// When Add button on pressed open the NFT Property view controller
    @IBAction func addBtnOnPressed(_ sender: Any) {
        let slideVC = NftPropertyViewController()
        slideVC.modalPresentationStyle = .overFullScreen
        slideVC.transitioningDelegate = self
        slideVC.attributeDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    
    /// When back button pressed from monetize summary  it will be hide and validate the input  alert
    @IBAction func monetizeSummaryBackBtnOnPressed(_ sender: Any) {
        self.monetizeSummaryView.isHidden = true
        //self.monetizeTextField.text = "\(self.monetizeAmount)"
        self.monetizationInputAlert(amount: "\(self.monetizeAmount)", isFromSummary: true)
        
    }
    
    /// Monetize summary continue button on pressed to save the internet
    @IBAction func monetizeSummaryContinueBtnOnPressed(_ sender: Any) {
        self.monetizeAmount = self.totalMonetizeAmount
        self.SaveRetry()
        
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
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isCheckingConnectivity ? stopConnectivityChecks() : startConnectivityChecks()
        if self.nftParam == 1{
            
            self.addBtn?.isHidden = false
//
        }
        else{
            self.addBtn?.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedTagValue(notification:)), name: Notification.Name("tagSelected"), object: nil)
        
    }
    
    
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        self.playerController.player?.pause()
        self.playToggle = 1
        
    }
    
    
    
    
    /// Set the selected tag value in tag  item
    /// - Parameter notification: Set the notification object value as dictionary with the tag button
    @objc func selectedTagValue(notification:NSNotification) {
        
        tagView.isHidden = false
        tagTxtField?.isHidden = true
        selectedTagValue = "\((notification.object as? [String:Any])?["tagName"] as? String ?? "")"
        selectedTagId = (notification.object as? [String:Any])?["tagID"] as? String ?? ""
        tagViewBtn?.setTitle((notification.object as? [String:Any])?["tagName"] as? String ?? "".uppercased(), for: .normal)
        
    }
    
    
    /// Load the audio viewer in the avplayer view controller
    func loadAudioViewer() {
        
        let selectedAudioAVAsset = AVAsset(url: asseturl)
        let playerItem = AVPlayerItem(asset: selectedAudioAVAsset)
        self.avplayer = AVPlayer(playerItem: playerItem)
        playerController.player = self.avplayer
        playerController.view.backgroundColor = .clear
        self.addChild(playerController)
        videoBgView?.addSubview(playerController.view)
        playerController.view.frame = videoBgView?.bounds ?? CGRect()
        playerController.showsPlaybackControls = true
//        self.avplayer.play()
    }
    
    /// When pressed on document viewer it will open the document
    @IBAction func documentViewerButtonTapped(sender:UIButton) {
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }
    /// When the audio in the wave formt it will show the avplayer to play
    @IBAction func audioPlayStopButtonTapped(sender:UIButton) {
        
        if (audioPlayer?.isPlaying ?? false) {
            audioPlayer?.stop()
            playBtn?.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playBtn?.backgroundColor = .black
            self.AudioAnimation.stopAnimatingGif()
        }else{
            do{
                self.audioPlayer = try AVAudioPlayer(contentsOf: asseturl)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
                playBtn?.setImage(UIImage(systemName: "pause"), for: .normal)
                playBtn?.backgroundColor = .clear
                self.AudioAnimation.startAnimatingGif()
                
            }catch{
                debugPrint(error.localizedDescription)
            }
        }
        
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
    
   
    
    
    /// Call the coconut api when we are uploading the video to split as multiple stream format
    /// - Parameters:
    ///   - mediaUrl: Send the uploaded video blob url to coconut api
    ///   - nft: Set the nft as 0 or 1
    ///  - call the api to upload to coconut api with watermark
    func callcoconutapi(mediaUrl:String, nft:Int){
        let settings = [
            "ultrafast":true
        ]
        let url = [
            "url":mediaUrl
                   ]
        let credentials = [
            "account":SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "",
            "access_key": SessionManager.sharedInstance.settingData?.data?.versionInfo?.BlobConnection ?? ""//"KJSr4bb7X/W4GAaFZZC0hf5PN1/PuGHmnGeUPKJ/QCcjcldxRBuRj7Hiyp8pjXwsAhkRUQ+A3Mawnfa0N4oUlg=="//SessionManager.sharedInstance.settingData?.data?.blobConnection ?? ""
        ]
        let storage = [
            "service":"azure",
            "container":SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "",
            "credentials":credentials
        ] as [String : Any]
        
       
        let notification = [
            
            "type":"http",
            "url": SessionManager.sharedInstance.settingData?.data?.cocnutInfo?.coconutWebHookURL ?? "" //SessionManager.sharedInstance.settingData?.data?.cocnutInfo?.CoconutWebHookURL ?? ""
        ]
        let watermark = [
            "url": SessionManager.sharedInstance.settingData?.data?.cocnutInfo?.waterMarkURL ?? "",
            "position" : "topright"
        ]
        let variants = [
            "mp4:240p::quality=1",
            "mp4:480p::quality=2,maxrate=1500k",
            "mp4:720p::quality=3,maxrate=3000k"
        ]
        let path = ["path":"/Videos/\(SessionManager.sharedInstance.getUserId)/\(currentTimeInMilliSeconds())"]
        let hls = ["hls":path,
                   "watermark":watermark,
                   "variants":variants
                   
        ] as [String : Any]
        let httpstream = ["httpstream":hls]
        
        
        
        let params = [
            "settings" : settings,
            "input": url,
            "storage": storage,
            "notification": notification,
            "outputs" : httpstream
            
        ] as[String : Any]
        
        print(params)
        callShareApi(params: params, mediaurl:mediaUrl, nft:nft)
        //loginWS(parameters: params)
    }
    
    
    
    /// If internet connected it will upload to the coconut api
    /// - Parameters:
    ///   - params: Send a set of dictionary to the coconut api
    ///   - mediaurl: send the media url as string
    ///   - nft: set the nft data as 0 or 1
    func callShareApi(params:[String:Any], mediaurl:String, nft:Int){
        
        
        if Connection.isConnectedToNetwork(){
            let login = SessionManager.sharedInstance.settingData?.data?.cocnutInfo?.coconutKey ?? ""//"k-bd65f20568d9a68aa5b89cbd088c7110"
            let password = ""
            let config = URLSessionConfiguration.default
            let userPasswordString = "\(login):\(password)"
            let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString()
            let authString = "Basic \(base64EncodedCredential)"
            config.httpAdditionalHeaders = ["Authorization" : authString]
            let session = URLSession(configuration: config)
            let url = Endpoints.coconutApi.rawValue
            let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          
            //request.setBasicAuth(username: "k-bd65f20568d9a68aa5b89cbd088c7110", password: "")
            //var params :[String: Any]?
            //params = ["username" : SessionManager.sharedInstance.getUserId]
            do{
               
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                    if let response = response {
                        let nsHTTPResponse = response as! HTTPURLResponse
                        let statusCode = nsHTTPResponse.statusCode
                        print ("status code = \(statusCode)")
                    }
                    if let error = error {
                        print ("\(error)")
                    }
                    if let data = data {
                        do{
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                            print ("data = \(jsonResponse)")
                            let decoder = JSONDecoder()
                            let nsHTTPResponse = response as! HTTPURLResponse
                            let statusCode = nsHTTPResponse.statusCode
                            print ("status code = \(statusCode)")
                            if jsonResponse != nil{
                                if statusCode == 201{
                                    let model = try decoder.decode(CoconutModel.self, from: data)
                                    print(model.id ?? "")
                                    DispatchQueue.main.async {
                                        
                                        self.callSaveApi(jobId: model.id ?? "", mediaurl: mediaurl)
                                    }
                                    
                                }
                                else{
                                    DispatchQueue.main.async {
                                    self.callSaveApi(jobId:"", mediaurl: mediaurl)
                                    }
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                self.callSaveApi(jobId:"", mediaurl: mediaurl)
                                }
                            }
                           
                            
                            
                            
                            
                        }catch _ {
                            DispatchQueue.main.async {
                            self.callSaveApi(jobId:"", mediaurl: mediaurl)
                            }
                            print ("OOps not good JSON formatted response")
                        }
                    }
                })
                task.resume()
            }catch _ {
                print ("Oops something happened buddy")
                DispatchQueue.main.async {
                self.callSaveApi(jobId:"", mediaurl: mediaurl)
                }
            }
        }
        else{
            self.appDelegate?.scheduleNotification(notificationType: "Upload Failed", sound: false)
        }
       
    }
    
    
    /// Call the save api whether it is to repost or normal post
    func callSaveApi(jobId:String, mediaurl:String){
        
        if FromLoopMonetize == 1 && multiplePost == 1{
            self.monetizeRepost(jobId: jobId, jobStatus: false, mediaType: MediaType.Video.rawValue, mediaContent: mediaurl, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "")
        }
        else{
            self.saveAPICall(mediaContent: mediaurl, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Video.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId:jobId)
        }
       
       
    }
    
    /// Set the current time in milliseconds
    /// - Returns: It returns the seconds as integer
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    /// Tells the delegate when the audio finishes playing.
    /// - Parameters:
    ///   - player: The audio player that finishes playing.
    ///   - flag: A Boolean value that indicates whether the audio finishes playing successfully.
    ///    - The system doesn’t call this method on an audio interruption.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBtn?.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.AudioAnimation.stopAnimatingGif()
    }
    
    
    ///  When move to tag search button is pressed it will open the tag search page
    @IBAction func moveToTagSearchButtonTapped(sender:UIButton) {
                
        self.playerController.player?.pause()
       // self.playerController.player = nil
        
        let tagSearchVC = self.storyboard?.instantiateViewController(identifier: "TagSearchViewController") as! TagSearchViewController
        tagSearchVC.view.backgroundColor = .black.withAlphaComponent(0)
        tagSearchVC.modalPresentationStyle = .popover
        self.present(tagSearchVC, animated: true, completion: nil)
    }
    
    
    /// intialise the video player and set the url to the avplayer
    func playVideoInPalyer(url:String) {
        self.avplayer = AVPlayer(url: URL.init(string: url) ?? NSURL.init() as URL)
        playerController.player = self.avplayer
        self.addChild(playerController)
        videoBgView?.addSubview(playerController.view)
        playerController.view.frame = videoBgView?.bounds ?? CGRect()
        playerController.showsPlaybackControls = true
        playerController.videoGravity = .resizeAspectFill
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController.player?.currentItem)
         //self.avplayer.play()
       
        //self.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
   
    /// After video or audio ended it starts from 0 seconds
    @objc func videoDidEnded (){
       // playerController.dismiss(animated: true,completion: nil)
        self.avplayer.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
    }
    
    
    
    /// Setup the ui for edit button
    func setUpUI() {
        editBtn?.layer.cornerRadius = 6.0
        editBtn?.clipsToBounds = true
        editBtn?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        tagTxtField?.layer.cornerRadius = 6.0
        tagTxtField?.clipsToBounds = true
        tagTxtField?.layer.borderWidth = 1.0
        tagTxtField?.layer.borderColor = UIColor.TextFieldBottomBorderColor.withAlphaComponent(0.3).cgColor
        
        
        
    }
    
    /// Asks the delegate whether to process the pressing of the Return button for the text field.
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: true if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /// Asks the delegate whether to change the specified text.
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range. During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text. When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: true if the specified text range should be replaced; otherwise, false to keep the old text.
    /// - The text field calls this method whenever user actions cause its text to change. Use this method to validate text as it is typed by the user. For example, you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == monetizeTextField{

            var max = ""
            
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                max = "\(SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0)"
            }
            else{
               max = "\(SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0)"
            }
           
            
            let maxLength = max.count
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            
            
            return newString.count <= maxLength
        }
        else{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            
            if newString.count >= 180 {
                showErrorAlert(error: "Maximum character limit reached.")
                return false
            }
            return true
        }
        
        
    }
    
    
    
    ///Back button pressed to dismiss and discard the media
    @IBAction func backButtonTapped(sender:UIButton) {
        
        let alert = UIAlertController(title: "Discard Spark media ?", message: "", preferredStyle: .actionSheet)
        
        //to change font of title and message.
        let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.veryLarge)]
        let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
        
        
        
        let titleAttrString = NSMutableAttributedString(string: "Discard Spark media ?", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "\nIf you go back now, you will lose any changes that you've made.", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
//        let updateButton = UIAlertAction(title: "Update Spark media", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
//            self.tabBarController?.tabBar.isHidden = true
//        })
//        //cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
//        alert.addAction(updateButton)
        
        
        
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (_) in
            

            SessionManager.sharedInstance.homeFeedsSwippedObject = nil
            SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
            
            self.tabBarController?.selectedIndex = 0
            
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            UserDefaults.standard.set("", forKey: "charPro0")
            UserDefaults.standard.set("", forKey: "valPro0")
            UserDefaults.standard.set("", forKey: "charPro1")
            UserDefaults.standard.set("", forKey: "valPro1")
            UserDefaults.standard.set("", forKey: "charPro2")
            UserDefaults.standard.set("", forKey: "valPro2")
            UserDefaults.standard.set("", forKey: "charBoost0")
            UserDefaults.standard.set("", forKey: "valBoost0")
            UserDefaults.standard.set("", forKey: "charBoost1")
            UserDefaults.standard.set("", forKey: "valBoost1")
            UserDefaults.standard.set("", forKey: "charBoost2")
            UserDefaults.standard.set("", forKey: "valBoost2")
            UserDefaults.standard.set("", forKey: "charDate0")
            UserDefaults.standard.set("", forKey: "valDate0")
            UserDefaults.standard.synchronize()
            
            if self.isFromPhotoModel == 1{
                if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                    self.dismiss(animated: true, completion: {
                        self.backtoMultipostDelegate?.back()
                    })
                }
                else{
                    self.dismiss(animated: true) {
                        self.delegate?.backFromAttachement()
                    }
                }
               
            }
            else{
                
                if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                    self.dismiss(animated: true, completion: {
                        self.backtoMultipostDelegate?.back()
                    })
                }
                else{
                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: Notification.Name("RepostUploadCancelled"), object: nil)
                                })
                                self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: Notification.Name("changeHomeIcon"), object: ["index":0])
                }
                
              

            }

//            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
//
           // self.dismiss(animated: true)
            
        }))
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            self.tabBarController?.tabBar.isHidden = true
        })
        //cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    
    
    /**
     Create a default items to select in the photo edit item
     */
    func createDefaultItems() -> [PhotoEditMenuItem] {
        let menuItems: [MenuItem?] = [
            ToolMenuItem.createCompositionOrTrimToolItem(),
            ToolMenuItem.createTransformToolItem(),
            ToolMenuItem.createFilterToolItem(),
            ToolMenuItem.createAdjustToolItem(),
            ToolMenuItem.createFocusToolItem(),
            ToolMenuItem.createStickerToolItem(),
            ToolMenuItem.createTextToolItem(),
            ToolMenuItem.createTextDesignToolItem(),
            ToolMenuItem.createOverlayToolItem(),
            ToolMenuItem.createFrameToolItem(),
            ToolMenuItem.createBrushToolItem()
        ]
        let photoEditMenuItems: [PhotoEditMenuItem] = menuItems.compactMap { menuItem in
            switch menuItem {
            case let menuItem as ToolMenuItem:
                return .tool(menuItem)
            case let menuItem as ActionMenuItem:
                return .action(menuItem)
            default:
                return nil
            }
        }
        
        return photoEditMenuItems
    }
    
    /// Edit button is tapped to edit the text or video or image
    @IBAction func editButtonTapped(sender:UIButton) {
        
        
        if typedQuestionDict["mediaType"] as? Int == MediaType.Text.rawValue {
            self.dismiss(animated: false) {
                NotificationCenter.default.post(name: Notification.Name("popToCreatePost"), object: nil)
            }
        }
        else if typedQuestionDict["mediaType"] as? Int == MediaType.Image.rawValue {
            let photo = Photo(image: selectedImage)
            let photoEditViewController = PhotoEditViewController(photoAsset: photo)
            photoEditViewController.delegate = self
            present(photoEditViewController, animated: true, completion: nil)
            
        }else if typedQuestionDict["mediaType"] as? Int == MediaType.Video.rawValue{
            self.playerController.player?.pause()
           
            let asset = AVAsset(url: URL.init(string: selectedVideoPath) ?? NSURL.init() as URL)
            
            let video = Video(asset: asset)
            let configuration = Configuration { builder in
              builder.configureVideoEditViewController { options in
                options.menuItems = createDefaultItems()
              }
            }
            let videoEditViewController = VideoEditViewController(videoAsset: video, configuration: configuration)
            videoEditViewController.delegate = self
            videoEditViewController.assetCatalog.audioClips.removeAll()
            present(videoEditViewController, animated: true, completion: nil)
        }
    }
    
    /// This method is used to pass the api calls and upload the text, Image, Video, audio and documents has been uploaded to server
    func SaveRetry(){
        if Connection.isConnectedToNetwork(){
           print("Connected")
            if typedQuestionDict["mediaType"] as? Int == MediaType.Text.rawValue {
                
                if FromLoopMonetize == 1 && multiplePost == 1{
                    self.dismiss(animated: true, completion: {
                        self.backtoMultipostDelegate?.back()
                    })
                }
                else if FromLoopMonetize == 2 && multiplePost == 0{
                    self.dismiss(animated: true, completion: {
                        self.backtoMultipostDelegate?.back()
                    })
                }
                else{
                    UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                    SessionManager.sharedInstance.selectedIndexTabbar = 0
                    
                    let presentingViewController = self.presentingViewController
                    self.dismiss(animated: false, completion: {
                        presentingViewController?.dismiss(animated: true, completion: {
                            //NotificationCenter.default.post(name: Notification.Name("UploadCompleted"), object: nil)
                            NotificationCenter.default.post(name: Notification.Name("InternetChecking"), object: nil)
                            
                        })
                    })
                }
                
            
                //self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                
                if FromLoopMonetize == 1 && multiplePost == 1{
                    self.monetizeRepost(jobId: "", jobStatus: true, mediaType: MediaType.Text.rawValue, mediaContent: "", bgColor: typedQuestionDict["bgColor"] as? String ?? "", txtColor: typedQuestionDict["textColor"] as? String ?? "")
                }
                else if FromLoopMonetize == 2 && multiplePost == 0{
                    self.saveAPICall(mediaContent: "", tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? repostTagValue : self.selectedTagValue, mediaType: MediaType.Text.rawValue, threadLimit: typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: typedQuestionDict["bgColor"] as? String ?? "", txtColor: typedQuestionDict["textColor"] as? String ?? "", postType: typedQuestionDict["postType"] as? Int ?? 0, postContent: typedQuestionDict["textViewValue"] as? String ?? "", nft: 0, jobId: "")
                }
                else{
                    self.saveAPICall(mediaContent: "", tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? repostTagValue : self.selectedTagValue, mediaType: MediaType.Text.rawValue, threadLimit: typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: typedQuestionDict["bgColor"] as? String ?? "", txtColor: typedQuestionDict["textColor"] as? String ?? "", postType: typedQuestionDict["postType"] as? Int ?? 0, postContent: typedQuestionDict["textViewValue"] as? String ?? "", nft: 0, jobId: "")
                }
                
                
            }
            else if typedQuestionDict["mediaType"] as? Int == MediaType.Video.rawValue {
                print(nftParam)
                
                if self.nftParam == 1{
                    let size = selectedVideoUrl.fileSize()
                    let medimaxLimit = SessionManager.sharedInstance.settingData?.data?.nFTInfo?.mediaMax ?? 0
                    if Double(size) > Double(medimaxLimit) {
                        self.showErrorAlert(error: "Please select a file less than or equal to \(medimaxLimit) MB")
                        self.dismiss(animated: true)
                    }
                    else{
                        
                        DispatchQueue.global(qos: .background).async {
                            
                            self.attachmentViewModel.getThumbnailImageFromVideoUrl(url: self.selectedVideoUrl) { (thumbImage) in
                                self.uploadThumpNailImageToBlob(thumpNailImage: thumbImage ?? UIImage())
                                
                            }
                            self.attachmentViewModel.convertVideoPathToData(fileUrl: self.selectedVideoUrl) { data in
                                DispatchQueue.main.async {
                                    
                                    self.attachmentViewModel.uploadVideoDataToBlob(data: data ?? Data()) { isSuccess, url in
                                        debugPrint(url)
                                        if isSuccess ?? Bool(){
                                            DispatchQueue.main.async {
                                                if self.player?.timeControlStatus == .playing{
                                                    self.player?.pause()
                                                }
                                                
                                                self.callcoconutapi(mediaUrl: url, nft:self.nftParam)
                                                print(self.nftParam)
                                            }
                                        }
                                        else{
                                            self.showErrorAlert(error: "Oops! Something went wrong")
                                        }
                                        
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                    self.dismiss(animated: true, completion: {
                                        self.backtoMultipostDelegate?.back()
                                    })
                                }
                                else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                                    self.dismiss(animated: true, completion: {
                                        self.backtoMultipostDelegate?.back()
                                    })
                                }
                                
                                else{
                                    
                                    UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                                    SessionManager.sharedInstance.selectedIndexTabbar = 0
                                    //
                                    let presentingViewController = self.presentingViewController
                                    self.dismiss(animated: false, completion: {
                                        presentingViewController?.dismiss(animated: true, completion: {
                                            NotificationCenter.default.post(name: Notification.Name("InternetChecking"), object: nil)
                                            
                                        })
                                    })
                                    self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                                }
                            }
                        }
                            
                            
                            
                      
                       //
                   
                    }
                }
                else{
                    
                    DispatchQueue.global(qos: .background).async {
                        self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: false)
                        NotificationCenter.default.post(name: Notification.Name("InternetChecking"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name("isUploading"), object: nil)
                        InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                            if megabytesPerSecond > 0.5{
                                self.attachmentViewModel.getThumbnailImageFromVideoUrl(url: self.selectedVideoUrl) { (thumbImage) in
                                    self.uploadThumpNailImageToBlob(thumpNailImage: thumbImage ?? UIImage())
                                    
                                }
                            }
                            else{
                                self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
                            }
                        }
                        
                        InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                            if megabytesPerSecond > 0.6{
                                self.attachmentViewModel.convertVideoPathToData(fileUrl: self.selectedVideoUrl) { data in
                                    DispatchQueue.main.async {
                                        // self.isCheckingConnectivity ? self.stopConnectivityChecks() : self.startConnectivityChecks()
                                        self.attachmentViewModel.uploadVideoDataToBlob(data: data ?? Data()) { isSuccess, url in
                                            debugPrint(url)
                                            
                                            DispatchQueue.main.async {
                                                InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                                                    print("My internet speed is \(megabytesPerSecond)")
                                                    if megabytesPerSecond > 0.5{
                                                        self.callcoconutapi(mediaUrl: url, nft:self.nftParam)
                                                    }
                                                    else{
                                                        self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
                                                    }
                                                }
                                                
                                                
                                                //
                                                print(self.nftParam)
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
                            }
                            
                        }
                    
                     
                        DispatchQueue.main.async {
                            if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                self.dismiss(animated: true, completion: {
                                    self.backtoMultipostDelegate?.back()
                                })
                            }
                            else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                                
                                
                                self.dismiss(animated: true, completion: {
                                    self.backtoMultipostDelegate?.back()
                                })
                            }
                            else{
                                UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                                SessionManager.sharedInstance.selectedIndexTabbar = 0
                                
                                let presentingViewController = self.presentingViewController
                                self.dismiss(animated: false, completion: {
                                    presentingViewController?.dismiss(animated: true, completion: {
                                        
                                        
                                    })
                                })
                                
                            }
                        }
                        
                    }
                    
                  
                }
                
            } else if typedQuestionDict["mediaType"] as? Int == MediaType.Image.rawValue {
                DispatchQueue.global(qos: .background).async {
                    print("This is run on the background queue")
                    self.uploadImageToBlob()
                    
                    DispatchQueue.main.async {
                        // print("This is run on the main queue, after the previous code in outer block")
                        if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                            self.dismiss(animated: true, completion: {
                                self.backtoMultipostDelegate?.back()
                            })
                        }
                        else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                            self.dismiss(animated: true, completion: {
                                self.backtoMultipostDelegate?.back()
                            })
                        }
                        else{
                            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                            NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                            SessionManager.sharedInstance.selectedIndexTabbar = 0
                            
                            let presentingViewController = self.presentingViewController
                            self.dismiss(animated: false, completion: {
                                presentingViewController?.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: Notification.Name("InternetChecking"), object: nil)
                                    //NotificationCenter.default.post(name: Notification.Name("UploadCompleted"), object: nil)
                                    
                                })
                            })
                        }
                     
                        self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                    }
                }
                //
                
            }
            else if typedQuestionDict["mediaType"] as? Int == MediaType.Document.rawValue {
                DispatchQueue.main.async {
                    DispatchQueue.global(qos: .background).async {
                        self.attachmentViewModel.uploadDocumentDataToBlob(data: self.selectedDocData, documentType: self.selectedDocTypeArray.last ?? "", subFolderName: "doc") { success, url, data  in
                            if success ?? false {
                                debugPrint(url)
                               
                                NotificationCenter.default.post(name: Notification.Name("InternetChecking"), object: nil)
                                DispatchQueue.main.async {
                                    if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                        self.monetizeRepost(jobId: "", jobStatus: true, mediaType: MediaType.Document.rawValue, mediaContent: url, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "")
                                    }
                                    else{
                                    self.saveAPICall(mediaContent: url, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Document.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId: "")
                                    }
                                    
                                    let fileSize = Float(Double(data.count)/1024/1024)
                                    print("File Size = \(fileSize) MB")
                                    if fileSize > 25{
                                        
                                    }
                                    else{
                                        self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                                    }
                                }
                                
                               
                            }
                        }
                        DispatchQueue.main.async {
                            
                            if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                self.dismiss(animated: true, completion: {
                                    self.backtoMultipostDelegate?.back()
                                })
                            }
                            else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                                self.dismiss(animated: true, completion: {
                                    self.backtoMultipostDelegate?.back()
                                })
                            }
                            else{
                                UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                                SessionManager.sharedInstance.selectedIndexTabbar = 0
                                
                                let presentingViewController = self.presentingViewController
                                self.dismiss(animated: false, completion: {
                                    presentingViewController?.dismiss(animated: true, completion: {
                                        
                                        //NotificationCenter.default.post(name: Notification.Name("UploadCompleted"), object: nil)
                                        
                                    })
                                })
                            }
                           
                           
                           
                            
                        }
                    }
                    
                 
                   
                    //}
                    
                    
                }
            }
            else if typedQuestionDict["mediaType"] as? Int == MediaType.Audio.rawValue || typedQuestionDict["mediaType"] as? Int == MediaType.RecordedAudio.rawValue {
                DispatchQueue.main.async {
                    
                    if self.nftParam == 1{
                        let fileSize = (Double(self.selectedDocData.count)/1024/1024)
                        let medimaxLimit = SessionManager.sharedInstance.settingData?.data?.nFTInfo?.mediaMax ?? 0
                        
                        if Double(fileSize) > Double(medimaxLimit) {
                            self.showErrorAlert(error: "Please select a file less than or equal to \(medimaxLimit) MB")
                            self.dismiss(animated: true)
                        }
                        else{
                            
                            DispatchQueue.global(qos: .background).async {
                                
                                self.attachmentViewModel.uploadAudioDataToBlob(data: self.selectedDocData, documentType: self.selectedDocTypeArray.last ?? "", subFolderName: "audio") { success, url in
                                    if success ?? false {
                                        debugPrint(url)
                                        DispatchQueue.main.async {
                                            if self.player?.timeControlStatus == .playing{
                                                self.player?.pause()
                                            }
                                            self.saveAPICall(mediaContent: url, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Audio.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId: "")
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    
                                    if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                        self.dismiss(animated: true) {
                                            self.delegate?.backFromAttachement()
                                        }
                                        self.dismiss(animated: true, completion: {
                                            self.backtoMultipostDelegate?.back()
                                        })
                                    }
                                    else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                                        self.dismiss(animated: true) {
                                            self.delegate?.backFromAttachement()
                                        }
                                    }
                                    else{
                                        self.dismiss(animated: true) {
                                            self.delegate?.backFromAttachement()
                                        }
                                        UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                        NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                                        SessionManager.sharedInstance.selectedIndexTabbar = 0
                                    }
                                    
                                    
                                   
                                    
                                  
                                    self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                                }
                            }
                         
                            
                          
                        }
                    }
                    else{
                        
                        DispatchQueue.global(qos: .background).async {
                            self.attachmentViewModel.uploadAudioDataToBlob(data: self.selectedDocData, documentType: self.selectedDocTypeArray.last ?? "", subFolderName: "audio") { success, url in
                                if success ?? false {
                                    debugPrint(url)
                                    DispatchQueue.main.async {
                                        
                                        if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                            self.monetizeRepost(jobId: "", jobStatus: true, mediaType: MediaType.Audio.rawValue, mediaContent: url, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "")
                                        }
                                        else{
                                            self.saveAPICall(mediaContent: url, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Audio.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId: "")
                                            
                                        }
                                        
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                
                                if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                    self.dismiss(animated: true, completion: {
                                        self.delegate?.backFromAttachement()
                                        self.backtoMultipostDelegate?.back()
                                    })
                                    
                                    
                                }
                                else if self.FromLoopMonetize == 2 && self.multiplePost == 0{
                                    self.dismiss(animated: true, completion: {
                                        self.delegate?.backFromAttachement()
                                        self.backtoMultipostDelegate?.back()
                                    })
                                    
                                    
                                }
                                else{
                                    UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":SessionManager.sharedInstance.selectedIndexTabbar == 1 ? 1 : 0])
                                    SessionManager.sharedInstance.selectedIndexTabbar = 0
                                    
                                    self.dismiss(animated: true) {
                                        self.delegate?.backFromAttachement()
                                    }
                                }
                               
                                self.appDelegate?.scheduleNotification(notificationType: "Sharing post", sound: true)
                            }
                            
                        }
                        
                        
                    
                    }
                    
                   
                }
            }
        
        }
        else{
            let alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)

            

            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
            // ... Do something
                self.navigationController?.popViewController(animated: true)
                self.MaininternetRetry()
               
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true) {
            // ... Do something
            }
            
        }
    }
    
    
    
    
    /// Check the monetization input alert with validation
    /// - Parameters:
    ///   - amount: Send the amount in the string
    ///   - isFromSummary: Set the boolean value to check whether it is from summary or not.
    func monetizationInputAlert(amount:String, isFromSummary:Bool) {
        
        let alert = UIAlertController(title: "Loop Value", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            let priceMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Min ?? 0
            let priceMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0
            let priceUsMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0
            let priceUSMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0
            
            self.monetizeTextField = textField
            //self.monetizeTextField.clearButtonMode = .always
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                self.monetizeTextField.placeholder = "₹\(priceMin) to ₹\(priceMax)"
            }
            else{
                self.monetizeTextField.placeholder = "$\(priceUsMin) to $\(priceUSMax)"
            }
            
            if isFromSummary{
                self.monetizeTextField.text = "\(amount)"
            }
            
            self.monetizeTextField.returnKeyType = .done
            self.monetizeTextField.keyboardType = .numberPad
            self.monetizeTextField.delegate = self
            
            //self.addDoneButtonOnKeyboard()
            
        }
        
        
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            textField?.keyboardType = .asciiCapableNumberPad
            let textValue = textField?.text
            let priceMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Min ?? 0
            let priceMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0
            let priceUsMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0
            let priceUSMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0
            if textValue?.isEmpty == true{
                //Toast(text: "Enter the Loop Value").show()
                self.showErrorAlert(error: "Enter the loop value")
                // Toast(text: "Hello, world!", duration: Delay.long)
                self.view.endEditing(true)
                self.monetizationInputAlert(amount: "", isFromSummary: false)
            }
        
            else{
                
                if self.nftParam == 1{
                    
                    
                    
                    if SessionManager.sharedInstance.saveCountryCode == "+91"{
                        if textValue == "0"{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 > SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 >= SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Min ?? 0{
                            let alert = UIAlertController(title: "", message: "Are you sure you want to post this NFT Spark? Once posted you will not be able to delete this NFT Spark.", preferredStyle: .alert)
                            
                            let deleteAction = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) in
                                print("Call the deletion function here")
                                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                                
                                self.tabBarController?.selectedIndex = 0
                                
                                SessionManager.sharedInstance.selectedIndexTabbar = 0
                                UserDefaults.standard.set("", forKey: "charPro0")
                                UserDefaults.standard.set("", forKey: "valPro0")
                                UserDefaults.standard.set("", forKey: "charPro1")
                                UserDefaults.standard.set("", forKey: "valPro1")
                                UserDefaults.standard.set("", forKey: "charPro2")
                                UserDefaults.standard.set("", forKey: "valPro2")
                                UserDefaults.standard.set("", forKey: "charBoost0")
                                UserDefaults.standard.set("", forKey: "valBoost0")
                                UserDefaults.standard.set("", forKey: "charBoost1")
                                UserDefaults.standard.set("", forKey: "valBoost1")
                                UserDefaults.standard.set("", forKey: "charBoost2")
                                UserDefaults.standard.set("", forKey: "valBoost2")
                                UserDefaults.standard.set("", forKey: "charDate0")
                                UserDefaults.standard.set("", forKey: "valDate0")
                                UserDefaults.standard.synchronize()
                                
                                
                                
                                //            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: Notification.Name("RepostUploadCancelled"), object: nil)
                                })
                                self.navigationController?.popViewController(animated: true)
                            })
                            alert.addAction(deleteAction)
                            
                            let postAction = UIAlertAction(title: "Continue", style: .default, handler: { action in
                                
                               // self.SaveRetry()
                                self.monetizeAmount = Int(textValue ?? "") ?? 0
                                self.monetizeSummaryView.isHidden = false
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                self.monetizeAmount = Int(textValue ?? "") ?? 0
                                print(self.monetizeAmount)
                                self.monetizeSummaryView.isHidden = false
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                UserDefaults.standard.set("", forKey: "charPro0")
                                UserDefaults.standard.set("", forKey: "valPro0")
                                UserDefaults.standard.set("", forKey: "charPro1")
                                UserDefaults.standard.set("", forKey: "valPro1")
                                UserDefaults.standard.set("", forKey: "charPro2")
                                UserDefaults.standard.set("", forKey: "valPro2")
                                UserDefaults.standard.set("", forKey: "charBoost0")
                                UserDefaults.standard.set("", forKey: "valBoost0")
                                UserDefaults.standard.set("", forKey: "charBoost1")
                                UserDefaults.standard.set("", forKey: "valBoost1")
                                UserDefaults.standard.set("", forKey: "charBoost2")
                                UserDefaults.standard.set("", forKey: "valBoost2")
                                UserDefaults.standard.set("", forKey: "charDate0")
                                UserDefaults.standard.set("", forKey: "valDate0")
                                UserDefaults.standard.synchronize()
                            })
                            alert.addAction(postAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                       
                        else{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                           
                        }
                    }
                    else if SessionManager.sharedInstance.saveCountryCode != ""{
                        if textValue == "0"{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceUsMin) to \(priceUSMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 > SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0{
                            let priceUsMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0
                            let priceUSMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceUsMin) to \(priceUSMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 >= SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0{
                            
                            let alert = UIAlertController(title: "", message: "Are you sure you want to post this NFT Spark? Once posted you will not be able to delete this NFT Spark.", preferredStyle: .alert)
                            
                            let deleteAction = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) in
                                print("Call the deletion function here")
                                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                                
                                self.tabBarController?.selectedIndex = 0
                                
                                SessionManager.sharedInstance.selectedIndexTabbar = 0
                                UserDefaults.standard.set("", forKey: "charPro0")
                                UserDefaults.standard.set("", forKey: "valPro0")
                                UserDefaults.standard.set("", forKey: "charPro1")
                                UserDefaults.standard.set("", forKey: "valPro1")
                                UserDefaults.standard.set("", forKey: "charPro2")
                                UserDefaults.standard.set("", forKey: "valPro2")
                                UserDefaults.standard.set("", forKey: "charBoost0")
                                UserDefaults.standard.set("", forKey: "valBoost0")
                                UserDefaults.standard.set("", forKey: "charBoost1")
                                UserDefaults.standard.set("", forKey: "valBoost1")
                                UserDefaults.standard.set("", forKey: "charBoost2")
                                UserDefaults.standard.set("", forKey: "valBoost2")
                                UserDefaults.standard.set("", forKey: "charDate0")
                                UserDefaults.standard.set("", forKey: "valDate0")
                                UserDefaults.standard.synchronize()
                                
                                
                                
                                //            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: Notification.Name("RepostUploadCancelled"), object: nil)
                                })
                                self.navigationController?.popViewController(animated: true)
                            })
                            alert.addAction(deleteAction)
                            
                            let postAction = UIAlertAction(title: "Continue", style: .default, handler: { action in
                                
                               // self.SaveRetry()
                                self.monetizeAmount = Int(textValue ?? "") ?? 0
                                self.monetizeSummaryView.isHidden = false
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                self.monetizeAmount = Int(textValue ?? "") ?? 0
                                print(self.monetizeAmount)
                                self.monetizeSummaryView.isHidden = false
                                self.tableView.delegate = self
                                self.tableView.dataSource = self
                                self.tableView.reloadData()
                                UserDefaults.standard.set("", forKey: "charPro0")
                                UserDefaults.standard.set("", forKey: "valPro0")
                                UserDefaults.standard.set("", forKey: "charPro1")
                                UserDefaults.standard.set("", forKey: "valPro1")
                                UserDefaults.standard.set("", forKey: "charPro2")
                                UserDefaults.standard.set("", forKey: "valPro2")
                                UserDefaults.standard.set("", forKey: "charBoost0")
                                UserDefaults.standard.set("", forKey: "valBoost0")
                                UserDefaults.standard.set("", forKey: "charBoost1")
                                UserDefaults.standard.set("", forKey: "valBoost1")
                                UserDefaults.standard.set("", forKey: "charBoost2")
                                UserDefaults.standard.set("", forKey: "valBoost2")
                                UserDefaults.standard.set("", forKey: "charDate0")
                                UserDefaults.standard.set("", forKey: "valDate0")
                                UserDefaults.standard.synchronize()
                            })
                            alert.addAction(postAction)
                            
                            self.present(alert, animated: true, completion: nil)
                         
                        }
                        
                       
                        else{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceUsMin) to \(priceUSMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                           
                        }
                    }
//                    else{
//
//                    }
//
                    
                    
                    
                    
                
                }
                else{
                   // print(textValue)
                    if SessionManager.sharedInstance.saveCountryCode == "+91"{
                        if textValue == "0"{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 > SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 >= SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Min ?? 0{
                            self.monetizeAmount = Int(textValue ?? "") ?? 0
                            print(self.monetizeAmount)
                            self.monetizeSummaryView.isHidden = false
                            self.tableView.delegate = self
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                        }
                        
                       
                        else{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceMin) to \(priceMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                           
                        }
                    }
                    else if SessionManager.sharedInstance.saveCountryCode != ""{
                        if textValue == "0"{
                            self.showErrorAlert(error: "Please enter the monetize amount")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 > SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0{
                            let priceUsMin = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0
                            let priceUSMax = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMax ?? 0
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceUsMin) to \(priceUSMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                        }
                        else if Int(textValue ?? "") ?? 0 >= SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.usMin ?? 0{
                            self.monetizeAmount = Int(textValue ?? "") ?? 0
                            print(self.monetizeAmount)
                            self.monetizeSummaryView.isHidden = false
                            self.tableView.delegate = self
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                        }
                        
                       
                        else{
                            self.showErrorAlert(error: "The amount value is only accepted between the \(priceUsMin) to \(priceUSMax)")
                            self.monetizationInputAlert(amount: "", isFromSummary:false)
                           
                        }
                    }
                    
                   
                    
                   
                    //self.SaveRetry()
                }
                
            }
            //            guard let textValue = textField?.text, !textValue.isEmpty else {
            //                // toast with a specific duration and position
            //               // self.view.makeToast("Please enter wallet address to continue.", duration: 3.0, position: .top)
            //                Toast(text: "Please enter wallet address to continue.").show()
            //               // Toast(text: "Hello, world!", duration: Delay.long)
            //                self.view.endEditing(true)
            //                self.monetizationInputAlert()
            //                return
            //            }
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  (_) in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// Post the the datas for NFT items and it will show the alert and discard buttons are also available
    func SurePost(){
        
        if monetizeSpark == 1{
            monetizationInputAlert(amount: "\(self.monetizeAmount)", isFromSummary: false)
        }
        
        else if self.nftParam == 1{
            
            let alert = UIAlertController(title: "", message: "Are you sure you want to post this NFT Spark? Once posted you will not be able to delete this NFT Spark.", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Discard", style: .destructive, handler: { (action) in
                print("Call the deletion function here")
                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                
                self.tabBarController?.selectedIndex = 0
                
                SessionManager.sharedInstance.selectedIndexTabbar = 0
                UserDefaults.standard.set("", forKey: "charPro0")
                UserDefaults.standard.set("", forKey: "valPro0")
                UserDefaults.standard.set("", forKey: "charPro1")
                UserDefaults.standard.set("", forKey: "valPro1")
                UserDefaults.standard.set("", forKey: "charPro2")
                UserDefaults.standard.set("", forKey: "valPro2")
                UserDefaults.standard.set("", forKey: "charBoost0")
                UserDefaults.standard.set("", forKey: "valBoost0")
                UserDefaults.standard.set("", forKey: "charBoost1")
                UserDefaults.standard.set("", forKey: "valBoost1")
                UserDefaults.standard.set("", forKey: "charBoost2")
                UserDefaults.standard.set("", forKey: "valBoost2")
                UserDefaults.standard.set("", forKey: "charDate0")
                UserDefaults.standard.set("", forKey: "valDate0")
                UserDefaults.standard.synchronize()
                
                
                //            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: Notification.Name("RepostUploadCancelled"), object: nil)
                })
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(deleteAction)
            
            let postAction = UIAlertAction(title: "Continue", style: .default, handler: { action in
                
                self.SaveRetry()
                UserDefaults.standard.set("", forKey: "charPro0")
                UserDefaults.standard.set("", forKey: "valPro0")
                UserDefaults.standard.set("", forKey: "charPro1")
                UserDefaults.standard.set("", forKey: "valPro1")
                UserDefaults.standard.set("", forKey: "charPro2")
                UserDefaults.standard.set("", forKey: "valPro2")
                UserDefaults.standard.set("", forKey: "charBoost0")
                UserDefaults.standard.set("", forKey: "valBoost0")
                UserDefaults.standard.set("", forKey: "charBoost1")
                UserDefaults.standard.set("", forKey: "valBoost1")
                UserDefaults.standard.set("", forKey: "charBoost2")
                UserDefaults.standard.set("", forKey: "valBoost2")
                UserDefaults.standard.set("", forKey: "charDate0")
                UserDefaults.standard.set("", forKey: "valDate0")
                UserDefaults.standard.synchronize()
            })
            alert.addAction(postAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            
            
        }
        
    }
    
    /// Enable the done button once user post it will diasbled for few seconds
    @objc func enableBtn(){
        self.doneBtn?.isEnabled = true
    }
    
    
    
    /// Save button tapped to post the datas to server
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(enableBtn), userInfo: nil, repeats: false)
        self.doneBtn?.isEnabled = false
        
        if FromLoopMonetize == 1 && multiplePost == 1{
            InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                if megabytesPerSecond > 0.3{
                    DispatchQueue.main.async {
                        self.SaveRetry()
                    }
                   
                }
                else{
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Poor network", message: "Please check your internet connection or try again later", preferredStyle: .alert)

                        

                        let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                        // ... Do something
                            self.doneBtn?.isEnabled = true
                            self.navigationController?.popViewController(animated: true)
                            //self.SaveRetry()
                           
                        }
                        alertController.addAction(OKAction)

                        self.present(alertController, animated: true) {
                        // ... Do something
                        }
                    }
                  
                }
            }
        }
        else if FromLoopMonetize == 2 && multiplePost == 0{
            self.isRepost = false
            let text = aboutPostTxtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if self.nftParam == 1{
                
                if text?.isEmpty ?? false || aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" {
                    self.showErrorAlert(error: "Please specify the caption to create your NFT")
                    return
                }
                else{
                    self.SurePost()
                }
            }
            
            else{
                InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                    if megabytesPerSecond > 0.3{
                        DispatchQueue.main.async {
                            self.SaveRetry()
                        }
                        
                    }
                    else{
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "Poor network", message: "Please check your internet connection or try again later", preferredStyle: .alert)
                            
                            
                            
                            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                                // ... Do something
                                self.navigationController?.popViewController(animated: true)
                                //self.SaveRetry()
                                
                            }
                            alertController.addAction(OKAction)
                            
                            self.present(alertController, animated: true) {
                                // ... Do something
                            }
                        }
                        
                    }
                }
            }
            
        }
        else{
            if SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? repostTagValue == "" : selectedTagValue == ""  {
                self.showErrorAlert(error: "Please choose your tag.")
                return
            }
            
            if txtView?.text.count ?? 0 > 2 && txtView?.text.isEmpty ?? false {
                self.showErrorAlert(error: "Please enter valid caption")
                return
            }
            
            if self.nftParam == 1 && monetizeSpark == 1{
                
                let text = aboutPostTxtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)

                if text?.isEmpty ?? false || aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" {
                    self.showErrorAlert(error: "Please specify the caption to create your NFT with monetize")
                    return
                }
                else{
                    self.SurePost()
                }
            }
            else if self.nftParam == 1{
                
                let text = aboutPostTxtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)

                if text?.isEmpty ?? false || aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" {
                    self.showErrorAlert(error: "Please specify the caption to create your NFT")
                    return
                }
                else{
                    self.SurePost()
                }
            }
            
            else if self.monetizeSpark == 1{
                
                let text = aboutPostTxtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)

                if text?.isEmpty ?? false || aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" {
                    self.showErrorAlert(error: "Please specify the caption to create your monetize")
                    return
                }
                else{
                    self.SurePost()
                }
            }
            
            else{
                if monetizeSpark == 0 && nftParam == 0{
                    
                    InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                        if megabytesPerSecond > 0.3{
                            DispatchQueue.main.async {
                                self.SaveRetry()
                            }
                           
                        }
                        else{
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Poor network", message: "Please check your internet connection or try again later", preferredStyle: .alert)

                                

                                let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                                // ... Do something
                                    self.navigationController?.popViewController(animated: true)
                                    //self.SaveRetry()
                                   
                                }
                                alertController.addAction(OKAction)

                                self.present(alertController, animated: true) {
                                // ... Do something
                                }
                            }
                          
                        }
                    }
                }
            }
        }
        
       
        
    
        
    }
    
    
    /// Upload a imgae to blob for azure and it will generate a link
    func uploadImageToBlob() {
        
        DispatchQueue.main.async {
            
            //Change to image data
            
            if self.nftParam == 1{
                let imageData = self.selectedImage.jpegData(compressionQuality: 0.5) ?? Data()
                
                let fileSize = (Double(imageData.count)/1024/1024)
                let medimaxLimit = SessionManager.sharedInstance.settingData?.data?.nFTInfo?.mediaMax ?? 0
                
                if Double(fileSize) > Double(medimaxLimit) {
                    self.showErrorAlert(error: "Please select a file less than or equal to \(medimaxLimit) MB")
                    self.dismiss(animated: true)
                }
                else{
                    self.attachmentViewModel.uploadImageToBlob(image: self.selectedImage) { success, url in
                        if success ?? false{
                            DispatchQueue.main.async {
                                self.saveAPICall(mediaContent: url, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Image.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId: "")
                                print(self.nftParam)
                            }
                        }
                    }
                }
            }
            else{
                self.attachmentViewModel.uploadImageToBlob(image: self.selectedImage) { success, url in
                    if success ?? false{
                        DispatchQueue.main.async {
                            
                            if self.FromLoopMonetize == 1 && self.multiplePost == 1{
                                self.monetizeRepost(jobId: "", jobStatus: true, mediaType: MediaType.Image.rawValue, mediaContent: url, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "")
                            }
                            else{
                                self.saveAPICall(mediaContent: url, tagValue: SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? self.repostTagValue : self.selectedTagValue, mediaType: MediaType.Image.rawValue, threadLimit: self.typedQuestionDict["threadLimit"] as? String ?? "", allowAnonymous: self.typedQuestionDict["allowAnonymous"] as? Bool ?? false, bgColor: self.typedQuestionDict["bgColor"] as? String ?? "", txtColor: self.typedQuestionDict["textColor"] as? String ?? "", postType: self.typedQuestionDict["postType"] as? Int ?? 0, postContent: self.typedQuestionDict["textViewValue"] as? String ?? "", nft: self.nftParam, jobId: "")
                            }
                            
                           
                            print(self.nftParam)
                        }
                    }
                }
            }
            
           
            
            
        }
    }
    
    /// Upload a thumbnail image to blob and set the image url with the varibale
    func uploadThumpNailImageToBlob(thumpNailImage:UIImage) {
       
        self.attachmentViewModel.uploadThumpNailImageToBlob(image: thumpNailImage) { success, url in
            if success ?? false{
                if success ?? Bool(){
                    DispatchQueue.main.async {
                        
                        self.thumpNailString = url
                        //self.saveAPICall(mediaContent: url, tagValue: "")
                    }
                }
                else{
                    self.showErrorAlert(error: "Please try again internet may slow!")
                }
                
            }
        }
    }
    
    //repostMonetize Api call
    
    /// Moentize repost will be happen and remove the notification
    /// - Parameters:
    ///   - jobId: Set th job id from the coconut  api
    ///   - jobStatus: Set the status of Coconut api data
    ///   - mediaType: Set the mediatype here text, image, video, audio and document
    ///   - mediaContent: Set the media content here
    ///   - bgColor: Check the bg color for the view
    ///   - txtColor: Send the text color to the api
    func monetizeRepost(jobId:String,jobStatus:Bool, mediaType:Int,mediaContent:String,bgColor:String,txtColor:String){
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let dict = [
            "postId":self.repostId,
            "jobId":jobId,
            "jobStatus":jobStatus,
            "mediaType":mediaType,
            "mediaUrl":mediaContent,
            "thumbNail":self.thumpNailString,
            "postContent":mediaType == MediaType.Text.rawValue ? "\(txtView?.text ?? "")" : aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" ? "" : "\(aboutPostTxtView?.text ?? "")",
            "bgColor":bgColor,
            "textColor":txtColor
        
        ] as [String : Any]
        viewModel.repostMonetizeApiCall(postDict: dict)
    }
    
    
    ///Save API call and pass the datas in the body parameters
    func saveAPICall(mediaContent:String,tagValue:String,mediaType:Int,threadLimit:String,allowAnonymous:Bool,bgColor:String,txtColor:String,postType:Int,postContent:String,nft:Int,jobId:String) {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
       
        if repostTagId != ""{
            self.isRepost = true
        }
        else{
            self.isRepost = false
        }
        
        
        let dict = [
            "postType": postType,
            "mediaType": mediaType,
            "postContent": mediaType == MediaType.Text.rawValue ? "\(txtView?.text ?? "")" : aboutPostTxtView?.text == " Caption your Spark but not longer than 180 words!" ? "" : "\(aboutPostTxtView?.text ?? "")",
            "bgColor":bgColor,
            "textColor":txtColor,
            "mediaUrl": mediaContent,
            "threadLimit":threadLimit,
            "tagId": SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0 ? repostTagId : self.selectedTagId,
            "tagName": tagValue,
            "lat": self.typedQuestionDict["lat"] ?? 0.0,
            "lng":self.typedQuestionDict["long"] ?? 0.0,
            "currencyCode" : self.currenyCode,
            "currencySymbol" : self.currencySymbol,
            "monetize" : self.monetizeSpark,
            "monetizeAmount":self.monetizeAmount,
            "closedUserList":self.typedQuestionDict["closedConnectionList"] ?? [],
            "allowAnonymous": allowAnonymous,
            "thumbNail":self.thumpNailString,
            "threadpostId": SessionManager.sharedInstance.homeFeedsSwippedObject != nil ? SessionManager.sharedInstance.homeFeedsSwippedObject?.postId ?? "" : SessionManager.sharedInstance.getTagNameFromFeedDetails?["postId"] as? String ?? "",
            "threaduserId": SessionManager.sharedInstance.homeFeedsSwippedObject != nil ? SessionManager.sharedInstance.homeFeedsSwippedObject?.userId ?? "" : SessionManager.sharedInstance.getTagNameFromFeedDetails?["userId"] as? String ?? "",
            "coordinates":self.typedQuestionDict["coordinates"] ?? 0.0,
            "attributes":self.attributeArray,
            "nft":nft,
            "jobId":jobId,
            "jobStatus":false,
            "isRepost": isRepost,
            "monetizePlatformAmount":self.monetizePlatformAmount,
            "monetizeTax":self.monetizeTax,
            "monetizeActualAmount":self.monetizeActualAmount
        ] as [String : Any]
        
        
        
        if FromLoopMonetize == 2 && multiplePost == 0{
            self.monetizePostApiCall(dict: dict)
        }
        else{
            self.createPostApiCallForText(dict: dict)
        }
        
    }
    
    
    /// Call the create post api to view model
    func createPostApiCallForText(dict:[String:Any]) {
        if Connection.isConnectedToNetwork(){
            viewModel.createPostApiCall(postDict: dict)
        }
        else{
            self.appDelegate?.scheduleNotification(notificationType: "Upload failed", sound: false)
        }
        
    }
    
    
    /// Call the monetize repost api call to view model
    func monetizePostApiCall(dict:[String:Any]) {
        if Connection.isConnectedToNetwork(){
            viewModel.monetizeRepostApiCall(postDict: dict)
        }
        else{
            self.appDelegate?.scheduleNotification(notificationType: "Upload failed", sound: false)
        }
        
    }
    
    /// Setup the create post view model whether the media is uploaded or not
    //View Model Setup
    func setupCreatePostMediaViewModel() {
        
        viewModel.createPostModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.showErrorAlert(error: error.localizedDescription)
                let presentingViewController = self.presentingViewController
                self.dismiss(animated: false, completion: {
                    presentingViewController?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: Notification.Name("UploadCompleted"), object: nil)
                        
                    })
                })
            }
            else if statusHttpCode.statusCode == 403{
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            else if statusHttpCode.statusCode == 400{
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            else{
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = 0
               // self.showErrorAlert(error: error.localizedDescription)
            }
            
        }
        viewModel.createPostModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                //Nil after repost success
                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                self.playerController.player?.pause()
                self.playerController.player = nil
                
                if value.data?.status == 2 { //Thread limit reached
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                
                self.typedQuestionDict = [:]
               // self.isAnonymousUserOn = false
                //Nil after repost success
                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                UIApplication.shared.applicationIconBadgeNumber = 0
                
             
            }
        }
    }
    
    // Check Nft user or not
    
    
    //Connectivity Check
    
    
    /// Check the connectivity notifier
    func configureConnectivityNotifier() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
    }

    /// Check the single connectivity check
    func performSingleConnectivityCheck() {
        connectivity.checkConnectivity { connectivity in
            self.updateConnectionStatus(connectivity.status)
        }
    }

    /// Start connectivity check
    func startConnectivityChecks() {
        //activityIndicator.startAnimating()
        connectivity.startNotifier()
        isCheckingConnectivity = true
       // segmentedControl.isEnabled = false
        //updateNotifierButton(isCheckingConnectivity: isCheckingConnectivity)
    }

    /// Stop the connectivity check
    func stopConnectivityChecks() {
       // activityIndicator.stopAnimating()
        connectivity.stopNotifier()
        isCheckingConnectivity = false
        //segmentedControl.isEnabled = true
       // updateNotifierButton(isCheckingConnectivity: isCheckingConnectivity)
    }

    
    /// Check the connection status connected via wifi, cellular, cellular without internet
    func updateConnectionStatus(_ status: Connectivity.Status) {
        switch status {
        case .connectedViaWiFi, .connectedViaCellular, .connected:
            print("Connected internet")
            break
            //statusLabel.textColor = UIColor.darkGreen
        case .connectedViaWiFiWithoutInternet, .connectedViaCellularWithoutInternet, .notConnected:
            print("From attachment Not Connected")
         
            //statusLabel.textColor = UIColor.red
        case .determining: break
            //statusLabel.textColor = UIColor.black
        }
        //statusLabel.text = status.description
        //segmentedControl.tintColor = statusLabel.textColor
    }

    
}







//#MARK: Pboto Editor Delegates
extension AttachmentViewController {
    /// Select the photo and save the image then set the uiimage in the variable
    /// - Parameters:
    ///   - photoEditViewController: Edit the image photo edit view controller
    ///   - image: Save the image using UIImage
    ///   - data: Save the image as data
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        selectedImage = image
        imageView?.image = selectedImage
        contentImageBgView?.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
   /// If failed to generate photo it will dismiss
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    /// User can cancel the photo edit
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Play the video and after edit the video
    func videoEditViewController(_ videoEditViewController: VideoEditViewController, didFinishWithVideoAt url: URL?) {
        selectedVideoPath = url?.absoluteString ?? ""
        dismiss(animated: true, completion: nil)
        playVideoInPalyer(url: selectedVideoPath)
    }
    
    /// If failed to generate Video it will dismiss
    func videoEditViewControllerDidFailToGenerateVideo(_ videoEditViewController: VideoEditViewController) {
        
    }
    
    
    
    /// User can cancel the video edit option
    func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

class VerticallyCenteredTextView: UITextView {
    
    /// Set the text in the textview vertically center
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

//#MARK : UITextView Delegate
extension  AttachmentViewController : UITextViewDelegate {
    
    /// Set the text count with limit of characters
    /// - Parameters:
    ///   - existingText: Already added text counts
    ///   - newText: Newly adding text counts
    ///   - limit: Set the limit of text count
    /// - Returns: Return as bool if the condition satisfied
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        print(text.count)
                return isAtLimit
    }
    
    
    
    
    /// Asks the delegate whether to replace the specified text in the text view.
    /// - Parameters:
    ///   - textView: The text view containing the changes.
    ///   - range: The current selection range. If the length of the range is 0, range reflects the current insertion point. If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character.

    ///   - text: The text to insert.
    /// - Returns: true if the old text should be replaced by the new text; false if the replacement operation should be aborted.
    ///  - The text view calls this method whenever the user types a new character or deletes an existing character. Implementation of this method is optional. You can use this method to replace text before it is committed to the text view storage. For example, a spell checker might use this method to replace a misspelled word with the correct spelling.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.textColor = UIColor.black
        
        //let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`~!@#$%^&*_+={}:;'<>.,?/0123456789 "
        
        //let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        //let new_String = (textView.text! as NSString).replacingCharacters(in: range, with: text) as NSString
//        let newText = textView.text.replacingCharacters(in: range, with: text)
//        let maxNumberOfLines = 4
//        let maxCharactersCount = 180
//        let underLineLimit = self.textView(textView, newText: newText, underLineLimit: maxNumberOfLines)
//        let underCharacterLimit = newText.count <= maxCharactersCount
//        let textCount = textView.text?.count ?? 0 + text.count - range.length
//        self.LblTextViewCount.text = "\(textCount)/180"
//        return underLineLimit && underCharacterLimit //newText.count <= 180 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        let newText = textView.text.replacingCharacters(in: range, with: text)
        let maxNumberOfLines = 4
        let maxCharactersCount = 180
        let underLineLimit = self.textView(textView, newText: newText, underLineLimit: maxNumberOfLines)
        let underCharacterLimit = newText.count <= maxCharactersCount
       
        
        if updatedText.count >= maxCharactersCount{
            self.LblTextViewCount.text = "\(180)/180"
            self.showErrorAlert(error: "Maximum character limit reached")
        }
        else{
            self.LblTextViewCount.text = "\(updatedText.count)/180"
        }
        // make sure the result is under 16 characters
        return updatedText.count <= maxCharactersCount && underLineLimit && underCharacterLimit
        
        
//        let currentText = textView.text ?? ""
//
//        // attempt to read the range they are trying to change, or exit if we can't
//        guard let stringRange = Range(range, in: currentText) else { return false }
//        let maxNumberOfLines = 4
//
//        // add their new text to the existing text
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//        let underLineLimit = self.textView(textView, newText: updatedText, underLineLimit: maxNumberOfLines)
//        //let underCharacterLimit = updatedText.count <= 180
//
//
//        self.LblTextViewCount.text  = "\(updatedText.count)/180"
//
//        if range.length >= 180 && text.isEmpty {
//            return false
//        }
//
//        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text)
//        if newString.count > 180 {
//            textView.text = String(newString.prefix(180))
//        }
//
//        // make sure the result is under 16 characters
//        return updatedText.count <= 180 && underLineLimit && newString.count <= 180
//
        //return self.textLimit(existingText: textView.text,
                              //newText: text,
                              //limit: 180)
    }
    
    
    /// Need to underline the text upto some value count
    /// - Parameters:
    ///   - textView: Added the textview of container to some limit
    ///   - newText: Add the new text as string
    ///   - underLineLimit: Underline the limit upto some text as limit count
    /// - Returns: It will returns the boolean value
    private func textView(_ textView: UITextView, newText: String, underLineLimit: Int) -> Bool {
            guard let textViewFont = textView.font else {
                return false
            }

            let rect = textView.frame.inset(by: textView.textContainerInset)
            let textWidth = rect.width - 2.0 * textView.textContainer.lineFragmentPadding

            let boundingRect = newText.size(constrainedToWidth: textWidth,
                                            font: textViewFont)

            let numberOfLines = boundingRect.height / textViewFont.lineHeight

            let underLimit = Int(numberOfLines) <= underLineLimit
            return underLimit
        }

    
    /// Tells the delegate when editing of the specified text view begins
    /// - Parameter textView: The text view in which editing began.
    /// Implementation of this method is optional. A text view sends this message to its delegate immediately after the user initiates editing in a text view and before any changes are actually made. You can use this method to set up any editing-related data structures and generally prepare your delegate to receive future editing messages.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == aboutPostTxtView{
            if  textView.text == " Caption your Spark but not longer than 180 words!" {
                textView.textColor = UIColor.black
                textView.text = ""
            }
        }
    }
    
    
    
    
    /// Tells the delegate when editing of the specified text view ends.
    /// - Parameter textView: The text view in which editing ended.
    /// - Implementation of this method is optional. A text view sends this message to its delegate after it closes out any pending edits and resigns its first responder status. You can use this method to tear down any data structures or change any state information that you set when editing began.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == aboutPostTxtView{
            if  (textView.text.isEmpty) {
                textView.text = " Caption your Spark but not longer than 180 words!"
                textView.textColor = UIColor.init(hexString: "A7A7A7").withAlphaComponent(0.8)
            }else {
                
            }
        }
    }
    
    
    /**
     Done button has been added in the keyboard to dismiss the keyboard.
     */
    fileprivate func doneButtonKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        aboutPostTxtView?.inputAccessoryView = doneToolbar
    }
    
    
    
    /**
     It is used to dimiss the current page
     */
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
}


extension AttachmentViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SparkpostFeeTableViewCell", for: indexPath) as! SparkpostFeeTableViewCell
            self.monetizeActualAmount = self.monetizeAmount
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                cell.sparkPostPrice.text = "₹\(self.monetizeAmount)"
            }
            else if SessionManager.sharedInstance.saveCountryCode == ""{
                cell.sparkPostPrice.text = "₹\(self.monetizeAmount)"
            }
            else{
                cell.sparkPostPrice.text = "$\(self.monetizeAmount)"
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sparkPostTaxFeeTableViewCell", for: indexPath) as! sparkPostTaxFeeTableViewCell
            
            cell.feeLbl.text = fees[indexPath.row - 1]
            
            
            
            
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                let indianPlatform = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaPlatform ?? 0)
                let indianrazorPay = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaRazorPay ?? 0)
                
                let monetizePlatformFee = Float(Float(self.monetizeAmount) * indianPlatform)/100
                let monetizeTax = Float((Float(self.monetizeAmount) + monetizePlatformFee ) * indianrazorPay)/100
                
                print(monetizePlatformFee)
                print(monetizeTax)
                let roundPlatform = round(monetizePlatformFee)
                let roundTax = round(monetizeTax)
                
                print("************************************")
                print(roundPlatform)
                print(roundTax)
                let totalPrice = Float(self.monetizeAmount) + roundPlatform + roundTax
                if indexPath.row == 1{
                    cell.feePrice.text = "₹\(Int(roundPlatform))"
                    self.monetizePlatformAmount = Int(roundPlatform)
                }
                else if indexPath.row == 2{
                    cell.feePrice.text = "₹\(Int(roundTax))"
                    self.monetizeTax = Int(roundTax)
                }
                else{
                    cell.feePrice.text = "₹\(Int(totalPrice))"
                }
                self.totalMonetizeAmount = Int(totalPrice)
                
            }
            else if SessionManager.sharedInstance.saveCountryCode == ""{
                let indianPlatform = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaPlatform ?? 0)
                let indianrazorPay = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaRazorPay ?? 0)
                
                let monetizePlatformFee = Float(Float(self.monetizeAmount) * indianPlatform)/100
                let monetizeTax = Float((Float(self.monetizeAmount) + monetizePlatformFee ) * indianrazorPay)/100
                
                print(monetizePlatformFee)
                print(monetizeTax)
                let roundPlatform = round(monetizePlatformFee)
                let roundTax = round(monetizeTax)
                
                print("************************************")
                print(roundPlatform)
                print(roundTax)
                let totalPrice = Float(self.monetizeAmount) + roundPlatform + roundTax
                if indexPath.row == 1{
                    cell.feePrice.text = "₹\(Int(roundPlatform))"
                    self.monetizePlatformAmount = Int(roundPlatform)
                }
                else if indexPath.row == 2{
                    cell.feePrice.text = "₹\(Int(roundTax))"
                    self.monetizeTax = Int(roundTax)
                }
                else{
                    cell.feePrice.text = "₹\(Int(totalPrice))"
                }
                self.totalMonetizeAmount = Int(totalPrice)
            }
            else{
                let usPlatform = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.usPlatform ?? 0)
                let usrazorPay = Float(SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.usRazorPay ?? 0)
                
                let monetizeusPlatformFee = Float(Float(self.monetizeAmount) * usPlatform)/100
                let monetizeusTax = Float((Float(self.monetizeAmount) + monetizeusPlatformFee ) * usrazorPay)/100
                
                print(monetizeusPlatformFee)
                print(monetizeusTax)
                let roundPlatform = round(monetizeusPlatformFee)
                let roundTax = round(monetizeusTax)
                
                print("************************************")
                print(roundPlatform)
                print(roundTax)
                let totalPrice = Float(self.monetizeAmount) + roundPlatform + roundTax
                if indexPath.row == 1{
                    cell.feePrice.text = "$\(Int(roundPlatform))"
                    self.monetizePlatformAmount = Int(roundPlatform)
                }
                else if indexPath.row == 2{
                    cell.feePrice.text = "$\(Int(roundTax))"
                    self.monetizeTax = Int(roundTax)
                }
                else{
                    cell.feePrice.text = "$\(Int(totalPrice))"
                }
                self.totalMonetizeAmount = Int(totalPrice)
            }
            return cell
        }
    }
    
    
    
    
    /// Asks the delegate for the height to use for a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
    ///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            if self.monetizeAmount == 0{
               return 0
            }
            else{
                return 70
            }
        }
        else if indexPath.row == 1{
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                let indianPlatform = SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaPlatform ?? 0
                
                
                if indianPlatform == 0{
                    return 0
                }
                else{
                    return 70
                }
            }
            else{
                let usPlatform = SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.usPlatform ?? 0
                if usPlatform == 0{
                    return 0
                }
                else{
                    return 70
                }
                
            }
        }
        else if indexPath.row == 2{
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                let indianrazorPay = SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.indiaRazorPay ?? 0
                if indianrazorPay == 0{
                    return 0
                }
                else{
                    return 70
                }
            }
            else{
                let usrazorPay = SessionManager.sharedInstance.settingData?.data?.PlatformInfo?.usRazorPay ?? 0
                if usrazorPay == 0{
                    return 0
                }
                else{
                    return 70
                }
            }
        }
        else{
            return 70
        }
        
    }
    
}

extension URL {
    /// Set the File size here with double value.
    func fileSize() -> Double {
        var fileSize: Double = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
        return fileSize
    }
}

extension AttachmentViewController: UIViewControllerTransitioningDelegate {
    /// Asks your delegate for the custom presentation controller to use for managing the view hierarchy when presenting a view controller.
    /// - Parameters:
    ///   - presented: The view controller being presented.
    ///   - presenting: The view controller that is presenting the view controller in the presented parameter. The object in this parameter could be the root view controller of the window, a parent view controller that is marked as defining the current context, or the last view controller that was presented. This view controller may or may not be the same as the one in the source parameter. This parameter may also be nil to indicate that the presenting view controller will be determined later.
    ///   - source: The view controller whose present(_:animated:completion:) method was called to initiate the presentation process.
    /// - Returns: The custom presentation controller for managing the modal presentation.
    ///  - When you present a view controller using the UIModalPresentationStyle.custom presentation style, the system calls this method and asks for the presentation controller that manages your custom style. If you implement this method, use it to create and return the custom presentation controller object that you want to use to manage the presentation process.
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension UITextView {

    ///  Set the vertical text as center in the textview
    func centerVerticalText() {
        self.textAlignment = .center
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}



extension URLRequest {
    
    /// Set the basic athentication method for coconut api url request
    /// - Parameters:
    ///   - username: Send the user name here
    ///   - password: send the password here for authentication and authorization
    mutating func setBasicAuth(username: String, password: String) {
        let encodedAuthInfo = String(format: "%@:%@", username, password)
            .data(using: String.Encoding.utf8)!
            .base64EncodedString()
        debugPrint(encodedAuthInfo)
        addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
        
    }
}


extension UIViewController{

    /// Global Alert
    /// Define Your number of buttons, styles and completion
    public func openAlert(title: String,
                          message: String,
                          alertStyle:UIAlertController.Style,
                          actionTitles:[String],
                          actionStyles:[UIAlertAction.Style],
                          actions: [((UIAlertAction) -> Void)]){

        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        for(index, indexTitle) in actionTitles.enumerated(){
            let action = UIAlertAction(title: indexTitle, style: actionStyles[index], handler: actions[index])
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
}

//extension AttachmentViewController : UITextFieldDelegate{
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let minPrice = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Min ?? 0
//        let maxPrice = SessionManager.sharedInstance.settingData?.data?.monetizeInfo?.Max ?? 0
//            if let text = textField.text, let amount = Int((text + string).trimmingCharacters(in: .whitespaces)),
//               (minPrice < amount), (amount < maxPrice) {
//                return true
//            }
//        else{
//            self.showErrorAlert(error: "Enter the valid monetize amount")
//        }
//            return false
//        }
//}



