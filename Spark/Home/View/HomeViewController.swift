//
//  HomeViewController.swift
//  Spark
//
//  Created by adhash on 29/06/21.
//

import UIKit
import SDWebImage
import Lottie
import AVKit
import AVFAudio
import Imaginary
import Contacts
import CoreLocation
import EasyTipView
import RSLoadingView
import LRSpotlight
import SwiftyGif
import MDatePickerView
import UIView_Shimmer
import Network
import CCBottomRefreshControl
import Kingfisher
import Connectivity

/**
 Get the full screen video delegate with current seconds
 */
protocol getPlayerVideoDelegate : AnyObject{
    func fullVideoScreenDismiss(currentSeconds:Double)
    
}


/// Call backoverlay delegate to dismiss the page of overlay with userid and indexpath
protocol backFromOverlay : AnyObject{
    func dismissOverlay(userId:String,IndexPath:Int)
    
}



/**
 This fragment class helps to list out other user spark post lists.It can be categorized into four types Global,Social,Closed and Local
- User can be able to repost,clap,eyeshot that post
 */
class HomeViewController: UIViewController, backToHomeFromDetailPage, getPlayerVideoDelegate, backFromOverlay, NetworkSpeedProviderDelegate, UITextViewDelegate {
    
    /// Dsimiss overlay with the userId and indexPath have been used to open the ConnectionList other user profile page
    func dismissOverlay(userId: String,IndexPath:Int) {
        print("Back from view")
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        connectionListVC.indexPath = IndexPath
        
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
    
    
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
            //DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
           // }
            break
        }
    }
   
    
    
    /// Requests the receiving responder to enable or disable the specified command in the user interface.
    /// - Parameters:
    ///   - action: A selector that identifies a method associated with a command. For the editing menu, this is one of the editing methods declared by the UIResponderStandardEditActions informal protocol (for example, copy:).
    ///   - sender: The object calling this method. For the editing menu commands, this is the shared UIApplication object. Depending on the context, you can query the sender for information to help you determine whether a command should be enabled.
    /// - Returns: true if the command identified by action should be enabled or false if it should be disabled. Returning true means that your class can handle the command in the current context.
    /// - This default implementation of this method returns true if the responder class implements the requested action and calls the next responder if it doesn’t. Subclasses may override this method to enable menu commands based on the current state; for example, you would enable the Copy command if there’s a selection or disable the Paste command if the pasteboard didn’t contain data with the correct pasteboard representation type. If no responder in the responder chain returns true, the menu command is disabled. Note that if your class returns false for a command, another responder further up the responder chain may still return true, enabling the command.
    /// - This method might be called more than once for the same action but with a different sender each time. You should be prepared for any kind of sender including nil.
    /// - For information on the editing menu, see the description of the UIMenuController class.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        OperationQueue.main.addOperation {
            UIMenuController.shared.setMenuVisible(false, animated: false)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    /// Get back from the feed detail page for select the tab bar
    /// According to the index and page limit set the selected tab bar and update the button when you are back from any of the page.
    func backToHomeFromDetail(indexPath: Int, selectedHomePageLimit: Int, postType: Int, isFromLink:Bool) {
        
        //        if isFromLink{
        //            isFromDetailPage = true
        //
        //            self.postType = postType
        //
        //            if postType == 1 {
        //                updateButtonSelection(globalBtn)
        //            } else if postType == 2 {
        //                updateButtonSelection(localBtn)
        //            } else if postType == 3 {
        //
        //                updateButtonSelection(socialBtn)
        //            } else if postType == 4 {
        //                updateButtonSelection(closedBtn)
        //            }
        //        }
        //        else{
        isFromDetailPage = true
        SessionManager.sharedInstance.isProfileUpdatedOrNot  = self.newUserProfile
        
        self.postType = postType
        
        if postType == 1 {
            updateButtonSelection(globalBtn)
            //self.navigationController?.popViewController(animated: true)
            SessionManager.sharedInstance.isFromLink = false
        } else if postType == 2 {
            updateButtonSelection(localBtn)
        } else if postType == 3 {
            
            updateButtonSelection(socialBtn)
        } else if postType == 4 {
            updateButtonSelection(closedBtn)
        }
        //  }
        
        
    }
    
    
    //    func backToHomeFromDetail(indexPath: Int, selectedHomePageLimit: Int) {
    //        isFromDetailPage = true
    ////        previousPageKey = selectedHomePageLimit
    ////        selectedRowFromDetailPage = indexPath
    ////        nextPageKey = selectedHomePageLimit
    //
    //        //homeRefresh(PageNumber: nextPageKey, PageSize: limit, postType: 1)
    //
    //    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    let viewModel = HomeViewModel()
    
    var nextPageKey = 1
    var previousPageKey = 1
    var limit = 20
    
    var isFromDetailPage = false
    var isFromProfilePage = false
    
    //    var selectedRowFromDetailPage = 0
    
    var homeBaseModel : homeBaseModel?
    
    var trailingBoolForSwipe = Bool()
    
    var selectedIndexPath = 0
    
    let refreshControl = UIRefreshControl()
    
    var clappedTagName = ""
    var nodess = [SpotlightNode]()
    let test = NetworkSpeedTest()
    
    fileprivate let connectivity = Connectivity()
    fileprivate var isCheckingConnectivity: Bool = false
    private var lastContentOffset: CGFloat = 0
    
    //paginator
    var loadingData = false
    //var loadingPreviousData = false
    var isAPICalled = false
    
    var repostSwippedDataIndexPath = 0
    var alertController = UIAlertController()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var attachmentViewModel = AttachmentViewModel()
    
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    @IBOutlet var noMoreView: UIView!
    
    
    
    var selectedDocUrl = URL.init(string: "") ?? URL(fileURLWithPath: "")
    
    // Thread popup objects
    @IBOutlet weak var threadPopUpBgView: UIView!
    @IBOutlet weak var threadPopUpView: Gradient!
    
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpMaybeLaterBtn: UIButton!
    @IBOutlet weak var threadPopUpStartThreadBtn: UIButton!
    
    var clapDataModel = [ClapData]()
    var threadpostId = ""
    var threaduserId = ""
    
    var contacts = [[String:Any]]()
    
    
    var telePhoneNumbers = [String]()
    
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var socialBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    
    @IBOutlet weak var globalLbl: UILabel!
    @IBOutlet weak var localLbl: UILabel!
    @IBOutlet weak var socialLbl: UILabel!
    @IBOutlet weak var closedLbl: UILabel!
    
    @IBOutlet weak var headerBtn: UIButton?
    @IBOutlet weak var loopBtn: UIButton!
    @IBOutlet weak var nftLogoImage: UIImageView!
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var collectionViewBottomHeightConstant: NSLayoutConstraint!
    
    
    var isLoading = false
    var selectedButton: UIButton? = nil
    
    var insertSize: CGFloat = 50
    var avPlayer = AVPlayer()
    
    var postType = 1
    
    var isLoadMore = false
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var locationManager = CLLocationManager()
    var latLong = [String:Any]()
    
    var playedVideoIndexPath = 0
    
    var currentIndexPath = IndexPath(row : 2, section : 0)
    
    var isFreshDataLoad = false
    
    var isPlayerFullScreenDismissed = false
    
    var preferences = EasyTipView.Preferences()
    
    var isPullRefresh = false
    var easyTipView : EasyTipView?
    
    var fullMediaUrl = ""
    var isUploading = false
    
    var newUserProfile = false
    
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newUserProfile = SessionManager.sharedInstance.isProfileUpdatedOrNot
        setupViewModel()
        self.setupNftViewModel()
        self.attachmentViewModel.createNftPostApiCall()
        
        self.loadingView.isHidden = true
        noMoreView.isHidden = true
        //collectionView.prefetchDataSource = self
        if !isPlayerFullScreenDismissed && !isFromDetailPage  && !SessionManager.sharedInstance.isImageFullViewed { //Not called when video full screen dismissed
            postType = 1
            
            limit = 20
            self.isLoading = true
            
            self.collectionView.setContentOffset(.zero, animated: true)
            
            self.homeRefresh(PageNumber: 1, PageSize: self.limit, postType: 1)
            
            updateButtonSelection(globalBtn)
            
            globalLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            
            globalBtn.setImage(UIImage(named: "global"), for: .normal)
            localBtn.setImage(UIImage(named: "localGray"), for: .normal)
            socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
            closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
        }else{
            
            let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
            let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
            if Connection.isConnectedToNetwork(){
                
                //cell?.playerController?.player?.play()
                // collectionView.reloadItems(at: [indexPath])
                //homeRefresh(PageNumber: 1, PageSize: limit, postType: 1)
            }
            else{
                cell?.playerController?.player?.pause()
            }
            
            SessionManager.sharedInstance.isImageFullViewed = false
            
            if postType == 1 {
                updateButtonSelection(globalBtn)
            } else if postType == 2 {
                updateButtonSelection(localBtn)
            } else if postType == 3 {
                updateButtonSelection(socialBtn)
            } else if postType == 4 {
                updateButtonSelection(closedBtn)
            }
            
            
            
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Loading new Sparks")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        threadPopUpStartThreadBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        threadPopUpStartThreadBtn.layer.cornerRadius = 6.0
        threadPopUpStartThreadBtn.clipsToBounds = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        easyTipViewSetUp()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(killedState), name: UIApplication.willTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushRedirectionFCM(notification:)), name: Notification.Name("PushRedirectionFCM"), object: nil)
        
        //NotificationCenter.default.addObserver(self,selector: #selector(statusManager),name: .flagsChanged,object: nil)
       // updateUserInterface()
        
        InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
            print("mb\(megabytesPerSecond)")
        }
        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom
        var tabBarheight = Int(self.tabBarController?.tabBar.frame.height ?? 0)
        tabBarheight = tabBarheight + Int(bottomPadding ?? 0)
        self.collectionViewBottomHeightConstant.constant = CGFloat(tabBarheight) + 10
       
    }
    
    /**
     Get the nft status to set nft in create post page.
     */
    func setupNftViewModel() {
        
        attachmentViewModel.nftPostModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        attachmentViewModel.nftPostModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            print(value)
            SessionManager.sharedInstance.isNFT = value.nftData?.nft ?? 0
            SessionManager.sharedInstance.isMonetize = value.nftData?.monetize ?? 0
            SessionManager.sharedInstance.isKYC = value.nftData?.isKYC ?? false
            SessionManager.sharedInstance.isAgree = value.nftData?.isAgree ?? 0
            SessionManager.sharedInstance.isSkip = value.nftData?.isSkip ?? false
//            DispatchQueue.main.async {
//
//                self.tableView?.reloadData()
//
//            }
            
        }
    
    }
    
    /// When it is uploading and app get closed trigger the notification
    @objc func isUploadingState(){
        self.isUploading = true
        NotificationCenter.default.addObserver(self, selector: #selector(killedState), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    /// Call the load more api when we are loading in bottom it will call the loadmore api with pagination
    @objc func refreshBottom() {
         //api call for loading more data
         loadMoreData()
    }
    

    /// In killed state method it will trigger the notification that upload will be cancelled
    @objc func killedState(){
        if isUploading{
            self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
            isUploading = false
        }
        else{
            isUploading = false
        }
    }
    
    
    /// Refresh the page by when swipping from top of the page in tableview
    /// - call the api to load
    @objc func refresh(_ sender: AnyObject) {
        
        viewModel.feedListData = []
        isPullRefresh = true
        
        if isPullRefresh{
            self.globalBtn.isEnabled = false
            self.localBtn.isEnabled = false
            self.socialBtn.isEnabled = false
            self.closedBtn.isEnabled = false
        }
        self.collectionView.reloadData()
        self.isLoading = true
        getNotificationPreviousListValues(PageNumber: 1, PageSize: limit, postType: postType, previousPage: previousPageKey > 0 ? previousPageKey - 1 : previousPageKey)
        
        //refreshControl.endRefreshing()
    }
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    /// Declare the tableview scroll to pause the player when it is playing
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method as the user’s finger touches up as it’s moving during a scrolling operation; the scroll view continues to move a short distance afterwards. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        
        print(viewModel.feedListData.count)
        
        if viewModel.feedListData.count > 0{
            let monetize = viewModel.feedListData[indexPath.item ?? 0].monetize ?? 0
            
            if monetize == 1{
                let cell = collectionView?.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                
                //cell?.audioAnimationBg.stopAnimatingGif()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                
            }
            else{
                let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                
                //cell?.audioAnimationBg.stopAnimatingGif()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
            }
        }
        
           
        //cell?.isReuse = true
       // cell?.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0
        
       
        
        print("scrolling")
        
    }

    
    /// When app moved to background , it will pause the player
    @objc func appMovedToBackground() {
        print("App moved to background!")
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        cell?.playerController?.player?.pause()
        if Connection.isConnectedToNetwork(){
        }
        else{
            cell?.playerController?.player?.pause()
            
        }
        
    }
    
    
    /// When app moved to foregound , set the cell
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = self.collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        if Connection.isConnectedToNetwork(){
            
        }
        else{
            cell?.playerController?.player?.pause()
            
            
        }
        
        
    }
    
   
    
    
    /// On tapping the header of sparkme logo it will call the document view web page.
    @IBAction func headerButtonTapped(_ sender: UIButton) {
        
        //RSLoadingView().showOnKeyWindow()
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
        docVC.url = SessionManager.sharedInstance.settingData?.data?.versionInfo?.tutorialUrl ?? ""
        self.present(docVC, animated: true, completion: nil)
        
    }
    
    
    /// When the scroll getting ends it will dismiss the pop tip of tag
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        easyTipView?.dismiss()
        
        
    }
    
    ///Global method has been set here highlight the global button
    func global(){
        globalLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
        localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        
        globalBtn.setImage(UIImage(named: "global"), for: .normal)
        localBtn.setImage(UIImage(named: "localGray"), for: .normal)
        socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
        closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
        postType = 1
        homeRefresh(PageNumber: 1, PageSize: limit, postType: 1)
    }
    
    /// Post type button action handling to select the post type
    @IBAction func postTypeButtonTapped(_ sender: UIButton) {
        if Connection.isConnectedToNetwork(){
            
            isFromDetailPage = false
            self.collectionView.setContentOffset(.zero, animated: true)
            easyTipView?.dismiss()
            
            
            
                
                
            let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
            
            print(viewModel.feedListData.count)
            
            if viewModel.feedListData.count > 0{
                let monetize = viewModel.feedListData[indexPath.item].monetize ?? 0
                
                if monetize == 1{
                    let cell = collectionView?.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                    
                    //cell?.audioAnimationBg.stopAnimatingGif()
                    
                    cell?.playerController?.player?.pause()
                    cell?.avplayer?.pause()
                    
                }
                else{
                    let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                    
                    //cell?.audioAnimationBg.stopAnimatingGif()
                    
                    cell?.playerController?.player?.pause()
                    cell?.avplayer?.pause()
                }
            }
//            cell?.playerController?.player?.pause()
//            cell?.audioAnimationBg.stopAnimatingGif()
            
            
            viewModel.feedListData = []
            if(selectedButton == nil) { // No previous button was selected
                
                updateButtonSelection(sender)
                
            } else{ // User have already selected a button
                
                if(selectedButton != sender){ // Not the same button
                    
                    selectedButton?.backgroundColor = self.linearGradientColor(
                        from: [UIColor.white, UIColor.white],
                        locations: [0, 1],
                        size: CGSize(width: 500, height:500)
                    )
                    selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                    selectedButton?.layer.borderWidth = 0.5
                    selectedButton?.layer.cornerRadius = 9
                    selectedButton?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                    updateButtonSelection(sender)
                }
                
            }
            
            if sender.tag == 0 {
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                print(indexPath.row)
                
                
                globalLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                self.collectionView.reloadData()
                self.isLoading = true
                globalBtn.setImage(UIImage(named: "global"), for: .normal)
                localBtn.setImage(UIImage(named: "localGray"), for: .normal)
                socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
                postType = 1
                nextPageKey = 1
                self.loadingData = true
                
                homeRefresh(PageNumber: 1, PageSize: limit, postType: 1)
                
                
                
                
               
                //}
                
            } else if sender.tag == 1 {
                
                
                globalLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                self.collectionView.reloadData()
                self.isLoading = true
                globalBtn.setImage(UIImage(named: "global"), for: .normal)
                localBtn.setImage(UIImage(named: "localGray"), for: .normal)
                socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
                
                updateButtonSelection(globalBtn)
                
                localBtn?.backgroundColor = self.linearGradientColor(
                    from: [UIColor.white, UIColor.white],
                    locations: [0, 1],
                    size: CGSize(width: 500, height:500)
                )
                localBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                localBtn?.layer.borderWidth = 0.5
                localBtn?.layer.cornerRadius = 9
                localBtn?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                
                
                let locationManager = CLLocationManager()
                
                //            if CLLocationManager.locationServicesEnabled() {
                
                if #available(iOS 14.0, *) {
                    
                    switch locationManager.authorizationStatus {
                        
                    case .notDetermined, .restricted, .denied:
                        print("No access")
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        
                        //to change font of title and message.
                        let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                        let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                        
                        let titleAttrString = NSMutableAttributedString(string: "Location Permission", attributes: titleFont)
                        let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to Location to get your nearest spark. Go to Settings to grant access.\n", attributes: messageFont)
                        
                        alert.setValue(titleAttrString, forKey: "attributedTitle")
                        alert.setValue(messageAttrString, forKey: "attributedMessage")
                        
                        if let settings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settings) {
                            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                                
                                UIApplication.shared.open(settings)
                            })
                        }
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                            self.global()
                        })
                        self.present(alert, animated: true)
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Access")
                        
                        globalLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        localLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                        socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        self.collectionView.reloadData()
                        self.isLoading = true
                        globalBtn.setImage(UIImage(named: "globalGray"), for: .normal)
                        localBtn.setImage(UIImage(named: "local"), for: .normal)
                        socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                        closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
                        
                        updateButtonSelection(localBtn)
                        
                        globalBtn?.backgroundColor = self.linearGradientColor(
                            from: [UIColor.white, UIColor.white],
                            locations: [0, 1],
                            size: CGSize(width: 500, height:500)
                        )
                        globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                        globalBtn?.layer.borderWidth = 0.5
                        globalBtn?.layer.cornerRadius = 9
                        globalBtn?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                        
                        postType = 2
                        nextPageKey = 1
                        self.loadingData = true
                        homeRefresh(PageNumber: 1, PageSize: limit, postType: 2)
                        
                        
                    @unknown default:
                        break
                    }
                } else {
                    // Fallback on earlier versions
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        print("No access")
                        
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        
                        //to change font of title and message.
                        let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                        let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                        
                        let titleAttrString = NSMutableAttributedString(string: "Location Permission", attributes: titleFont)
                        let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to Location to get your nearest spark. Go to Settings to grant access.\n", attributes: messageFont)
                        
                        alert.setValue(titleAttrString, forKey: "attributedTitle")
                        alert.setValue(messageAttrString, forKey: "attributedMessage")
                        
                        if let settings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settings) {
                            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                                
                                UIApplication.shared.open(settings)
                            })
                        }
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                            self.global()
                        })
                        self.present(alert, animated: true)
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Access")
                        
                        globalLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        localLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                        socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                        self.collectionView.reloadData()
                        self.isLoading = true
                        globalBtn.setImage(UIImage(named: "globalGray"), for: .normal)
                        localBtn.setImage(UIImage(named: "local"), for: .normal)
                        socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                        closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
                        
                        updateButtonSelection(localBtn)
                        
                        globalBtn?.backgroundColor = self.linearGradientColor(
                            from: [UIColor.white, UIColor.white],
                            locations: [0, 1],
                            size: CGSize(width: 500, height:500)
                        )
                        globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                        globalBtn?.layer.borderWidth = 0.5
                        globalBtn?.layer.cornerRadius = 9
                        globalBtn?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                        
                        postType = 2
                        nextPageKey = 1
                        self.loadingData = true
                        homeRefresh(PageNumber: 1, PageSize: limit, postType: 2)
                        
                    @unknown default:
                        break
                    }
                    
                }
                
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                
                print(viewModel.feedListData.count)
                
             
                //            } else {
                //                print("Location services are not enabled")
                //            }
                
                
                
            } else if sender.tag == 2 {
                
                globalLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                socialLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                self.collectionView.reloadData()
                self.isLoading = true
                globalBtn.setImage(UIImage(named: "globalGray"), for: .normal)
                localBtn.setImage(UIImage(named: "localGray"), for: .normal)
                socialBtn.setImage(UIImage(named: "social"), for: .normal)
                closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
                postType = 3
                homeRefresh(PageNumber: 1, PageSize: limit, postType: 3)
                
                
                
            } else if sender.tag == 3 {
                
                globalLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                closedLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                self.collectionView.reloadData()
                self.isLoading = true
                globalBtn.setImage(UIImage(named: "globalGray"), for: .normal)
                localBtn.setImage(UIImage(named: "localGray"), for: .normal)
                socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                closedBtn.setImage(UIImage(named: "closed"), for: .normal)
                postType = 4
                nextPageKey = 1
                self.loadingData = true
                homeRefresh(PageNumber: 1, PageSize: limit, postType: 4)
            
            }
            
        
        }
    }
    
    /// Update the button selected with highlight using gradient
    func updateButtonSelection(_ sender: UIButton){
        
        selectedButton = sender
        selectedButton?.backgroundColor = self.linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0, 1],
            size: CGSize(width: 100, height:40)
        )
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 9
        selectedButton?.setTitleColor(#colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1), for: .normal)
        
    }
    
    
    /// RTefresh the home feeds with feedlist data to set empty array, accordig to the post type it will be refresh
    func homeRefresh(PageNumber:Int,PageSize:Int,postType:Int) {
        //RSLoadingView().showOnKeyWindow()
        viewModel.feedListData = []
        
        self.globalBtn.isEnabled = false
        self.localBtn.isEnabled = false
        self.socialBtn.isEnabled = false
        self.closedBtn.isEnabled = false
        
        if postType == 1{
            self.globalBtn.isEnabled = true
        }
        else if postType == 2{
            self.localBtn.isEnabled = true
        }
        else if postType == 3{
            self.socialBtn.isEnabled = true
        }
        else if postType == 4{
            self.closedBtn.isEnabled = true
        }
        
        let params = [
            "postType" :postType,
            "coordinates":[postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0 : 0.0,postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0 : 0.0],
            "paginator":[
                "nextPage": 1,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
        
        viewModel.homeListApiCallNoLoading(postDict: params)
    }
    
    
    /// Call the load more api with pagination has been set.
    func getNotificationListValues(PageNumber:Int,PageSize:Int,postType:Int) {
        
        let params = [
            "postType" :postType,
            "coordinates":[postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0 : 0.0,postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0 : 0.0],
            "paginator":[
                "nextPage": nextPageKey,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
        //RSLoadingView.hideFromKeyWindow()
        viewModel.homeListApiCallNoLoading(postDict: params)
    }
    
    ///Call the load more api with pagination has been set and with with the previous page number
    func getNotificationPreviousListValues(PageNumber:Int,PageSize:Int,postType:Int,previousPage:Int) {
        
        let params = [
            "postType" :postType,
            "coordinates":[postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0 : 0.0,postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0 : 0.0],
            "paginator":[
                "nextPage":  1,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
        
        viewModel.homeListApiCallNoLoading(postDict: params)
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData {
            limit = 20
            self.loadingData = true
            self.nextPageKey = self.viewModel.homeBaseModel.value?.data?.paginator?.nextPage ?? 0
            getNotificationListValues(PageNumber: nextPageKey, PageSize: limit, postType:postType)
        }
        else {
            self.noMoreView.isHidden = true
        }
    }
    
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.isLoading = true
       
        NotificationCenter.default.addObserver(self, selector: #selector(isUploadingState), name: Notification.Name("isUploading"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(internetChecking), name: Notification.Name("InternetChecking"), object: nil)
        connectivity.framework = .systemConfiguration
        performSingleConnectivityCheck()
        configureConnectivityNotifier()
        isCheckingConnectivity ? stopConnectivityChecks() : startConnectivityChecks()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            if SessionManager.sharedInstance.settingData?.data?.versionInfo?.tutorialView == true {
                self.headerBtn?.isHidden = false
            }else {
                self.headerBtn?.isHidden = true
            }
        }
        self.headerBtn?.setTitle("", for: .normal)
        
        SessionManager.sharedInstance.isUserPostId = ""
        
        isFreshDataLoad = true
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        if cell?.isFullscreen == true{
            cell?.isFullscreen = false
        }
        
        //debugPrint("Token: \(SessionManager.sharedInstance.getAccessToken)")
       // print(self.tabBarController?.selectedIndex)
        
        if self.tabBarController?.selectedIndex ?? 0 == 1 || self.tabBarController?.selectedIndex ?? 0 == 3 || self.tabBarController?.selectedIndex ?? 0 == 4 {
            if !isPlayerFullScreenDismissed && !isFromDetailPage  && !SessionManager.sharedInstance.isImageFullViewed { //Not called when video full screen dismissed
                postType = 1
                
                limit = 20
                self.btnReset()
                
                self.collectionView.setContentOffset(.zero, animated: true)
                isLoading = true
                self.homeRefresh(PageNumber: 1, PageSize: self.limit, postType: 1)
                
                updateButtonSelection(globalBtn)
                
                globalLbl.textColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
                
                globalBtn.setImage(UIImage(named: "global"), for: .normal)
                localBtn.setImage(UIImage(named: "localGray"), for: .normal)
                socialBtn.setImage(UIImage(named: "SocialGray"), for: .normal)
                closedBtn.setImage(UIImage(named: "closedGray"), for: .normal)
            }else{
                self.isLoading = false
                
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                if Connection.isConnectedToNetwork(){
                    
                    //cell?.playerController?.player?.play()
                    // collectionView.reloadItems(at: [indexPath])
                    //homeRefresh(PageNumber: 1, PageSize: limit, postType: 1)
                }
                else{
                    cell?.playerController?.player?.pause()
                }
                
                SessionManager.sharedInstance.isImageFullViewed = false
                
                if postType == 1 {
                    updateButtonSelection(globalBtn)
                } else if postType == 2 {
                    updateButtonSelection(localBtn)
                } else if postType == 3 {
                    updateButtonSelection(socialBtn)
                } else if postType == 4 {
                    updateButtonSelection(closedBtn)
                }
                
                
                
            }
        }
        
        isAPICalled = false
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        self.tabBarController?.tabBar.isHidden = false
        
        let profilePicUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] ?? "")"
        //value.data?.gender == 1 ?  "Male" : value.data?.gender == 2 ? "Female" : "Others"
        self.userImgView.setImage(
            url: URL.init(string: profilePicUrl) ?? URL(fileURLWithPath: ""),
            placeholder: #imageLiteral(resourceName: SessionManager.sharedInstance.saveGender == 1 ?  "no_profile_image_male" : SessionManager.sharedInstance.saveGender == 2 ? "no_profile_image_female" : "others"))
        
        let nft = SessionManager.sharedInstance.saveUserDetails["nft"] ?? 0
        if nft as! Int == 1{
            self.nftLogoImage.isHidden = false
        }
        else{
            self.nftLogoImage.isHidden = true
        }
        self.userImgView.layer.cornerRadius = 6.0
        self.userImgView.clipsToBounds = true
        
        threadPopUpBgView.isHidden = true
        threadPopUpBgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveToCreateSpark), name: Notification.Name("FromDetailToCreateSpark"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(highlightHomeIcon(notification:)), name: Notification.Name("changeHomeIcon"), object: nil)
        
        //
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("listenPostLink"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("listenProfiletLink"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("NFTPostLink"), object: nil)
        //NFTPostLink
        if SessionManager.sharedInstance.getAccessToken != "" {
            NotificationCenter.default.addObserver(self, selector: #selector(openPostDetail), name: Notification.Name("listenPostLink"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(openProfile), name: Notification.Name("listenProfiletLink"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(openNFTPostDetail), name: Notification.Name("NFTPostLink"), object: nil)
        }
        
        
        SessionManager.sharedInstance.isBoolForInshortsLayout = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "NewsCardCollectionCell", bundle: nil), forCellWithReuseIdentifier: "NewsCardCollectionCell")
        self.collectionView.register(UINib.init(nibName: "MonetizeNewscardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MonetizeNewscardCollectionViewCell")
        self.collectionView.register(UINib.init(nibName: "LoadmoreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadmoreCollectionViewCell")
        
//        //self.collectionView.setContentOffset(.zero, animated: true)
//        let bottomRefreshController = UIRefreshControl()
//        bottomRefreshController.triggerVerticalOffset = 50
//        bottomRefreshController.attributedTitle =  NSAttributedString(string: "Loading Sparks")
//        bottomRefreshController.tintColor = UIColor.defaultTintColor
//        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
//        collectionView.bottomRefreshControl = bottomRefreshController
//
        
        
    }
    
    
    
    
    
    /// Open the post detail page when the user clicked the link to open the post
    @objc func openPostDetail(notification:NSNotification){
        
        
        
        Spotlight().delegate?.didDismiss()
        let postId = "\((notification.object as? [String:Any])?["postId"] as? String ?? "")"
        let threadId = "\((notification.object as? [String:Any])?["threadId"] ?? "")"
        let userId = "\((notification.object as? [String:Any])?["userId"] ?? "")" //"\((notification.object as? [String:Any])?["userId"] as? String ?? "")"
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
        detailVC.postId = postId
        detailVC.threadId = threadId
        SessionManager.sharedInstance.threadId = threadId
        SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
        
        detailVC.myPostId = postId
        detailVC.myThreadId = threadId
        detailVC.myUserId = userId
        
        detailVC.isFromBubble = false
        detailVC.isFromHomePage = true
        detailVC.isfromLink = true
        detailVC.postType = self.postType
        // detailVC.selectedHomePageIndexPath = indexPath
        detailVC.delegate = self
        SessionManager.sharedInstance.selectedIndexTabbar = 0
        self.navigationController?.pushViewController(detailVC, animated: true)
        SessionManager.sharedInstance.linkFeedPostId = ""
        SessionManager.sharedInstance.linkFeedProfileUserId = ""
        SessionManager.sharedInstance.linkFeedThreadId = ""
        SessionManager.sharedInstance.isFeedFromBeforeLogin = false
        SessionManager.sharedInstance.isPostFromLink = true
        
    }
    
    /// When we get a push notification it will move from home page to feed detail page
    @objc func pushRedirectionFCM(notification:NSNotification) {
        
        let postId = "\((notification.object as? [String:Any])?["postId"] as? String ?? "")"
        let threadId = "\((notification.object as? [String:Any])?["threadId"] as? String ?? "")"
        let userId = "\((notification.object as? [String:Any])?["userId"] as? String ?? "")"
        let notifyType = "\((notification.object as? [String:Any])?["typeOfnotify"] as? String ?? "")"
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        cell?.playerController?.quitFullScreen()
        self.dismiss(animated: false)
        if notifyType == "1" || notifyType == "2" {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
            detailVC.postId = postId
            detailVC.threadId = threadId
            SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
            SessionManager.sharedInstance.threadId = threadId
            
            detailVC.myPostId = postId
            detailVC.myThreadId = threadId
            detailVC.myUserId = userId
            
            detailVC.isFromBubble = false
            detailVC.isFromHomePage = false
            detailVC.postType = 0
            detailVC.delegate = self
            detailVC.isFromNotificationPage = true
            detailVC.postType = self.postType
            detailVC.delegate = self
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            self.navigationController?.pushViewController(detailVC, animated: true)
            
        }
        
        else if notifyType == "5" || notifyType == "6" { //Approval and Reveal request
            print("Its notified")
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.selectedIndex = 3
            SessionManager.sharedInstance.selectedIndexTabbar = 3
            //NotificationCenter.default.post(name: Notification.Name("SelectNotificationTabBar"), object: nil)
            //
             NotificationCenter.default.post(name: Notification.Name("DetailToNotificvationTab"), object: ["index":3])
            
            
            self.tabBarController?.tabBar.isHidden = false
            
            //self.navigationController?.popViewController(animated: true)
        }
        else if notifyType == "7" || notifyType == "3" {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let feedDetailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
            feedDetailVC.postId = postId
            feedDetailVC.threadId = threadId
            
            feedDetailVC.myPostId = postId
            feedDetailVC.myThreadId = threadId
            feedDetailVC.myUserId = userId
            
            
            
            feedDetailVC.isFromBubble = false
            feedDetailVC.isCallBubbleAPI = false
            feedDetailVC.isFromNotificationPage = true
            SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
            SessionManager.sharedInstance.threadId = threadId
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            self.navigationController?.pushViewController(feedDetailVC, animated: true)
        }
        
        else if notifyType == "8"{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let feedDetailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
            feedDetailVC.postId = postId
            feedDetailVC.threadId = threadId
            
            feedDetailVC.myPostId = postId
            feedDetailVC.myThreadId = threadId
            feedDetailVC.myUserId = userId
            
            
            
            feedDetailVC.isFromBubble = false
            feedDetailVC.isCallBubbleAPI = false
            feedDetailVC.isFromNotificationPage = true
            SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
            SessionManager.sharedInstance.threadId = threadId
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            self.navigationController?.pushViewController(feedDetailVC, animated: true)
        }
        
        else if notifyType == "9" || notifyType == "10"{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
            detailVC.postId = postId
            detailVC.threadId = threadId
            SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
            SessionManager.sharedInstance.threadId = threadId
            
            detailVC.myPostId = postId
            detailVC.myThreadId = threadId
            detailVC.myUserId = userId
            
            detailVC.isFromBubble = false
            detailVC.isFromHomePage = false
            detailVC.postType = 0
            detailVC.delegate = self
            detailVC.isFromNotificationPage = true
            detailVC.postType = self.postType
            detailVC.delegate = self
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        
    }
    
    
    ///Check the internet speed here
    @objc func internetChecking(){
        self.test.delegate = self
        self.test.networkSpeedTestStop()
        self.test.networkSpeedTestStart(UrlForTestSpeed: "https://www.google.com")
        InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
            print("mb\(megabytesPerSecond)")
            if megabytesPerSecond < 0.5{
               
            }
        }
    
    }
    
    /// Dismiss the fullscreen video with current seconds
    func fullVideoScreenDismiss(currentSeconds:Double){
        
        isPlayerFullScreenDismissed = true
        
        
    }
    
    
    /// Connectivity Check Notifier will start and check the status
    func configureConnectivityNotifier() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
    }

    /// Perform the simngle connectivity check  and update the status
    func performSingleConnectivityCheck() {
        connectivity.checkConnectivity { connectivity in
            self.updateConnectionStatus(connectivity.status)
        }
    }

    /// Start the notifier to check and check the connectivity boolean
    func startConnectivityChecks() {
        //activityIndicator.startAnimating()
        connectivity.startNotifier()
        isCheckingConnectivity = true
       // segmentedControl.isEnabled = false
        //updateNotifierButton(isCheckingConnectivity: isCheckingConnectivity)
    }

    ///  Stop the notifier
    func stopConnectivityChecks() {
       // activityIndicator.stopAnimating()
        connectivity.stopNotifier()
        isCheckingConnectivity = false
        //segmentedControl.isEnabled = true
       // updateNotifierButton(isCheckingConnectivity: isCheckingConnectivity)
    }

    /// Update the connection status with connected to wifi, mobile, hotspot or without internet
    func updateConnectionStatus(_ status: Connectivity.Status) {
        switch status {
        case .connectedViaWiFi, .connectedViaCellular, .connected:
            print("Connected internet")
            break
            //statusLabel.textColor = UIColor.darkGreen
        case .connectedViaWiFiWithoutInternet, .connectedViaCellularWithoutInternet, .notConnected:
            print("Not Connected")
            //self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: true)
            //statusLabel.textColor = UIColor.red
        case .determining:
            print("determining")
            break
            //statusLabel.textColor = UIColor.black
        }
        //statusLabel.text = status.description
        //segmentedControl.tintColor = statusLabel.textColor
    }
    
    /// Open the profile using redirection of notification or link
    @objc func openProfile(notification:NSNotification){
        Spotlight().delegate?.didDismiss()
        let userId = "\((notification.object as? [String:Any])?["userId"] ?? "")"
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        self.navigationController?.pushViewController(connectionListVC, animated: true)
        SessionManager.sharedInstance.linkProfileUserId = ""
        SessionManager.sharedInstance.isProfileFromBeforeLogin = false
        
    }
    
    
    /// Open the NFT post detail page
    @objc func openNFTPostDetail(notification:NSNotification){
        Spotlight().delegate?.didDismiss()
        let postId = "\((notification.object as? [String:Any])?["postId"] as? String ?? "")"
        // let threadId = "\((notification.object as? [String:Any])?["threadId"] ?? "")"
        let userId = "\((notification.object as? [String:Any])?["userId"] ?? "")"
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "NftFeedDetailViewController") as! NftFeedDetailViewController
        vc.postId = postId
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
        SessionManager.sharedInstance.linkNFTProfileUserId = ""
        SessionManager.sharedInstance.linkNFTPostId = ""
        SessionManager.sharedInstance.linkNFTThreadId = ""
        SessionManager.sharedInstance.isNftFromBeforeLogin = false
        
        
    }
    
    /// Highlight the home icon
    @objc func highlightHomeIcon(notification:NSNotification) {
        
        print("My Home selected")
        
        //NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":1])
        
        //self.tabBarController?.selectedIndex = 0
        
    }
    //
    
    /// Move to craete post from home page
    @objc func moveToCreateSpark() {
        NotificationCenter.default.post(name: Notification.Name("detailToCreatePostBackButton"), object: ["index":0])
        // self.tabBarController?.selectedIndex = 2
    }
    
    
    /// Open the profile page when user tap their own profile image
    @IBAction func profileBtnTapped(sender:UIButton) {
        SessionManager.sharedInstance.selectedIndexTabbar = 0
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    /// Thread button is tapped to open the bubbleview controller with selected tab bar
    @IBAction func threadBtnTapped(sender:UIButton) {
        SessionManager.sharedInstance.selectedIndexTabbar = 0
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let bubbleVC = storyBoard.instantiateViewController(identifier: "BubbleViewController") as! BubbleViewController
        self.navigationController?.pushViewController(bubbleVC, animated: true)
    }
    
    
    /// Get the viewmodel with the observer to get all the values from api and refresh the data
    /// - If link user id and is from profile open connectionlist profile page
    /// - If link nft id empty and lft link post id empty and is nft before login empty call nft feed detail view controller
    /// -
    //View Model Setup
    func setupViewModel() {
        //RSLoadingView().showOnKeyWindow()
        viewModel.homeBaseModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            print(error)
            self.refreshControl.endRefreshing()
//            self.collectionView.bottomRefreshControl?.endRefreshing()
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.homeBaseModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            print(value)
            if value.isOk ?? false {
                
                //                self.tableView.setContentOffset(.zero, animated: true)
                self.collectionView.refreshControl?.endRefreshing()
                self.refreshControl.endRefreshing()
//                self.collectionView.bottomRefreshControl?.endRefreshing()
                
                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                
                //Save user details
                SessionManager.sharedInstance.saveUserDetails["currentUsername"] = value.data?.currentUsername
                SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = value.data?.currentProfilePic
                SessionManager.sharedInstance.saveUserDetails["nft"] = value.data?.nft
                SessionManager.sharedInstance.saveGender = value.data?.currentUserGender ?? 0
               
                if value.data?.nft == 1{
                    self.nftLogoImage.isHidden = false
                }
                else{
                    self.nftLogoImage.isHidden = true
                }
                
                let profilePicUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(value.data?.currentProfilePic ?? "")"
                
                self.userImgView.setImage(
                    url: URL.init(string: profilePicUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: value.data?.currentUserGender == 1 ?  "no_profile_image_male" : value.data?.currentUserGender == 2 ? "no_profile_image_female" : "others"))
                
                if self.viewModel.feedListData.count > 0 {
                    
                    if self.viewModel.homeBaseModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.feedListData.count > 0 { //Loading
                        self.isAPICalled = true
                        self.noDataImg.isHidden = true
                        self.noDataLbl.isHidden = true
                        self.collectionView.isHidden = false
                        DispatchQueue.main.async {
                            self.activityIndicator.startAnimating()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                self.isLoading = false
                                self.collectionView.reloadData()
                                self.loadingView.isHidden = true
                                self.globalBtn.isEnabled = true
                                self.localBtn.isEnabled = true
                                self.socialBtn.isEnabled = true
                                self.closedBtn.isEnabled = true
                            }
                         
                            print(SessionManager.sharedInstance.linkProfileUserId)
                            if !SessionManager.sharedInstance.linkProfileUserId.isEmpty && SessionManager.sharedInstance.isProfileFromBeforeLogin{
                                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                                let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
                                connectionListVC.userId = SessionManager.sharedInstance.linkProfileUserId
                                self.navigationController?.pushViewController(connectionListVC, animated: true)
                                SessionManager.sharedInstance.linkProfileUserId = ""
                                SessionManager.sharedInstance.isProfileFromBeforeLogin = false
                                SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                                SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                            }
                            else if !SessionManager.sharedInstance.linkNFTProfileUserId.isEmpty && !SessionManager.sharedInstance.linkNFTPostId.isEmpty && SessionManager.sharedInstance.isNftFromBeforeLogin {
                                
                                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                                let vc = storyBoard.instantiateViewController(withIdentifier: "NftFeedDetailViewController") as! NftFeedDetailViewController
                                vc.postId = SessionManager.sharedInstance.linkNFTPostId
                                vc.userId = SessionManager.sharedInstance.linkNFTProfileUserId
                                self.navigationController?.pushViewController(vc, animated: true)
                                SessionManager.sharedInstance.linkNFTPostId = ""
                                SessionManager.sharedInstance.linkNFTProfileUserId = ""
                                SessionManager.sharedInstance.isNftFromBeforeLogin = false
                                SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                                SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                                
                                
                            }
                            else if !SessionManager.sharedInstance.linkFeedPostId.isEmpty && !SessionManager.sharedInstance.linkFeedProfileUserId.isEmpty && SessionManager.sharedInstance.isFeedFromBeforeLogin {
                                let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                                let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                                detailVC.postId = SessionManager.sharedInstance.linkFeedPostId
                                detailVC.threadId = SessionManager.sharedInstance.linkFeedThreadId
                                SessionManager.sharedInstance.threadId = SessionManager.sharedInstance.linkFeedThreadId
                                SessionManager.sharedInstance.userIdFromSelectedBubbleList = SessionManager.sharedInstance.linkFeedProfileUserId
                                detailVC.isFromBubble = false
                                detailVC.isFromHomePage = true
                                detailVC.postType = self.postType
                                
                                detailVC.myPostId = SessionManager.sharedInstance.linkFeedPostId
                                detailVC.myThreadId = SessionManager.sharedInstance.linkFeedThreadId
                                detailVC.myUserId = SessionManager.sharedInstance.linkFeedProfileUserId
                                // detailVC.selectedHomePageIndexPath = indexPath
                                detailVC.delegate = self
                                SessionManager.sharedInstance.selectedIndexTabbar = 0
                                self.navigationController?.pushViewController(detailVC, animated: true)
                                SessionManager.sharedInstance.linkFeedPostId = ""
                                SessionManager.sharedInstance.linkFeedProfileUserId = ""
                                SessionManager.sharedInstance.linkFeedThreadId = ""
                                SessionManager.sharedInstance.isFeedFromBeforeLogin = false
                                SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                                SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
                                SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                                
                                
                            }
                            
                            
                            //                            if self.isFromDetailPage {
                            //                                self.isFromDetailPage = false
                            //                                let indexPaths = IndexPath(row: self.selectedRowFromDetailPage, section: 0)
                            //                                self.collectionView?.scrollToItem(at: indexPaths, at: .bottom, animated: false)
                            //                            }
                            self.loadingData = false
                            
                        }
                    }else {
                        //No extra data available
                        self.isAPICalled = true
                        self.noDataLbl.isHidden = true
                        self.noDataImg.isHidden = true
                        self.collectionView.isHidden = false
                        DispatchQueue.main.async {
                            self.loadingData = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isLoading = false
                                self.collectionView.reloadData()
                                self.loadingView.isHidden = true
                                self.loadingView.isHidden = true
                                self.globalBtn.isEnabled = true
                                self.localBtn.isEnabled = true
                                self.socialBtn.isEnabled = true
                                self.closedBtn.isEnabled = true
                            }
                            
                           
                            
                            
                            //                            if self.isFromDetailPage {
                            //                                self.isFromDetailPage = false
                            //                                let indexPaths = IndexPath(row: self.selectedRowFromDetailPage, section: 0)
                            //                                self.collectionView?.scrollToItem(at: indexPaths, at: .bottom, animated: false)
                            //                            }
                            
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        self.isLoading = false
                        self.globalBtn.isEnabled = true
                        self.localBtn.isEnabled = true
                        self.socialBtn.isEnabled = true
                        self.closedBtn.isEnabled = true
                    }
                    self.loadingData = true
                    self.noDataImg.isHidden = false
                    self.noDataLbl.isHidden = false
                    self.collectionView.isHidden = true
                    self.loadingView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
            
        }
        
    }
    
    
    ///Setup the home clap model to clap the post
    func setupHomeClapViewModel(tag:Int) {
        
        viewModel.homeClapModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            
            print("Error")
            print(statusHttpCode.statusCode)
            if statusHttpCode.statusCode == 404{
                //self.remove(tag)
                self.remove(tag)
                self.showErrorAlert(error: error.localizedDescription)
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
        }
        viewModel.homeClapModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            print("Success")
            print(statusHttpCode.statusCode)
            
            if value.isOk ?? false {
                
                self.clapDataModel = value.data ?? [ClapData]()
                self.trailingBoolForSwipe = true
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                if self.clapDataModel.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.threadPopUpBgView.isHidden = false
                        self.threadPopUpDesclbl.text = "You have clapped \(self.clappedTagName) spark \nDo you want continue to create a Loop"
                    }
                }
            }
        }
        
    }
    
    
    /// If post deleted use the remove method to remove the current cell and refresh
    func remove(_ i: Int) {

        viewModel.feedListData.remove(at: i)
        

        let indexPath = IndexPath(row: i, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        self.fullMediaUrl = ""
        self.collectionView.reloadItems(at: [indexPath])
        
//        self.collectionView.performBatchUpdates({
//            self.collectionView.deleteItems(at: [indexPath])
//        }) { (finished) in
//
//        }

    }
    
    
    /// Check the thread limit and observe the value and se repost to be true
    func checkThreadLimitObserverForRepost(tag:Int) {
        
        viewModel.checkThreadLimitModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            print(error)
            if statusHttpCode.statusCode == 404{
                self.remove(tag)
                self.showErrorAlert(error: error.localizedDescription)
            }
            else{
            self.showErrorAlert(error: error.localizedDescription)
            }
        }
        viewModel.checkThreadLimitModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            print(value)
            if value.isOk ?? false {
                
                if value.data?.status == 2 {
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                else if value.data?.status == 1 { //Allow to create repost
                    SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                    SessionManager.sharedInstance.homeFeedsSwippedObject = self.viewModel.feedListData[self.repostSwippedDataIndexPath]
                    SessionManager.sharedInstance.isRepost = true
                    self.tabBarController?.selectedIndex = 2
                }
                
            }
        }
        
    }
    
    
    ///Check the thread limit with observer value and check for loop joining
    func checkThreadLimitObserverForClapAndLoopCreation(tag:Int) {
        
        viewModel.checkThreadLimitModelForClapAndLoopRequest.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                 self.remove(tag)
                self.showErrorAlert(error: error.localizedDescription)
            }
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.checkThreadLimitModelForClapAndLoopRequest.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.status == 2 {
                    self.threadPopUpBgView.isHidden = true
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                else if value.data?.status == 1 { //Allow to create repost
                    self.threadPopUpBgView.isHidden = true
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                    let clappedTagSelectionVC = storyBoard.instantiateViewController(identifier: CLAPPED_TAG_SPARK_SELECTION_STORYBOARD) as! ClappedTagRelatedSparkViewController
                    clappedTagSelectionVC.clapDataModel = self.clapDataModel
                    clappedTagSelectionVC.threadpostId = self.threadpostId
                    clappedTagSelectionVC.threaduserId = self.threaduserId
                    self.navigationController?.pushViewController(clappedTagSelectionVC, animated: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFromDetailPage = false
        easyTipView?.dismiss()
        
        
        self.nodess.removeAll()
        
        if viewModel.feedListData.count > 0{
            guard let indexPath = collectionView.indexPathsForVisibleItems.first else {
                return
            }

            let monetize = viewModel.feedListData[indexPath.item].monetize
            
            if monetize == 1{
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView?.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                cell?.test.networkSpeedTestStop()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                cell?.activityLoader.isHidden = true
            }
            else{
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                cell?.test.networkSpeedTestStop()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                cell?.activityLoader.isHidden = true
            }
        }
      
        
    }
    
    
    
    /// Reset the button with selected gradient
    func btnReset(){
        selectedButton?.backgroundColor = self.linearGradientColor(
            from: [UIColor.white, UIColor.white],
            locations: [0, 1],
            size: CGSize(width: 500, height:500)
        )
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 9
        selectedButton?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
        
        globalLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        localLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        socialLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
        closedLbl.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
    }
    
}

//#MARK: Start Thread View Actions
extension HomeViewController {
    
    /// It will hide the thread pop bg view
    @IBAction func mayBeLaterButtonTapped(sender:UIButton) {
        threadPopUpBgView.isHidden = true
    }
    
    
    /// Start thread button tapped to check the limit with post id and user id
    @IBAction func startThreadButtonTapped(sender:UIButton) {
        
        checkThreadLimitObserverForClapAndLoopCreation(tag: sender.tag)
        
        viewModel.checkThreadLimitAPICallForClapAndLoopRequest(postDict: ["threadpostId":self.viewModel.feedListData[selectedIndexPath].postId ?? "","threaduserId":self.viewModel.feedListData[selectedIndexPath].userId ?? ""])
        
    }
}


/**
 Extend to set the location manager
 */
extension HomeViewController : CLLocationManagerDelegate {
    ///Location manager delegate to set the coordintes of latitute and longitude
    /// - Parameters:
    ///     - manager: CLLocationManager to detect the current location
    ///     - locations: Array of CLLocation to set the latitude and longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        SessionManager.sharedInstance.saveUserCurrentLocationDetails = ["lat":locValue.latitude,"long":locValue.longitude]
        locationManager.stopUpdatingLocation()
    }
    
}


extension HomeViewController: UIViewControllerTransitioningDelegate {
    /// The presentation controller that’s managing the current view controller.
    /// - Parameters:
    ///   - presented: A vc that presents already
    ///   - presenting: A vc thats going to present now
    ///   - source: From the present vc it will shown
    /// - Returns: It will returns the currently opened vc
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}



/// This extension class is used to get the delegates of video or audio player dismiss the fullscreen to get the indexpath of currently playing
extension HomeViewController : getPlayerVideoAudioIndexDelegate {
    func videoPlayerFullScreenDismiss() {
        isPlayerFullScreenDismissed = true
        print("Exit")
        
        
    }
    
    func getPlayVideoIndex(index: Int) {
        debugPrint(index)
        playedVideoIndexPath = index
        self.callViewObserver()
        self.callViews(postId: self.viewModel.feedListData[index].postId ?? "")
    }
    
    func callAudioAnimation(isPlaying: Bool) {
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        if isPlaying == true{
            //cell?.audioAnimationBg.startAnimatingGif()
        }
        else{
            //cell?.audioAnimationBg.stopAnimatingGif()
        }
    }
    
    func callViewObserver(){
        viewModel.eyeShotModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            print(error)
            self.refreshControl.endRefreshing()
        }
        viewModel.eyeShotModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
        }
    }
    
    func playViewed(sender: Int) {
        
    }
    
}

extension HomeViewController {
    /// Setup the tag view with splash theme colour
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
}


extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
   
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - collectionView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }
        else{
            return viewModel.feedListData.count //+ 1
            
        }
    }
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //        if indexPath.item == viewModel.feedListData.count{
        //            let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadmoreCollectionViewCell", for: indexPath) as! LoadmoreCollectionViewCell
        //            cells.activityIndicator.startAnimating()
        //            return  cells
        //        }
        //        else{
        
        
        if isLoading{
            let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MonetizeNewscardCollectionViewCell", for: indexPath) as! MonetizeNewscardCollectionViewCell
            cells.showDummy()
            return cells
        }
        else{
            let monetize = viewModel.feedListData[indexPath.item].monetize ?? 0
            if monetize == 1{
                let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MonetizeNewscardCollectionViewCell", for: indexPath)
                if let cell = cells as? MonetizeNewscardCollectionViewCell{
                    
                    if isLoading{
                        cell.showDummy()
                    }
                    else{
                        cell.hideDummy()
                        if self.viewModel.feedListData.count > 0 {
                            cell.isviewed = viewModel.feedListData[indexPath.item].isViewed ?? false
                            
                            switch self.viewModel.feedListData[indexPath.item].mediaType {
                            case 1://Text
                                cell.bgViewForText.isHidden = false
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                cell.pdfImgView.isHidden = true
                                cell.txtView.backgroundColor = .clear
                                cell.txtView.textAlignment = .center
                                cell.txtView.font = UIFont.MontserratMedium(.veryLarge)
                                cell.nftImage.isHidden = true
                                cell.audioAnimationBg.isHidden = true
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.txtView.delegate = self
                                // cell.Activityindicator.isHidden = true
                                
                                if self.viewModel.feedListData[indexPath.item].bgColor ?? "" != "" {
                                    if self.viewModel.feedListData[indexPath.item].bgColor ?? "" == "#ffffff" {
                                        Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: "#ffffff", bgColor: "368584", label: cell.txtView, bgView: cell.bgViewForText)
                                    }else{
                                        Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: self.viewModel.feedListData[indexPath.item].textColor ?? "", bgColor: self.viewModel.feedListData[indexPath.item].bgColor ?? "", label: cell.txtView, bgView: cell.bgViewForText)
                                    }
                                }else{
                                    Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: "FFFFFF", bgColor: "358383", label: cell.txtView, bgView: cell.bgViewForText)
                                }
                                
                            case 2://Image
                                
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = false
                                cell.contentBgImgView.isHidden = false
                                cell.pdfImgView.isHidden = true
                                //cell.videoPlayBtn.isHidden = true
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                cell.audioAnimationBg.isHidden = true
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                // cell.Activityindicator.isHidden = true
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                //let cacheImage = ImageCache.default.retrieveImageInDiskCache(forKey: "cache")

                                //let resource = ImageResource(downloadURL:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , cacheKey: "cache")

                                cell.contentsImageView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                                
                                cell.contentBgImgView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                                cell.activityLoader.isHidden = true
        //                        cell.contentsImageView.setImage(
        //                            url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
        //                            placeholder: UIImage(named: "NoImage"))
        //                        cell.contentBgImgView.setImage(
        //                            url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
        //                            placeholder: UIImage(named: "NoImage"))
                                
                            case 3 ://Video
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = false
                                cell.pdfImgView.isHidden = true
                                //cell.audioAnimationBg.isHidden = true
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                //cell.videoBgView.alpha = 0.8
                                cell.cellBackgroundView.backgroundColor = UIColor.black
                                cell.videoBgView.tag = indexPath.item
                                cell.playBtn.tag = indexPath.item
                                cell.audioAnimationBg.isHidden = true
                                cell.mediaType = 3
                                
                               
                                
                                //cell.Activityindicator.isHidden = true
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].thumbNail ?? "")"
                                cell.mediaUrl = self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.playOrPauseVideo(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
                               // cell.playOrPauseVideo(url:"https://sparkdevelop.blob.core.windows.net/sparkdevelop/Videos/623428765c521a76411c01ec/1654259310992/master.m3u8", parent: self, play: false)
                                
                                
                            case 4 ://Audio
                                
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                //cell.contentBgImgView.image = UIImage(named: "Band")
                                //cell.audioAnimationBg.isHidden = false
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                cell.noInternetView.isHidden = true
                                //cell.videoPlayBtn.isHidden = false
                                cell.mediaType = 4
                                
                                cell.playBtn.tag = indexPath.item
                                cell.audioAnimationBg.isHidden = true
                                cell.audioAnimationBg.contentMode = .scaleAspectFit
                                
                                // cell.Activityindicator.isHidden = true
                                
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                cell.mediaUrl = fullMediaUrl//self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.AudioplayOrPauseVideo(url: fullMediaUrl, parent: self, play: false)
                                cell.pdfImgView.isHidden = true
                                
                                
                            case 5 ://Document
                                
                                
                                let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                
                                let imageName = url.components(separatedBy: ".")
                                
                                //                    if imageName.last == "pdf" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "pdf")
                                //                    }else if imageName.last == "ppt" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "ppt")
                                //                    }else if imageName.last == "docs" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "doc")
                                //                    }
                                //                    else if imageName.last == "doc" || imageName.last == "docx" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "doc")
                                //                    }else if imageName.last == "xlsx" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "xls")
                                //                    }
                                //                    else if imageName.last == "xls" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "xls")
                                //                    }
                                //                    else  {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "text")
                                //                    }
                                
                                cell.pdfImgView.image = #imageLiteral(resourceName: "document_image")
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                cell.contentsImageView.backgroundColor = UIColor.clear
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = false
                                //cell.audioAnimationBg.isHidden = true
                                cell.pdfImgView.isHidden = false
                                cell.audioAnimationBg.isHidden = true
                                cell.contentBgImgView.image = #imageLiteral(resourceName: "document_image")
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                
                                //cell.Activityindicator.isHidden = true
                            default:
                                break
                            }
                            
                            if selectedIndexPath == indexPath.item {
                                if trailingBoolForSwipe {
                                    trailingBoolForSwipe = false
                                    cell.animationBgView.isHidden = false
                                    //cell.animationBgView.backgroundColor = UIColor.navigationTitleColor.withAlphaComponent(0.6)
                                    cell.loadAnimatedImage(view: cell.animationBgView)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        cell.animationBgView.isHidden = true
                                    }
                                } else {
                                    cell.animationBgView.isHidden = true
                                }
                            }
                            
                            // content cell values
                            
                            cell.viewCountBtn.tag = indexPath.item
                            cell.clapBtn.tag = indexPath.item
                            cell.clapCountBtn.tag = indexPath.item
                            cell.viewBtn.tag = indexPath.item
                            cell.tagBtn.tag = indexPath.item
                            cell.rightViewBtn.tag = indexPath.item
                            cell.leftViewBtn.tag = indexPath.item
                            cell.contentBgView.tag = indexPath.item
                            cell.profileBtn.tag = indexPath.item
                            cell.titleLabel.tag = indexPath.item
                            cell.collectionDelegate = self
                            
                            
                            let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.feedListData[indexPath.item].createdDate ?? 0)")
                            cell.dateLabel.text = convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
                            
                            if self.viewModel.feedListData[indexPath.item].mediaType != 1{
                                cell.postContentLabel.text = viewModel.feedListData[indexPath.item].postContent
                                if viewModel.feedListData[indexPath.item].postContent?.isEmpty ?? false{
                                    cell.contentLblHeightConstraints.constant = 0
                                    
                                } else {
                                    let heightOfText = (viewModel.feedListData[indexPath.item].postContent)?.height(withConstrainedWidth: self.view.frame.size.width, font: UIFont.MontserratMedium(.large)) ?? CGFloat.init()
                                    print(heightOfText)
                                    cell.contentLblHeightConstraints.constant = 51//heightOfText + 15
                                    
                                }
                            }else{
                                cell.contentLblHeightConstraints.constant = 0
                                cell.postContentLabel.text = ""
                            }

                            
                            
                            

                            cell.tagBtn.setTitle(self.viewModel.feedListData[indexPath.item].tagName, for: .normal)
                            
                            cell.tag = indexPath.item
                            
                            
                            cell.postContentLabel.isHidden = false
                            
                            if viewModel.feedListData[indexPath.item].postContent?.contains("http") ?? false || viewModel.feedListData[indexPath.item].postContent?.contains("https") ?? false || viewModel.feedListData[indexPath.item].postContent?.contains("www") ?? false {
                                cell.postContentLabel.isUserInteractionEnabled = true
                            } else {
                                cell.postContentLabel.isUserInteractionEnabled = false
                            }
                            
                            cell.rightViewClapImgView.image = self.viewModel.feedListData[indexPath.item].isClap == true ? #imageLiteral(resourceName: "clapSwipe") : #imageLiteral(resourceName: "not_clapSwipe")
                            cell.rightViewClapDescLbl.text = viewModel.feedListData[indexPath.item].isClap ?? false ? "This spark has been clapped." : "Clap to start your Loop"
                            
                            cell.leftViewClapImgView.image = #imageLiteral(resourceName: "repost")
                            cell.leftViewClapDescLbl.text = "New Spark same as this category"
                            
                            let viewCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].viewCount ?? 0))
                            let connectionCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].threadCount ?? 0))
                            let clapCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].clapCount ?? 0))
                            
                            cell.viewCountBtn.setTitle(viewModel.feedListData[indexPath.item].viewCount == 0 ? "0" : "\(viewCount)", for: .normal)
                            
                            cell.connectionCountBtn.setTitle(viewModel.feedListData[indexPath.item].threadCount == 0 ? "0" :  "\(connectionCount)", for: .normal)
                            
                            cell.clapCountBtn.setTitle(viewModel.feedListData[indexPath.item].clapCount == 0 ? "0" :  "\(clapCount)", for: .normal)
                            

                            
                            let currencyCode = viewModel.feedListData[indexPath.item].currencySymbol ?? ""
                            cell.currencySymbol.text = currencyCode
                            

                            if viewModel.feedListData[indexPath.item].threadCount ?? 0 >= viewModel.feedListData[indexPath.item].threadLimit ?? 0 {
                                cell.connectionThreadLimitLbl.text = "Exceeded"
                            }else{
                                let connectionThreadLimitCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].threadLimit ?? 0))
                                cell.connectionThreadLimitLbl.text = "\(connectionThreadLimitCount)"
                            }
                            
                            if viewModel.feedListData[indexPath.item].isClap ?? false {
                                // cell.clapBtn.setImage(#imageLiteral(resourceName: "Clapped"), for: .normal)
                                cell.clapImg.image = UIImage.init(named: "Clapped")
                            }else {
                                // cell.clapBtn.setImage(#imageLiteral(resourceName: "clap_gray"), for: .normal)
                                cell.clapImg.image = UIImage.init(named: "clap_gray")
                            }
                            
                           
                            
                            if viewModel.feedListData[indexPath.item].isView ?? false{
                                cell.viewImg.image = UIImage.init(named: "viewed")//setImage(#imageLiteral(resourceName: "viewed"), for: .normal)
                            }else {
                                cell.viewImg.image = UIImage.init(named: "eye_gray")//setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
                            }
                            
                            if viewModel.feedListData[indexPath.item].threadCount ?? 0 > 0 {
                                // cell.connectionBtn.setImage(#imageLiteral(resourceName: "Connection_Fill"), for: .normal)
                                cell.connectionImg.image = UIImage.init(named: "Connection_Fill")
                            }else {
                                //cell.connectionBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
                                cell.connectionImg.image = UIImage.init(named: "connection_gray")
                            }
                            
                            let profilePic = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(viewModel.feedListData[indexPath.item].profilePic ?? "")"
                            
                            if let isAnonymousUser = self.viewModel.feedListData[indexPath.item].allowAnonymous, !isAnonymousUser {
                                cell.iconImageView.setImageFromUrl(urlString: profilePic, imageView: cell.iconImageView, placeHolderImage: self.viewModel.feedListData[indexPath.item].gender == 1 ?  "no_profile_image_male" : self.viewModel.feedListData[indexPath.item].gender == 2 ? "no_profile_image_female" : "others")
                                
                                cell.titleLabel.text = viewModel.feedListData[indexPath.item].profileName
                                
                            }else{
                                cell.iconImageView.image = #imageLiteral(resourceName: "ananomous_user")
                                cell.titleLabel.text = "Anonymous User"
                            }

                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0
                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                               // print("Inside If \(viewModel.feedListData[indexPath.item].monetize ?? 0)")
                                cell.monetizeView.isHidden = false
        //                        cell.removeGestureRecognizer(cell.rightSwipe)
        //                        cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                //print("Inside else \(viewModel.feedListData[indexPath.item].monetize ?? 0)")
                                cell.monetizeView.isHidden = true
        //                        cell.contentView.addGestureRecognizer(cell.rightSwipe)
        //                        cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            
                        
                            
                            
                            

                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                                cell.monetizeView.isHidden = false
                                //cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                cell.monetizeView.isHidden = true
                                //cell.contentView.addGestureRecognizer(cell.rightSwipe)
                                //cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0

                            let postType = self.viewModel.feedListData[indexPath.item].postType
                            
                            switch postType {
                            case 1:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "global")
                            case 2:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "local")
                            case 3:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "social")
                            case 4:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "closed")
                            default:
                                break
                            }
                        }
                        
                        if SessionManager.sharedInstance.isProfileUpdatedOrNot == false {
                            
                            self.nodess = [
                                SpotlightNode(text: "Click here to create a Spark post of things you want to start a conversation.", target: .point(CGPoint(x: view.frame.width/2, y: self.tabBarController?.tabBar.frame.origin.y ?? 0.0 + 25), radius: 30), imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts across the globe", target: .view(globalView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts in your locality", target: .view(localView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts of your connections", target: .view(socialView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts that are directly shared with you", target: .view(closedView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view your loops and bubbles", target: .view(loopBtn), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark users who viewed your Spark posts", target:.view(cell.viewBtn), imageName: ""),
                                SpotlightNode(text: "View here how many Spark users connected with this Spark post", target:.view(cell.connectionBtn), imageName: ""),
                                SpotlightNode(text: "Click here to view Spark users who clapped this Spark post", target: .view(cell.clapBtn), imageName: ""),
                                SpotlightNode(text: "This icon represents the loop limit of the Spark post", target: .view(cell.loopLimitStackView), imageName: ""),
                                SpotlightNode(text: "Swipe right to repost for this Spark post", target: .view(cell.leftViewBtn), roundedCorners: true, imageName: "swipe_right"),
                                SpotlightNode(text: "Swipe left to clap for this Spark post", target: .view(cell.rightViewBtn), roundedCorners: true, imageName: "swipe_left")]
                            
                            
                            Spotlight().startIntro(from: self, withNodes: nodess)
                            SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
                            SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
                            SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                            
                        }
                    }
                    
                   
                    
                    
                    return cell
                }
            }
            else{
                let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCardCollectionCell", for: indexPath)
                if let cell = cells as? NewsCardCollectionCell {
                    
                    if isLoading{
                        cell.showDummy()
                    }
                    else{
                        cell.hideDummy()
                        if self.viewModel.feedListData.count > 0 {
                            cell.isviewed = viewModel.feedListData[indexPath.item].isViewed ?? false
                            
                            switch self.viewModel.feedListData[indexPath.item].mediaType {
                            case 1://Text
                                cell.bgViewForText.isHidden = false
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                cell.pdfImgView.isHidden = true
                                cell.txtView.backgroundColor = .clear
                                cell.txtView.textAlignment = .center
                                cell.txtView.font = UIFont.MontserratMedium(.veryLarge)
                                cell.nftImage.isHidden = true
                                cell.audioAnimationBg.isHidden = true
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.txtView.delegate = self
                                // cell.Activityindicator.isHidden = true
                                
                                if self.viewModel.feedListData[indexPath.item].bgColor ?? "" != "" {
                                    if self.viewModel.feedListData[indexPath.item].bgColor ?? "" == "#ffffff" {
                                        Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: "#ffffff", bgColor: "368584", label: cell.txtView, bgView: cell.bgViewForText)
                                    }else{
                                        Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: self.viewModel.feedListData[indexPath.item].textColor ?? "", bgColor: self.viewModel.feedListData[indexPath.item].bgColor ?? "", label: cell.txtView, bgView: cell.bgViewForText)
                                    }
                                }else{
                                    Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.feedListData[indexPath.item].postContent ?? "", textColor: "FFFFFF", bgColor: "358383", label: cell.txtView, bgView: cell.bgViewForText)
                                }
                                
                            case 2://Image
                                
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = false
                                cell.contentBgImgView.isHidden = false
                                cell.pdfImgView.isHidden = true
                                //cell.videoPlayBtn.isHidden = true
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                cell.audioAnimationBg.isHidden = true
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                // cell.Activityindicator.isHidden = true
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                //let cacheImage = ImageCache.default.retrieveImageInDiskCache(forKey: "cache")

                                //let resource = ImageResource(downloadURL:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , cacheKey: "cache")

                                cell.contentsImageView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                                
                                cell.contentBgImgView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                                cell.activityLoader.isHidden = true
        //                        cell.contentsImageView.setImage(
        //                            url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
        //                            placeholder: UIImage(named: "NoImage"))
        //                        cell.contentBgImgView.setImage(
        //                            url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
        //                            placeholder: UIImage(named: "NoImage"))
                                
                            case 3 ://Video
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = false
                                cell.pdfImgView.isHidden = true
                                //cell.audioAnimationBg.isHidden = true
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                //cell.videoBgView.alpha = 0.8
                                cell.cellBackgroundView.backgroundColor = UIColor.black
                                cell.videoBgView.tag = indexPath.item
                                cell.playBtn.tag = indexPath.item
                                cell.audioAnimationBg.isHidden = true
                                cell.mediaType = 3
                                
                               
                                
                                //cell.Activityindicator.isHidden = true
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].thumbNail ?? "")"
                                cell.mediaUrl = self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.playOrPauseVideo(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
                               // cell.playOrPauseVideo(url:"https://sparkdevelop.blob.core.windows.net/sparkdevelop/Videos/623428765c521a76411c01ec/1654259310992/master.m3u8", parent: self, play: false)
                                
                                
                            case 4 ://Audio
                                
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                //cell.contentBgImgView.image = UIImage(named: "Band")
                                //cell.audioAnimationBg.isHidden = false
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                cell.noInternetView.isHidden = true
                                //cell.videoPlayBtn.isHidden = false
                                cell.mediaType = 4
                                
                                cell.playBtn.tag = indexPath.item
                                cell.audioAnimationBg.isHidden = true
                                cell.audioAnimationBg.contentMode = .scaleAspectFit
                                
                                // cell.Activityindicator.isHidden = true
                                
                                self.fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                cell.mediaUrl = fullMediaUrl//self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.AudioplayOrPauseVideo(url: fullMediaUrl, parent: self, play: false)
                                cell.pdfImgView.isHidden = true
                                
                                
                            case 5 ://Document
                                
                                
                                let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                
                                let imageName = url.components(separatedBy: ".")
                                
                                //                    if imageName.last == "pdf" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "pdf")
                                //                    }else if imageName.last == "ppt" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "ppt")
                                //                    }else if imageName.last == "docs" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "doc")
                                //                    }
                                //                    else if imageName.last == "doc" || imageName.last == "docx" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "doc")
                                //                    }else if imageName.last == "xlsx" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "xls")
                                //                    }
                                //                    else if imageName.last == "xls" {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "xls")
                                //                    }
                                //                    else  {
                                //                        cell.pdfImgView.image = #imageLiteral(resourceName: "text")
                                //                    }
                                
                                cell.pdfImgView.image = #imageLiteral(resourceName: "document_image")
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                cell.contentsImageView.backgroundColor = UIColor.clear
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = true
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = false
                                //cell.audioAnimationBg.isHidden = true
                                cell.pdfImgView.isHidden = false
                                cell.audioAnimationBg.isHidden = true
                                cell.contentBgImgView.image = #imageLiteral(resourceName: "document_image")
                                cell.noInternetView.isHidden = true
                                cell.activityLoader.isHidden = true
                                
                                //cell.Activityindicator.isHidden = true
                            default:
                                break
                            }
                            
                            if selectedIndexPath == indexPath.item {
                                if trailingBoolForSwipe {
                                    trailingBoolForSwipe = false
                                    cell.animationBgView.isHidden = false
                                    //cell.animationBgView.backgroundColor = UIColor.navigationTitleColor.withAlphaComponent(0.6)
                                    cell.loadAnimatedImage(view: cell.animationBgView)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        cell.animationBgView.isHidden = true
                                    }
                                } else {
                                    cell.animationBgView.isHidden = true
                                }
                            }
                            
                            // content cell values
                            
                            cell.viewCountBtn.tag = indexPath.item
                            cell.clapBtn.tag = indexPath.item
                            cell.clapCountBtn.tag = indexPath.item
                            cell.viewBtn.tag = indexPath.item
                            cell.tagBtn.tag = indexPath.item
                            cell.rightViewBtn.tag = indexPath.item
                            cell.leftViewBtn.tag = indexPath.item
                            cell.contentBgView.tag = indexPath.item
                            cell.profileBtn.tag = indexPath.item
                            cell.titleLabel.tag = indexPath.item
                            cell.collectionDelegate = self
                            
                            
                            let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.feedListData[indexPath.item].createdDate ?? 0)")
                            cell.dateLabel.text = convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
                            
                            if self.viewModel.feedListData[indexPath.item].mediaType != 1{
                                cell.postContentLabel.text = viewModel.feedListData[indexPath.item].postContent
                                if viewModel.feedListData[indexPath.item].postContent?.isEmpty ?? false{
                                    cell.contentLblHeightConstraints.constant = 0
                                    
                                } else {
                                    let heightOfText = (viewModel.feedListData[indexPath.item].postContent)?.height(withConstrainedWidth: self.view.frame.size.width, font: UIFont.MontserratMedium(.large)) ?? CGFloat.init()
                                    print(heightOfText)
                                    cell.contentLblHeightConstraints.constant = 51//heightOfText + 15
                                    
                                }
                            }else{
                                cell.contentLblHeightConstraints.constant = 0
                                cell.postContentLabel.text = ""
                            }

                            
                            
                            cell.viewModelCell = viewModel.homeFeedsData(indexpath: indexPath)

                            cell.tagBtn.setTitle(self.viewModel.feedListData[indexPath.item].tagName, for: .normal)
                            
                            cell.tag = indexPath.item
                            
                            
                            cell.postContentLabel.isHidden = false
                            
                            if viewModel.feedListData[indexPath.item].postContent?.contains("http") ?? false || viewModel.feedListData[indexPath.item].postContent?.contains("https") ?? false || viewModel.feedListData[indexPath.item].postContent?.contains("www") ?? false {
                                cell.postContentLabel.isUserInteractionEnabled = true
                            } else {
                                cell.postContentLabel.isUserInteractionEnabled = false
                            }
                            
                            cell.rightViewClapImgView.image = self.viewModel.feedListData[indexPath.item].isClap == true ? #imageLiteral(resourceName: "clapSwipe") : #imageLiteral(resourceName: "not_clapSwipe")
                            cell.rightViewClapDescLbl.text = viewModel.feedListData[indexPath.item].isClap ?? false ? "This spark has been clapped." : "Clap to start your Loop"
                            
                            cell.leftViewClapImgView.image = #imageLiteral(resourceName: "repost")
                            cell.leftViewClapDescLbl.text = "New Spark same as this category"
                            
                            let viewCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].viewCount ?? 0))
                            let connectionCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].threadCount ?? 0))
                            let clapCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].clapCount ?? 0))
                            
                            cell.viewCountBtn.setTitle(viewModel.feedListData[indexPath.item].viewCount == 0 ? "0" : "\(viewCount)", for: .normal)
                            
                            cell.connectionCountBtn.setTitle(viewModel.feedListData[indexPath.item].threadCount == 0 ? "0" :  "\(connectionCount)", for: .normal)
                            
                            cell.clapCountBtn.setTitle(viewModel.feedListData[indexPath.item].clapCount == 0 ? "0" :  "\(clapCount)", for: .normal)
                            

                            
                            let currencyCode = viewModel.feedListData[indexPath.item].currencySymbol ?? ""
                            cell.currencySymbol.text = currencyCode
                            

                            if viewModel.feedListData[indexPath.item].threadCount ?? 0 >= viewModel.feedListData[indexPath.item].threadLimit ?? 0 {
                                cell.connectionThreadLimitLbl.text = "Exceeded"
                            }else{
                                let connectionThreadLimitCount = formatPoints(num: Double(viewModel.feedListData[indexPath.item].threadLimit ?? 0))
                                cell.connectionThreadLimitLbl.text = "\(connectionThreadLimitCount)"
                            }
                            
                            if viewModel.feedListData[indexPath.item].isClap ?? false {
                                // cell.clapBtn.setImage(#imageLiteral(resourceName: "Clapped"), for: .normal)
                                cell.clapImg.image = UIImage.init(named: "Clapped")
                            }else {
                                // cell.clapBtn.setImage(#imageLiteral(resourceName: "clap_gray"), for: .normal)
                                cell.clapImg.image = UIImage.init(named: "clap_gray")
                            }
                            
                           
                            
                            if viewModel.feedListData[indexPath.item].isView ?? false{
                                cell.viewImg.image = UIImage.init(named: "viewed")//setImage(#imageLiteral(resourceName: "viewed"), for: .normal)
                            }else {
                                cell.viewImg.image = UIImage.init(named: "eye_gray")//setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
                            }
                            
                            if viewModel.feedListData[indexPath.item].threadCount ?? 0 > 0 {
                                // cell.connectionBtn.setImage(#imageLiteral(resourceName: "Connection_Fill"), for: .normal)
                                cell.connectionImg.image = UIImage.init(named: "Connection_Fill")
                            }else {
                                //cell.connectionBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
                                cell.connectionImg.image = UIImage.init(named: "connection_gray")
                            }
                            
                            let profilePic = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(viewModel.feedListData[indexPath.item].profilePic ?? "")"
                            
                            if let isAnonymousUser = self.viewModel.feedListData[indexPath.item].allowAnonymous, !isAnonymousUser {
                                cell.iconImageView.setImageFromUrl(urlString: profilePic, imageView: cell.iconImageView, placeHolderImage: self.viewModel.feedListData[indexPath.item].gender == 1 ?  "no_profile_image_male" : self.viewModel.feedListData[indexPath.item].gender == 2 ? "no_profile_image_female" : "others")
                                
                                cell.titleLabel.text = viewModel.feedListData[indexPath.item].profileName
                                
                            }else{
                                cell.iconImageView.image = #imageLiteral(resourceName: "ananomous_user")
                                cell.titleLabel.text = "Anonymous User"
                            }

                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0
                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                               // print("Inside If \(viewModel.feedListData[indexPath.item].monetize ?? 0)")
                                cell.monetizeView.isHidden = false
        //                        cell.removeGestureRecognizer(cell.rightSwipe)
        //                        cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                //print("Inside else \(viewModel.feedListData[indexPath.item].monetize ?? 0)")
                                cell.monetizeView.isHidden = true
        //                        cell.contentView.addGestureRecognizer(cell.rightSwipe)
        //                        cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            
                        
                            
                            
                            

                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                                cell.monetizeView.isHidden = false
                                //cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                cell.monetizeView.isHidden = true
                                //cell.contentView.addGestureRecognizer(cell.rightSwipe)
                                //cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0

                            let postType = self.viewModel.feedListData[indexPath.item].postType
                            
                            switch postType {
                            case 1:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "global")
                            case 2:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "local")
                            case 3:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "social")
                            case 4:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "closed")
                            default:
                                break
                            }
                        }
                        
                        if SessionManager.sharedInstance.isProfileUpdatedOrNot == false {
                            
                            self.nodess = [
                                SpotlightNode(text: "Click here to create a Spark post of things you want to start a conversation.", target: .point(CGPoint(x: view.frame.width/2, y: self.tabBarController?.tabBar.frame.origin.y ?? 0.0 + 25), radius: 30), imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts across the globe", target: .view(globalView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts in your locality", target: .view(localView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts of your connections", target: .view(socialView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark posts that are directly shared with you", target: .view(closedView), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view your loops and bubbles", target: .view(loopBtn), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "Click here to view Spark users who viewed your Spark posts", target:.view(cell.viewBtn), imageName: ""),
                                SpotlightNode(text: "View here how many Spark users connected with this Spark post", target:.view(cell.connectionBtn), imageName: ""),
                                SpotlightNode(text: "Click here to view Spark users who clapped this Spark post", target: .view(cell.clapBtn), imageName: ""),
                                SpotlightNode(text: "This icon represents the loop limit of the Spark post", target: .view(cell.loopLimitStackView), imageName: ""),
                                SpotlightNode(text: "Swipe right to repost for this Spark post", target: .view(cell.leftViewBtn), roundedCorners: true, imageName: "swipe_right"),
                                SpotlightNode(text: "Swipe left to clap for this Spark post", target: .view(cell.rightViewBtn), roundedCorners: true, imageName: "swipe_left")]
                            
                            
                            Spotlight().startIntro(from: self, withNodes: nodess)
                            SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
                            SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
                            SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                            
                        }
                    }
                    
                   
                    
                    
                    return cell
                }
            }
        }
        
        
       
        //        }
        
        
        
        return UICollectionViewCell.init()
    }
    
   
    
    /// Tells the delegate that the specified cell was removed from the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that removed the cell.
    ///   - cell: The cell object that was removed.
    ///   - indexPath: The index path of the data item that the cell represented.
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        print("removed")
        
        if viewModel.feedListData.count > 0{
            let monetize = viewModel.feedListData[indexPath.item].monetize
            if monetize == 1{
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                cell?.test.networkSpeedTestStop()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                cell?.activityLoader.isHidden = true
            }
            else{
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as? NewsCardCollectionCell
                cell?.test.networkSpeedTestStop()
                
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                cell?.activityLoader.isHidden = true
            }
        }
        
    }
    
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        
    
        if isLoading{
            
        }
        else{
            print("displaying each cell \(viewModel.feedListData[indexPath.item])")
            
        }
        
        
        
        let lastElement = viewModel.feedListData.count - 1
        if indexPath.item == lastElement && !loadingData {
            self.noMoreView.isHidden = false
            self.loadingView.isHidden = true
            self.collectionView.addSubview(self.loadingView)
            loadMoreData()
            self.activity.startAnimating()
            
        }
        
        
        
    }
    
    
   
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.viewModel.feedListData.count > 0 {
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
            let isViewed = self.viewModel.feedListData[indexPath.item].isViewed ?? false
            if self.viewModel.feedListData[indexPath.item].mediaType == 2 {
                
                if isViewed == false{
                    self.viewModel.feedListData[indexPath.item].isViewed = true
                    self.callViews(postId: self.viewModel.feedListData[indexPath.item].postId ?? "")
                }
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
                vc.url = fullMediaUrl
                vc.modalPresentationStyle = .fullScreen
                self.isPlayerFullScreenDismissed = false
                navigationController?.present(vc, animated: true, completion: nil)
//                let imageInfo   = GSImageInfo(image: UIImage(), imageMode: .aspectFit, imageHD: URL(string: fullMediaUrl))
//                let imageViewer = GSImageViewerController(imageInfo: imageInfo)
//                imageViewer.backgroundColor = UIColor.black
//                imageViewer.navigationItem.title = self.viewModel.feedListData[indexPath.item].allowAnonymous == true ? "Anonymous User's Spark Image" : "\(self.viewModel.feedListData[indexPath.item].profileName ?? "")'s Spark Image"
//                SessionManager.sharedInstance.isImageFullViewed = true
//                navigationController?.present(imageViewer, animated: true, completion: nil)
            }
            else if self.viewModel.feedListData[indexPath.item].mediaType == 5
            {
                DispatchQueue.main.async {
                    RSLoadingView().showOnKeyWindow()
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    
                    if isViewed == false{
                        self.viewModel.feedListData[indexPath.item].isViewed = true
                        self.callViews(postId: self.viewModel.feedListData[indexPath.item].postId ?? "")
                    }
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
                    docVC.url = fullMediaUrl
                    self.present(docVC, animated: true, completion: nil)
                }
            }
        }
    }
    
  
    /// Call Views with view model to set the the datas from view model
    func callViews(postId:String){
        let params = ["postId":postId] as! [String : Any]
        self.viewModel.viewedApiCallNoLoading(postDict: params)
    }
    
    /// Scroll view did scroll offset will change
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
           // print("Move Up")
            for cell in collectionView.visibleCells {
                let indexPath = collectionView.indexPath(for: cell)
              //  print(indexPath)
                let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? NewsCardCollectionCell
                cell?.activityLoader.isHidden = true
            }
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
           // move down
          //print("Move Down")
            for cell in collectionView.visibleCells {
                let indexPath = collectionView.indexPath(for: cell)
              //  print(indexPath)
                let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? NewsCardCollectionCell
                cell?.activityLoader.isHidden = true
            }
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    /// Asks the delegate whether the specified text view allows the specified type of user interaction with the specified URL in the specified range of text.
    /// - Parameters:
    ///   - textView: The text view containing the text attachment.
    ///   - URL: The URL to be processed.
    ///   - characterRange: The character range containing the URL.
    ///   - interaction: The type of interaction that is occurring (for possible values, see UITextItemInteraction).
    /// - Returns: true if interaction with the URL should be allowed; false if interaction should not be allowed.
    /// - This method is called on only the first interaction with the URL link. For example, this method is called when the user wants their first interaction with a URL to display a list of actions they can take; if the user chooses an open action from the list, this method is not called, because “open” represents the second interaction with the same URL.
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)
            print(indexPath)
            let textview = self.viewModel.feedListData[indexPath?.item ?? 0].postContent ?? ""
            let collcell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? NewsCardCollectionCell
            print("Absolute String is \(URL.absoluteString)")
            print(URL.absoluteURL)
            if (URL.absoluteString == textview){
                self.callViews(postId: self.viewModel.feedListData[indexPath?.item ?? 0].postId ?? "")
            }
            
            else if collcell?.txtView.text.isValidURL == true{
                self.callViews(postId: self.viewModel.feedListData[indexPath?.item ?? 0].postId ?? "")
            }
            
//            else if (URL.absoluteURL ==  self.viewModel.feedListData[indexPath?.item ?? 0].postId ?? ""){
//                self.callViews(postId: self.viewModel.feedListData[indexPath?.item ?? 0].postId ?? "")
//            }
//
//            cell?.activityLoader.isHidden = true
        }
        
        return true
    }
    
    // It will show the count if its greater than '1000' and less than  '1000000' it will show K if its greater than 1000000 it will show M
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


extension HomeViewController : collectionDelegate {
    
    /// On pressing the name label  profile button open the other user profile page
    func profileButtonSelection(sender: Int) {
        if viewModel.feedListData[sender].allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = viewModel.feedListData[sender].userId ?? ""
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    
    func GetPostDetailsObserver(indexPath:Int) {
        
        viewModel.GetPostDetailsModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.remove(indexPath)
                self.showErrorAlert(error: error.localizedDescription)
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
           
        }
        viewModel.GetPostDetailsModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
//                if value.data?.status == 2{
//                    //self.remove(indexPath)
//                    self.remove(indexPath)
//
//                }
//                else{
                
                print(self.playedVideoIndexPath)
                    if self.viewModel.feedListData.count > 0 {
                        
                        

                        let monetize = self.viewModel.feedListData[indexPath].monetize
                            
                            if monetize == 1{
                                let indexPath = IndexPath(row: self.playedVideoIndexPath, section: 0)
                                let cell = self.collectionView?.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                                cell?.test.networkSpeedTestStop()
                                
                                cell?.playerController?.player?.pause()
                                cell?.avplayer?.pause()
                                cell?.activityLoader.isHidden = true
                            }
                            else{
                                let indexPath = IndexPath(row: self.playedVideoIndexPath, section: 0)
                                let cell = self.collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                                cell?.test.networkSpeedTestStop()
                                
                                cell?.playerController?.player?.pause()
                                cell?.avplayer?.pause()
                                cell?.activityLoader.isHidden = true
                            }
                        
                        
                        
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                        detailVC.postId = value.data?.postId ?? ""
                        detailVC.threadId = value.data?.threadId ?? ""
                        SessionManager.sharedInstance.threadId = value.data?.threadId ?? ""
                        
                        
                        detailVC.myPostId = value.data?.postId ?? ""
                        detailVC.myThreadId = value.data?.threadId ?? ""
                        //detailVC.myUserId = SessionManager.sharedInstance.linkFeedProfileUserId
                        
                        
                        detailVC.isFromBubble = false
                        detailVC.isFromHomePage = true
                        detailVC.postType = self.postType
                        detailVC.selectedHomePageIndexPath = indexPath
                        detailVC.delegate = self
                        SessionManager.sharedInstance.selectedIndexTabbar = 0
                        
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
               // }
               
                
               
                
                
            }
        }
        
    }
    
    func contentViewDidSelect(sender: Int) {
        if self.viewModel.feedListData.count > 0 {
            let detailsDict = [
                "postId": self.viewModel.feedListData[sender].postId ?? ""
            ]
            GetPostDetailsObserver(indexPath: sender)
            viewModel.getPostDetailsById(postDict: detailsDict)
        }
        
    }
    
    func homeView(sender: UIButton) {
        if self.viewModel.feedListData.count > 0 {
            if self.viewModel.feedListData[sender.tag].clapCount ?? 0 > 0 {
                let slideVC = OverlayView()
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self
                slideVC.userId = self.viewModel.feedListData[sender.tag].postId ?? ""
                slideVC.type = 2
                slideVC.delegate = self
                debugPrint(slideVC.userId)
                self.present(slideVC, animated: true, completion: nil)
            } else {
                self.showErrorAlert(error: "Still not clapped this post")
                
            }
        }
    }
    
    func homeClap(sender: UIButton) {
        if self.viewModel.feedListData.count > 0 {
            if self.viewModel.feedListData[sender.tag].viewCount ?? 0 > 0 {
                let slideVC = OverlayView()
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self
                slideVC.userId = self.viewModel.feedListData[sender.tag].postId ?? ""
                slideVC.type = 1
                slideVC.delegate = self
                debugPrint(slideVC.userId)
                self.present(slideVC, animated: true, completion: nil)
            } else {
                self.showErrorAlert(error: "Still not viewed this post")
                
            }
        }
    }
    
    func tagButtonTapped(sender: UIButton) {
        if self.viewModel.feedListData.count > 0 {
            easyTipView?.dismiss()
            
            easyTipView = EasyTipView(text: self.viewModel.feedListData[sender.tag].tagName ?? "", preferences: preferences)
            easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
            
            let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: easyTipView?.frame.size.width ?? 0.0, height: easyTipView?.frame.size.height ?? 0.0))
            easyTipView?.addSubview(btn)
            btn.tag = sender.tag
            btn.backgroundColor = UIColor.clear
            btn.addTarget(self, action: #selector(tipViewButtonTapped(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func tipViewButtonTapped(sender:UIButton){
        if self.viewModel.feedListData.count > 0 {
            debugPrint("Tip button Tapped")
            SessionManager.sharedInstance.saveUserTagDetails = ["tagId": self.viewModel.feedListData[sender.tag].tagId ?? "","tagName": self.viewModel.feedListData[sender.tag].tagName ?? "", "postType":postType]
            print(SessionManager.sharedInstance.saveUserTagDetails)
            
            // self.tabBarController?.selectedIndex = 1
            UserDefaults.standard.set(false, forKey: "isFireOnceForTag") //Bool
            NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIcon"), object: ["isFireOnceForTag":true])
        }
    }
    
    
    
    func leftButtonDetailsTapped(sender: UIButton) {
        if self.viewModel.feedListData.count > 0 {
            self.checkThreadLimitObserverForRepost(tag: sender.tag)
            
            self.repostSwippedDataIndexPath = sender.tag
            
            self.viewModel.checkThreadLimitAPICall(postDict: ["threadpostId":self.viewModel.feedListData[sender.tag].postId ?? "","threaduserId":self.viewModel.feedListData[sender.tag].userId ?? ""])
        }
    }
    
    func rightButtonDetailsTapped(sender: UIButton) {
        if self.viewModel.feedListData.count > 0 {
            
            if !(self.viewModel.feedListData[sender.tag].isClap ?? false) {
               
                self.selectedIndexPath = sender.tag
                
                let monetize = self.viewModel.feedListData[sender.tag].monetize
                var isBubble = false
                if monetize == 1{
                    isBubble = true
                }
                else{
                    isBubble = false
                }
                
                let clapDict = ["postId": self.viewModel.feedListData[sender.tag].postId ?? "","isClap": false,"isBubble":isBubble,"postType":self.viewModel.feedListData[sender.tag].postType ?? 0,"threadId":self.viewModel.feedListData[sender.tag].threadId ?? ""] as [String : Any]
                
                self.setupHomeClapViewModel(tag:sender.tag)
                
                self.viewModel.homeClapApiCall(postDict: clapDict as [String : Any])
                
                self.viewModel.feedListData[sender.tag].clapCount = ((self.viewModel.feedListData[sender.tag].clapCount ?? 0) + 1)
                
                self.viewModel.feedListData[sender.tag].isClap = true
                
                self.clappedTagName = self.viewModel.feedListData[sender.tag].tagName ?? ""
                
                self.threadpostId = self.viewModel.feedListData[sender.tag].postId ?? ""
                self.threaduserId = self.viewModel.feedListData[sender.tag].userId ?? ""
                
                
            }
        }
        
    }
    
}

extension String {

    var isValidURL: Bool {
        guard !contains("..") else { return false }
    
        let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
        let urlRegEx = head+"+(.)+"+tail
    
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)

        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))
    }

}
