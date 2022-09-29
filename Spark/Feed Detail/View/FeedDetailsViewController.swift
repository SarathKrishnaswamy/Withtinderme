//
//  FeedDetailsViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 13/08/21.
//

import UIKit
import GrowingTextView
import EasyTipView
import AVKit
import Firebase
import FirebaseDynamicLinks
import SwiftyGif
import RSLoadingView
import UIView_Shimmer
import Toaster
import Razorpay
import IQKeyboardManagerSwift
import Network

protocol backToHomeFromDetailPage:AnyObject {
    func backToHomeFromDetail(indexPath:Int,selectedHomePageLimit:Int,postType:Int, isFromLink:Bool)
}

protocol backFromProfileDelegate {
    func backandReload()
}


protocol backtoSearchDelegate{
    func backSearch()
}



import RAMAnimatedTabBarController



/**
 * Post detail page activity - Core Logic of the application holds by this class
 * Detailed Information of a Spark Post
 * Post can contains Medias like Audio, Video, Image, Document and Text
 * Post Categories are Global, Local, Social and Closed
 * Special Post Categories are Monetize and NFT
 * RazorPay Payment Gateway Implemented for buying Monetize posts
 * Date / Time Function Implemented
 * Image Download from Server for both profile or post
 * Audio/Video Player Implemented
 * View, Connections and Clap counts of a post shown using 1000 - 1K standard
 * Posts can be shared
 * Our own post can be deleted until loop formed.
 * LOOP Concepts:
 * Connected members are listed in the top
 * Post owner can exit from the loop (note: Monetize Post owner cant exit from the loop).
 * Post owner can remove users from this loop.
 * Users can exit from their connected loops.
 * Connected users and post owner can chat each other.
 */


class FeedDetailsViewController: UIViewController,getSelectedMemberList,sendAfterSocketConnect, getPlayerVideoDelegate, backFromOverlay, UITextViewDelegate,backfromFeedDelegate, backtoMultipostDelegate,backtoSearchDelegate,callSocketDelegate {
    func callSocket(postId: String, userId:String, linkPostId:String) {
        SessionManager.sharedInstance.isUserPostId = linkPostId
        setupViewModel()
        setupMemberListSelectionViewModel()
        FeedDetailsViewModel.instance.messageListArray = []
        getSelectedMemberListPostDetails(postId: postId, userId: userId)
        
        //
        //        SocketIOManager.sharedSocketInstance.disconnectSocket()
        ////        SocketIOManager.sharedSocketInstance.delegate = self
        //        SocketIOManager.sharedSocketInstance.ConnectsToSocket()
        //        self.sendAfterSocketConnectMethod()
        //        self.ifNetworkChanged()
        
        
        
        
        //self.tableView?.reloadData()
    }
    
    /// In the delegate we have the back button to call the indexbar of 1 and dismiss the pop up page
    func back() {
        SessionManager.sharedInstance.selectedIndexTabbar = 1
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// In the delegate we have the back from search to call the indexbar of 1 and dismiss the pop up page
    func backSearch() {
        SessionManager.sharedInstance.selectedIndexTabbar = 1
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Set back from the delegate of post id, threadid, userid, member list, message list approved, isfromloop, isfrom notification, isfrom home, isfrom bubble and isfrom thread  or link postid
    ///  - Check according to home page which is done with loopconversation, From bubble page,or from notification page
    func back(postId: String, threadId: String, userId: String, memberList:[MembersList], messageListApproved:Bool, isFromLoopConversation:Bool, isFromNotify:Bool, isFromHome:Bool, isFromBubble:Bool, isThread:Int, linkPostId:String) {
        
        self.isNewLoading = true
        self.membersList = memberList
        self.isPlayerFullScreenDismissed = false
        
        
        if isFromLoopConversation{
            //SessionManager.sharedInstance.isUserPostId = postId
            if isFromNotify{
                SessionManager.sharedInstance.isUserPostId = linkPostId
                isFromNotificationPage = isFromNotify
                setupViewModel()
                FeedDetailsViewModel.instance.messageListArray = []
                getSelectedMemberListPostDetails(postId: postId, userId: userId)
            }
            else{
                isFromLoop = isFromLoopConversation
                // SessionManager.sharedInstance.isUserPostId = ""
                SessionManager.sharedInstance.isUserPostId = linkPostId
                
                self.nextPageKey = 1
                
                //if isClapped == false{
                self.titleLbl.text = "Loop Coversations"
                setupViewModel()
                setupMemberListSelectionViewModel()
                
                self.titleLbl.text = "Loop Coversations"
                FeedDetailsViewModel.instance.messageListArray = []
                getSelectedMemberListPostDetails(postId: postId, userId: userId)
                // }
                
                // if isThread == 2{
                
                //}
                // else{
                
                //}
                //
                
                // setupHomeClapViewModel()
                //FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList = []
                
                // FeedDetailsViewModel.instance.messageListArray = []
                //getSelectedMemberListPostDetails(postId: postId, userId: userId)
                
                //getFeedDetailsAndMemberList(postId: postId, threadId: threadId, linkUserId: userId, isFromBubble: isFromBubble ? true : false)
            }
            
            
        }
        else if isFromHome{
            SessionManager.sharedInstance.isUserPostId = postId
            self.isFromHomePage = isFromHome
            setupViewModel()
            getSelectedMemberListPostDetails(postId: postId, userId: userId)
            //getFeedDetailsAndMemberList(postId: postId, threadId: threadId, linkUserId:userId, isFromBubble: isFromBubble ? true : false)
        }
        
        else if isFromNotify{
            self.isFromNotificationPage = isFromNotify
            setupHomeClapViewModel()
            setupViewModel()
            //getFeedDetailsAndMemberList(postId: postId, threadId: threadId, linkUserId:userId, isFromBubble: isFromBubble ? true : false)
            getSelectedMemberListPostDetails(postId: postId, userId: userId)
        }
        else if isFromBubble{
            //SessionManager.sharedInstance.isUserPostId = postId
            setupHomeClapViewModel()
            setupViewModel()
            SessionManager.sharedInstance.isUserPostId = ""
            getbubbleListByIdObserver()
            getFeedDetailsWhenFromBubble(postId: postId, threadId: self.myThreadId, linkUserId: userId, isFromBubble: isFromBubble ? true : false)
        }
        else{
            SessionManager.sharedInstance.isUserPostId = ""//postId
            self.nextPageKey = 1
            
            //if isClapped == false{
            self.titleLbl.text = "Loop Coversations"
            setupViewModel()
            self.titleLbl.text = "Loop Coversations"
            FeedDetailsViewModel.instance.messageListArray = []
            getSelectedMemberListPostDetails(postId: postId, userId: userId)
        }
        
        
        
    }
    
    
    
    
    /// Dismiss the page after member has been removed with delegate we used this
    func dismissAfterMemberRemove(postId: String, threadId: String, linkUserId: String) {
        
        self.isRemoved = true
        self.isNewLoading = true
        
    }
    
    /// Send after scoket method it will show the online status of the socket
    func sendAfterSocketConnectMethod() {
        
        SocketIOManager.sharedSocketInstance.newsocket.off("online_status")
        
        listenOnlineStatus()
        
        if !SessionManager.sharedInstance.getUserId.isEmpty {
            SocketIOManager.sharedSocketInstance.emitLoggedInUserIDToSocket()
        }
        
    }
    
    /// Selected memeber need to show and empty the array of message list
    /// - Show the setup member list observer with post id, thread id and linked user id to get the member lsit
    func selectedMember(postId: String, threadId: String, linkUserId: String) {
        //
        self.isRemoved = true
        FeedDetailsViewModel.instance.messageListArray = []
        isMemberSelected = true
        setupMemberListSelectionViewModel()
        self.postId = postId
        getSelectedMemberListPostDetails(postId: postId, userId: linkUserId)
        //getFeedDetailsAndMemberList(postId: postId, threadId: threadId, linkUserId: linkUserId, isFromBubble: false)
        //
        //      setupMemberListSelectionViewModel()
        //getSelectedMemberListPostDetails(postId: postId, userId: linkUserId)
        
    }
    
    
    /// Dsimiss overlay with the userId and indexPath have been used to open the ConnectionList other user profile page
    func dismissOverlay(userId: String, IndexPath: Int) {
        print("Back from view")
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        connectionListVC.indexPath = IndexPath
        connectionListVC.backDelegate = self
        
        
        
        connectionListVC.basepostId = postId
        connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
        connectionListVC.basethreadId = bseUserThreadId
        
        connectionListVC.linkPostId = SessionManager.sharedInstance.isUserPostId
        connectionListVC.backDelegate = self
        connectionListVC.isMessageList = self.messageList
        connectionListVC.isLoopConversation = isLoopConversation
        connectionListVC.isFromNotification = isFromNotificationPage
        connectionListVC.isFromHomePage = isFromHomePage
        connectionListVC.isFromBubble = isFromBubble
        connectionListVC.isThread = FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread ?? 0
        //connectionListVC.messageListArray = FeedDetailsViewModel.instance.messageListArray
        connectionListVC.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
    
    ///Delegate is used to call communicatiion between home
    weak var delegate : backToHomeFromDetailPage?
    
    var selectedHomePageIndexPath = 0
    
    var selectedHomePageLimit = 0
    let viewModel = HomeViewModel()
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    var messageList = false
    
    
    @IBOutlet weak var collectionView:UICollectionView?
    // @IBOutlet weak var tableVIewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var growingTxtView:GrowingTextView!
    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputToolbarHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var headerViewLoadMoreBtn: UIButton!
    
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var moreBtnView: UIView!
    @IBOutlet weak var reportPostBtn: UIButton!
    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    var backDelegate : backfromFeedDelegate?
    
    var notificationPostId = ""
    var postId = ""
    var threadId = ""
    var userId = ""
    var tag_Name = ""
    var tagId = ""
    var postype = 1
    var senderUserName = ""
    var clapDataModel = [ClapData]()
    var isFromBubble = false
    var isFromHomePage = false
    var isCallBubbleAPI = false
    
    var selectedMemberPostId = ""
    var selectedMemberAnonymous = false
    var selectedMemberUserId = ""
    var isFromThreadRequestPage = false
    var isFromNotificationPage = false
    
    var isMemberSelected = false
    var isFromConnectionList = false
    
    var isFromProfile = false
    var backfromprofileDelegate :backFromProfileDelegate?
    var backFromOtherProfileDelegate : backFromProfileDelegate?
    
    var cornerRadiuss: CGFloat = 5
    
    var shadowOffsetWidth: Int = 0
    var shadowOffsetHeight: Int = 1
    var shadowColor: UIColor? = UIColor.gray
    var shadowOpacity: Float = 0.3
    
    var customView : customImageView?
    var isRemoved = false
    var isPlayerDismissed = false
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    //paginator
    var loadingData = false
    var isLoadingOldData = false
    var share_url: URL?
    
    let refreshControl = UIRefreshControl()
    var isfromLink = Bool()
    var window: UIWindow?
    var isLoading = false
    var isLoopConversation = false
    
    var myPostId = ""
    var myThreadId = ""
    var myUserId = ""
    var mySelectedMemberPostId = ""
    var mySelectedMemberAnonymous = false
    var isFromLoop = false
    var repostId = ""
    var myBasePostMonetizeId = ""
    var getSearchItemDelegate : getSearchItemDelegate?
    
    var razorpay : RazorpayCheckout? = nil
    var monetizeInterlink = false
    
    var isMoreEnabled = false
    var isClapped = false
    
    var backtoSearchDelegate: backtoSearchDelegate?
    var isFromSettings = false
    
    @IBOutlet weak var threadPopUpBgView: UIView!
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpOkBtn: UIButton!
    @IBOutlet weak var threadPopUpCancelBtn: UIButton!
    
    
    @IBOutlet weak var postDeleteView: UIView!
    @IBOutlet weak var postDeleteLbl: UILabel!
    @IBOutlet weak var pkayBtn: UIButton!
    
    @IBOutlet weak var endCoversationBtn: UIButton!
    
    //More btn
    @IBOutlet weak var MoreView: CardView!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var removeUserBtn: UIButton!
   // @IBOutlet weak var removeUserStackView: UIStackView!
    
    @IBOutlet weak var addmoreContextBtn: UIButton!
    @IBOutlet weak var textViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    var isPlayerFullScreenDismissed = false
    
    var baseUserPostId = ""
    var bseUserThreadId = ""
    var baseUserLinkUserId = ""
    
    var baseNewUserPostId = ""
    var baseNewUserThreadId = ""
    var baseNewUserLinkUserId = ""
    
    
    var isNewLoading = false
    
    var postType = Int()
    
    var linkPostId = ""
    
    var alertController = UIAlertController()
    
    var membersList = [MembersList]()
    
    var postUserId = ""
    var memberCount = Int()
    var isMonetise = 0
    var userName = ""
    var proPic = ""
    var tagName = ""
    var proGender = 0
    var postDate = 0
    var isUserPostId = ""
    var isUserPostIdSaved = false
    
    var newPostId = ""
    
    
    @IBOutlet weak var removeMemberBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PostType:\(postType)")
        
       // self.sendBtn.isEnabled = false
        self.MoreView.isHidden = true
        self.sendBtn.isHidden = false
        threadPopUpBgView.isHidden = true
        threadPopUpBgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
        postDeleteView.isHidden = true
        self.postDeleteLbl.text = userDeletedPost
        postDeleteView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        growingTxtView.delegate = self
        
        
        self.tableView?.register(UINib(nibName: "FeedDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedDetailTableViewCell")
        self.tableView?.register(UINib(nibName: "ClapTableViewCell", bundle: nil), forCellReuseIdentifier: "ClapTableViewCell")
        self.tableView?.register(UINib(nibName: "ChatTextMsgSender", bundle: nil), forCellReuseIdentifier: "ChatTextMsgSender")
        self.tableView?.register(UINib(nibName: "ChatTextMsgReceiver", bundle: nil), forCellReuseIdentifier: "ChatTextMsgReceiver")
        
        self.tableView?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        NotificationCenter.default.addObserver(self,selector: #selector(status_Manager),name: .flagsChanged,object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(pushRedirectionFCM(notification:)), name: Notification.Name("PushRedirectionFCM"), object: nil)
        updateUser_Interface()
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
    }
    
    ///Update the User Interface when there is internet  ot no internet or changed from wifi, mobile data
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            self.internetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            self.alertController.dismiss(animated: true)
            //MaininternetRetry()
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            self.alertController.dismiss(animated: true)
            // MaininternetRetry()
            //view.backgroundColor = .green
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    
    /// Satus manager to update the internet userInterface
    /// - Parameter notification: It receives the notified to update the internet checking
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    /// Satus manager to update the internet userInterface
    /// - Parameter notification: It receives the notified to update the internet checking
    @objc func status_Manager(_ notification: Notification) {
        updateUser_Interface()
    }
    
    
    
    ///Update the User Interface when there is internet  ot no internet or changed from wifi, mobile data
    func updateUser_Interface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            self.MaininternetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            //self.alertController.dismiss(animated: true)
            //MaininternetRetry()
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            //self.alertController.dismiss(animated: true)
            // MaininternetRetry()
            //view.backgroundColor = .green
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    
    
    ///Once we click the push notification it will redirect to open the post detail page.
    @objc func pushRedirectionFCM(notification:NSNotification) {
        
        let postId = "\((notification.object as? [String:Any])?["postId"] as? String ?? "")"
        let threadId = "\((notification.object as? [String:Any])?["threadId"] as? String ?? "")"
        let userId = "\((notification.object as? [String:Any])?["userId"] as? String ?? "")"
        let notifyType = "\((notification.object as? [String:Any])?["typeOfnotify"] as? String ?? "")"
        
        if notifyType == "5" || notifyType == "6" { //Approval and Reveal request
            print("Its notified")
            //SessionManager.sharedInstance.selectedIndexTabbar = 3
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name("SelectNotificationTabBar"), object: nil)
            //
            // NotificationCenter.default.post(name: Notification.Name("DetailToNotificvationTab"), object: ["index":0])
            
            
            self.tabBarController?.tabBar.isHidden = false
        }
        //
        
        
    }
    
    
    /// Retry the internet and if it connected to the internet it will call api with empty the message array list
    ///  - If we have dimiss the player boolean is false it will clear the message array list
    ///  - If it is from notification page call the member list post detail api and show loops
    ///  - If it is from the call bubble api to get the bubble list id observer to set the member list and post details
    ///  - If its requested from thread page save the postid, threadid and selected from bubble list
    ///  - If there is no internet popup will show to retry the internet
    func MaininternetRetry(){
        if Connection.isConnectedToNetwork(){
            print("Connected")
            setupViewModel()
            setupHomeClapViewModel()
            
            
            if !isPlayerFullScreenDismissed {
                FeedDetailsViewModel.instance.messageListArray = []
            }
            
            if isFromNotificationPage{
                getSelectedMemberListPostDetails(postId: postId, userId: SessionManager.sharedInstance.userIdFromSelectedBubbleList)
                //isFromNotificationPage = false
                baseUserPostId = postId
                bseUserThreadId = SessionManager.sharedInstance.threadId
                baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
            }
            else{
                if isCallBubbleAPI {
                    getbubbleListByIdObserver()
                    getFeedDetailsWhenFromBubble(postId: postId, threadId: threadId, linkUserId: userId, isFromBubble: isFromBubble ? true : false)
                }
                else if !isFromThreadRequestPage {
                    //To handle back action
                    baseUserPostId = postId
                    bseUserThreadId = SessionManager.sharedInstance.threadId
                    baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                    
                    //                    baseNewUserPostId = postId
                    //                    baseNewUserThreadId = SessionManager.sharedInstance.threadId
                    //                    baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                    
                    
                    getFeedDetailsAndMemberList(postId: postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: isFromBubble ? true : false)
                }
            }
            
            
        }
        else{
            self.alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
            
            
            
            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                // ... Do something
                
                self.navigationController?.popViewController(animated: true)
                
                
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ... Do something
            }
            
        }
    }
    
    
    /// App will moved background
    @objc func appMovedToBackground() {
        print("App moved to background!")
        
    }
    
    /// App will move foreground and stop the background task
    @objc func appMovedToForeground() {
        print("App moved to Fore In Feed!")
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        cell?.playerController?.player?.pause()
        self.endBackgroundUpdateTask()
        
        
    }
    
    
    /// Set the network path monitor here to connects the socket again
    ///  The boolean 'isNewLoading' is handle the data load first time it will be false and if back from other page it will be true
    ///  - isNewLoading is false then title will be spark details when it is loading on first time.
    ///  - If it is from connection list hide inside the more button icons, Setup the observer.
    ///  - if the playerfull screen dimiss is false, then hide the toolbar and clear the message array list
    ///  - Notification page:
    ///   - call the api 'thread/getThreadByPostId' using postid and selected post userId
    ///   - Set the postid, Threadid and select user id  in the variable
    ///  - Else
    ///   - isCallBubbleAPI
    ///    - call the bubble list id observer details
    ///    - Call the "thread/getbubbleListById" api
    ///   - Else if isFromThreadRequestPage
    ///    - Check it is from fullscreen and set postid, threadid and selected bubblelist
    ///     - Call the setupview model obsrver and call the api "thread/getThreadById"
    ///    - Else
    ///       - Get the member list post detail and call api "thread/getThreadByPostId"
    ///   - Else New loading is true dont call any apis
    ///   - Initialise the socket methid to receive the messages.
    ///   - Call the socket methods of receive base close thread to exit from the loop
    ///   - Call the socket methods of receive member close thread to remove member from the loop
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        
        
        
        SocketIOManager.sharedSocketInstance.delegate = self
        SocketIOManager.sharedSocketInstance.ConnectsToSocket()
        
        let nwPathMonitor = NWPathMonitor()
        nwPathMonitor.pathUpdateHandler = { path in
            
            if path.usesInterfaceType(.wifi) {
                print("Path is Wi-Fi")
                self.ifNetworkChanged()
            } else if path.usesInterfaceType(.cellular) {
                print("Path is Cellular")
                self.ifNetworkChanged()
            } else if path.usesInterfaceType(.wiredEthernet) {
                print("Path is Wired Ethernet")
                self.ifNetworkChanged()
            } else if path.usesInterfaceType(.loopback) {
                print("Path is Loopback")
                self.ifNetworkChanged()
            } else if path.usesInterfaceType(.other) {
                print("Path is other")
                self.ifNetworkChanged()
            }
        }
        
        nwPathMonitor.start(queue: .main)
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.tableView?.isHidden = false
        self.collectionView?.isHidden = false
        
        self.collectionView?.allowsSelection = true
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        
        
        if !isNewLoading{
            titleLbl.text = "Spark Details"
            if isFromConnectionList{
                self.deleteBtn.isHidden = true
                self.removeMemberBtn.isHidden = true
                //self.removeUserStackView.isHidden = true
                self.removeUserBtn.isHidden = true
                self.collectionViewHeightConstraints.constant = 95
                isLoading = true
                
                setupViewModel()
                setupHomeClapViewModel()
                if !isPlayerFullScreenDismissed {
                    self.inputToolbar.isHidden = true
                    self.textViewBottomConstraint.constant = -60
                    FeedDetailsViewModel.instance.messageListArray = []
                }
                
                if isFromNotificationPage{
                    getSelectedMemberListPostDetails(postId: postId, userId: SessionManager.sharedInstance.userIdFromSelectedBubbleList)
                    //isFromNotificationPage = false
                    baseUserPostId = postId
                    bseUserThreadId = SessionManager.sharedInstance.threadId
                    baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                }
                else{
                    if isCallBubbleAPI {
                        getbubbleListByIdObserver()
                        getFeedDetailsWhenFromBubble(postId: postId, threadId: threadId, linkUserId: userId, isFromBubble: isFromBubble ? true : false)
                    }
                    else if !isFromThreadRequestPage {
                        //To handle back action
                        if !(cell?.isFullscreen ?? false){
                            baseUserPostId = postId
                            bseUserThreadId = SessionManager.sharedInstance.threadId
                            baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                            
                            if SessionManager.sharedInstance.getUserId == SessionManager.sharedInstance.userIdFromSelectedBubbleList{
                                self.setupViewModel()
                                getFeedDetailsAndMemberList(postId: postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: isFromBubble ? true : false)
                            }
                            else{
                                getSelectedMemberListPostDetails(postId: postId, userId: SessionManager.sharedInstance.userIdFromSelectedBubbleList)
                            }
                            
                            
                        }
                        
                    }
                }
            }
            else{
                self.deleteBtn.isHidden = true
                //self.removeUserStackView.isHidden = true
                self.removeMemberBtn.isHidden = true
                self.removeUserBtn.isHidden = true
                
                self.collectionViewHeightConstraints.constant = 95
                isLoading = true
                setupViewModel()
                setupHomeClapViewModel()
                if !isPlayerFullScreenDismissed {
                    self.textViewBottomConstraint.constant = -60
                    self.inputToolbar.isHidden = true
                    FeedDetailsViewModel.instance.messageListArray = []
                }
                
                if isFromNotificationPage{
                    getSelectedMemberListPostDetails(postId: postId, userId: SessionManager.sharedInstance.userIdFromSelectedBubbleList)
                    //isFromNotificationPage = false
                    baseUserPostId = postId
                    bseUserThreadId = SessionManager.sharedInstance.threadId
                    baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                }
                else{
                    if isCallBubbleAPI {
                        getbubbleListByIdObserver()
                        getFeedDetailsWhenFromBubble(postId: postId, threadId: threadId, linkUserId: userId, isFromBubble: isFromBubble ? true : false)
                    }
                    else if !isFromThreadRequestPage {
                        //To handle back action
                        if !(cell?.isFullscreen ?? false){
                            baseUserPostId = postId
                            bseUserThreadId = SessionManager.sharedInstance.threadId
                            baseUserLinkUserId = SessionManager.sharedInstance.userIdFromSelectedBubbleList
                            
                            getFeedDetailsAndMemberList(postId: postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: isFromBubble ? true : false)
                        }
                        
                    }
                }
            }
            
            
            
        }
        
        else{
            isNewLoading = true
            
        }
        
        
        
        FeedDetailsViewModel.instance.delegate = self
        
        //        let shadowPath = UIBezierPath(roundedRect: growingTxtView?.bounds ?? CGRect(), cornerRadius: (growingTxtView?.frame.height ?? CGFloat())/2)
        //        growingTxtView?.layer.masksToBounds = false
        //        growingTxtView?.layer.shadowColor = UIColor.white.cgColor
        //        growingTxtView?.layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        //        growingTxtView?.layer.shadowOpacity = shadowOpacity
        //        growingTxtView?.layer.shadowPath = shadowPath.cgPath
        
        growingTxtView?.placeholder = "Write a comment"
        growingTxtView?.font = UIFont.MontserratMedium(.appNormalSize)
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        inputToolbar.addGestureRecognizer(tapGesture)
        
        
        
        
        
        
        FeedDetailsViewModel.instance.receiveMessage()
        
        receiveBaseUserCloseThread()
        receiveMemberCloseThread()
        
        headerBgView.backgroundColor = .clear
        headerView.layer.cornerRadius = 12.0
        headerView.clipsToBounds = true
        
        
        cell?.isFullscreen = false
        
        
        
        cell?.playToggle = 1
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("listenPostLink"), object: nil)
        
    }
    
    
    /// Check whether if the network has been changed resign the keyboard
    /// - Check messagelist size > 1 and check isthread == 2 and threadid id empty
    ///  - Call the receive message socket to listen the messages
    func ifNetworkChanged(){
        
        self.growingTxtView.resignFirstResponder()
        
        if((FeedDetailsViewModel.instance.messageListArray?.count ?? 0) > 1 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && !SessionManager.sharedInstance.threadId.isEmpty) {
            //  SocketIOManager.sharedSocketInstance.disconnectSocket()
            //            SocketIOManager.sharedSocketInstance.delegate = self
            //            SocketIOManager.sharedSocketInstance.ConnectsToSocket()
            //Leave Room
            //            let newDict = ["user_id":SessionManager.sharedInstance.getUserId,"oldroom":SessionManager.sharedInstance.threadId]
            //            SocketIOManager.sharedSocketInstance.leaveFromRoom(param: newDict)
            //            SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":SessionManager.sharedInstance.threadId,"room":SessionManager.sharedInstance.threadId])
            
            
            //            SocketIOManager.sharedSocketInstance.delegate = self
            //            SocketIOManager.sharedSocketInstance.ConnectsToSocket()
            
            FeedDetailsViewModel.instance.receiveMessage()
            
            //            receiveBaseUserCloseThread()
            //            receiveMemberCloseThread()
            //
            //            if SocketIOManager.sharedSocketInstance.isConnected {
            //                SocketIOManager.sharedSocketInstance.closeThreadEmit(param: ["postId":SessionManager.sharedInstance.isUserPostId,"threadId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? "","userId":SessionManager.sharedInstance.getUserId,"status":1])
            //            }
            // listenOnlineStatus()
            
        }
        
    }
    
    
    /// End the background task handler
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    /// When the application is resign active it will call the background task
    @objc func applicationWillResignActive() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    /// When application is did become active it will end the task
    @objc func applicationDidBecomeActive() {
        print("Become Active")
        self.endBackgroundUpdateTask()
        // self.conversationMessageListObserver()
        //self.conversationMessageListAPICall(isVerified: false)
        
    }
    
    /// After receiving the full screen player it will seek to current time and pause the player.
    func fullVideoScreenDismiss(currentSeconds: Double) {
        isPlayerFullScreenDismissed = true
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        let newTime = CMTime(seconds: Double(currentSeconds), preferredTimescale: 600)
        cell?.player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        cell?.player?.pause()
        cell?.playToggle = 1
    }
    
    /// Listen for online status and wait for  3 seconds and run in the background with threadid and emit the thread id
    func listenOnlineStatus() {
        SocketIOManager.sharedSocketInstance.newsocket.on("online_status") { data, ack in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !SessionManager.sharedInstance.threadId.isEmpty {
                    SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":SessionManager.sharedInstance.threadId,"room":SessionManager.sharedInstance.threadId])
                }
            }
        }
    }
    
    /// Keyboard will change the frame when user tapped on mesaage box ithe keyboard will rise
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            // tableviewBottomConstraint.constant = keyboardHeight + 82
            textViewBottomConstraint.constant = keyboardHeight + 7
            
            print("tablevieContraint\(keyboardHeight + 82)")
            print("textviewContraint\(keyboardHeight - 13)")
            view.layoutIfNeeded()
        }
    }
    
    /// tap any where in the view to dimiss the editing of the text field
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    /// - isFromThreadRequestPage is false
    /// - isFromNotificationPage is false
    /// - Set the playercontroller to pause and avplayer to pause
    /// - Set the session user post id to be empty
    override func viewWillDisappear(_ animated: Bool) {
        
        isFromThreadRequestPage = false
        isFromNotificationPage = false
        
        //isFromNotificationPage = false
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        cell?.playerController?.player?.pause()
        cell?.avplayer?.pause()
        SessionManager.sharedInstance.isUserPostId = ""
        //
        //        if !SessionManager.sharedInstance.getUserId.isEmpty {
        //            SocketIOManager.sharedSocketInstance.disconnectSocket()
        //        }
    }
    
    
    
    /// This method is used to clap the post by using the post id by calling the "clapThread" api call
    /// - Parameter postId: Send the post id in the params
    func clapThreadAPICall(postId:String) {
        self.isRemoved = false
        let params = [
            "threadpostId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id,
            "threaduserId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId,
            "linkpostId": postId,
            "linkuserId": SessionManager.sharedInstance.getUserId,
            "tagId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId
        ]
        
        FeedDetailsViewModel.instance.clapThreadApiCall(params: params as [String : Any])
    }
    
    /// Clap thread monetize api call is used to clap the monetize post using post id by calling the "thread/clapMonetizeThread" api call
    /// - Parameter postId: Send the post id in the params
    func clapThreadMonetizeAPICall(postId:String) {
        
        let params = [
            "threadpostId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "",
            "threaduserId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "",
            "linkpostId": postId,
            "linkuserId": SessionManager.sharedInstance.getUserId,
            "tagId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId ?? ""
        ]
        
        FeedDetailsViewModel.instance.clapThreadMonetizeApiCall(params: params as [String : Any])
    }
    
    /// This method is used to get the feed details when from bubble page by calling ""thread/getbubbleListById""
    /// - Parameters:
    ///   - postId: Send the post id in the params
    ///   - threadId: Send the current thread id
    ///   - linkUserId: Send the linked user id
    ///   - isFromBubble: If it is from bubble send the boolean as true
    func getFeedDetailsWhenFromBubble(postId:String,threadId:String,linkUserId:String, isFromBubble:Bool) {
        let params = ["postId":postId,
                      "threadId":threadId,
                      "userId":linkUserId,
                      "isBubble": isFromBubble] as [String : Any]
        FeedDetailsViewModel.instance.getbubbleListById(params: params)
    }
    
    
    
    
    /// This method is used to get the member list details from the feed details
    /// - Parameters:
    ///   - postId: Send the post id to the api
    ///   - threadId: Send the threadid in the params to the api
    ///   - linkUserId: Send the link user id to the params
    ///   - isFromBubble: Set is from bubble false or true
    func getFeedDetailsAndMemberList(postId:String,threadId:String,linkUserId:String, isFromBubble:Bool) {
        let params = ["postId":postId,
                      "threadId":threadId,
                      "userId":linkUserId,
                      "isBubble": isFromBubble] as [String : Any]
        FeedDetailsViewModel.instance.getFeedDetails(params: params)
    }
    
    
    
    /// This method is used to call the selected member list post detail by calling "thread/getThreadByPostId"
    /// - Parameters:
    ///   - postId: Send the post id params here
    ///   - userId: Send the user id params here
    func getSelectedMemberListPostDetails(postId:String,userId:String) {
        let params = ["postId":postId,
                      "userId":userId] as [String : Any]
        
        FeedDetailsViewModel.instance.getMemberListPostDetails(params: params)
    }
    
    
    
    /// Create a short url to share the post to other user to view that post
    /// - Parameter urlString: Pass the url string to any of the device with airdrop or any of the sharing paltform
    func createShortUrl(urlString:String){
        guard let link = URL(string: urlString) else { return }
        let components = DynamicLinkComponents(link: link, domainURIPrefix: "https://sparkme.synctag.com/Post")
        components?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.adhash.spark")
        components?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.adhash.sparkme")
        components?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        components?.socialMetaTagParameters?.title = "Sparkme"
        components?.socialMetaTagParameters?.descriptionText = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postContent
        
        let type = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.mediaType ?? 0
        
        switch type{
        case 1:
            
            break
        case 2:
            print("image")
            var url = ""
            url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.mediaUrl ?? "")"
            let image = url
            components?.socialMetaTagParameters?.imageURL = URL(string:image )
            
            break
        case 3:
            var url = ""
            url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.thumbNail ?? "")"
            let video = url
            print("video")
            components?.socialMetaTagParameters?.imageURL = URL(string:video)
            
            break
        case 4:
            break
        case 5:
            break
        default:
            break
        }
        
        
        
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        components?.options = options
        components?.shorten(completion: { (url, warnings, error) in
            
            //print(url)
            if let error = error {
                print(error.localizedDescription)
            }
            print(url?.absoluteString)
            //let sharedObjects = [objectsToShare]
            //self.share_url = url
            let objectstoshare = [url?.absoluteString]
            
            let activityVC = UIActivityViewController(activityItems: objectstoshare as [Any], applicationActivities: nil)
            activityVC.setValue("Reg: Sparkme Post", forKey: "Subject")
            activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
            
            self.present(activityVC, animated: true, completion: nil)
            
        })
        //  print(self.self.share_url)
        
    }
    
    
    

    /// This method is used to check the observe error with statuscode of error alert
    ///  - Observe the value to reload the data with setup the receive base close thread, receive member close thread
    ///  - Call the bubble boolean value
    ///  - SessionManager.sharedInstance.isUserPostId if this one is empty save the userpost id from the api value.
    ///  - Save the post id, repost id, member count and is monetize, save the tag name, profile pic, gender and post data
    ///  - If session our userid matches userid and memberlist count > 1
    ///  - Hide all the buttons inside more View except remove user button
    ///  - Else hide all the button inside more button view
    ///  - If session our userid matches userid and memberlist count > 1
    ///  - Show the more button
    ///  - Else hide the more button
    ///  - If memberlist count  == 1 and same user id and nft is 0 and thread count is 0 and isfrom profile shows
    ///   - Delete button, Hide more button and hide more view.
    ///  - Else hide the Delete button, Show more button and show more view
    ///   - If member list is  > 1 and userid is equal to same userid and monetize == 0
    ///   - then show remove user views and button
    ///   - Hide all the user views and buttons
    ///  - If member list is  > 1 and userid is equal to same userid and monetize == 1
    ///   - Then show the report views and report view button
    ///    - Else hide the report view buttons and report button
    ///  - If user id is same and monetize == 1 then hide the exit button
    ///   - Else show the exit burron
    /// - If total media > 0 and monetize  == 3 then show the multiple media counts here
    ///  - Show the headings according to the value "Loop conversation " or  "Spark Details"
    //View Model Setup
    func setupViewModel() {
        
        FeedDetailsViewModel.instance.feedDetails.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                //self.postDeleteView.isHidden = false
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
            
        }
        FeedDetailsViewModel.instance.feedDetails.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.tableView?.isHidden = false
                self.collectionView?.isHidden = false
                
                self.receiveBaseUserCloseThread()
                self.receiveMemberCloseThread()
                
                self.isCallBubbleAPI = value.data?.isBubbleRequest ?? false
                
                if SessionManager.sharedInstance.isUserPostId == "" {
                    SessionManager.sharedInstance.isUserPostId = value.data?.isUser?.postId ?? ""
                    
                }
                if self.isUserPostIdSaved == false{
                    self.isUserPostId = value.data?.isUser?.postId ?? ""
                    self.isUserPostIdSaved = true
                }
                
               
                
                self.myBasePostMonetizeId = value.data?.isUser?.postId ?? ""
                
                self.postUserId = value.data?.postDetails?.userId ?? ""
                self.memberCount = value.data?.membersList?.count ?? 0
                self.isMonetise = value.data?.postDetails?.monetize ?? 0
              
                
   
                
                self.repostId = value.data?.postDetails?._id ?? ""
                self.userName = value.data?.postDetails?.profileName ?? ""
                
                self.tagName = value.data?.postDetails?.tagName ?? ""
                self.proPic = value.data?.postDetails?.profilePic ?? ""
                self.proGender = value.data?.postDetails?.gender ?? 0
                self.postDate = value.data?.postDetails?.createdDate ?? 0
                print( value.data?.postDetails?._id ?? "")
                
                if SessionManager.sharedInstance.getUserId == value.data?.postDetails?.userId && value.data?.membersList?.count ?? 0 > 1  {
                    self.removeMemberBtn.isHidden = true
                   // self.removeUserStackView.isHidden = false
                    self.removeUserBtn.isHidden = false
                }else{
                    self.removeMemberBtn.isHidden = true
                    //self.removeUserStackView.isHidden = true
                    self.removeUserBtn.isHidden = true
                }
//                if SessionManager.sharedInstance.getUserId == value.data?.postDetails?.userId && value.data?.membersList?.count ?? 0 > 1{
                self.moreBtnView.isHidden = false
                
                if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId{
                    self.reportPostBtn.isHidden = true
                    self.moreBtnView.isHidden = true
                }else{
                    self.reportPostBtn.isHidden = false
                    self.moreBtnView.isHidden = false
                }
                
//                }
//                else{
//                    self.moreBtnView.isHidden = true
//                }
                if value.data?.membersList?.count == 1 && value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && value.data?.postDetails?.nft == 0 && value.data?.postDetails?.threadCount == 0 && self.isFromProfile{
                    self.deleteBtn.isHidden = false
                    self.moreBtn.isHidden = false
                    self.moreBtnView.isHidden = false
                    
                }
                else{
                    self.deleteBtn.isHidden = true
                    if value.data?.membersList?.count ?? 0 > 1 && value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId {
                        self.moreBtn.isHidden = false
                        self.moreBtnView.isHidden = false
                    }
                }
                
                
                
                if value.data?.membersList?.count ?? 0 > 1 && value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && value.data?.postDetails?.monetize == 0{
                    //self.removeUserStackView.isHidden = false
                    self.removeUserBtn.isHidden = false
                }
                else{
                    //self.removeUserStackView.isHidden = true
                    self.removeUserBtn.isHidden = true
                }
                
                if value.data?.membersList?.count ?? 0 > 1 && value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && value.data?.postDetails?.monetize == 1{
                    self.reportBtn.isHidden = false
                    self.addmoreContextBtn.isHidden = false
                }
                else{
                    self.reportBtn.isHidden = true
                    self.addmoreContextBtn.isHidden = true
                }
                
                if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && value.data?.postDetails?.monetize == 1{
                    self.endCoversationBtn.isHidden = true
                    self.textViewLeading.constant = 15
                }
                else{
                    self.endCoversationBtn.isHidden = false
                    self.textViewLeading.constant = 53
                }
                let indexPath = IndexPath(row: 0, section: 0)
                let cell = self.tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
                
                let totalMedia = value.data?.mediaTotal ?? 0
                if totalMedia > 0 && value.data?.isMonetize == 3 && !self.isRemoved{
                    //if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId{
                    cell?.mosaicView.isHidden = false
                    cell?.mosaicViewCount.setTitle("+\(totalMedia)", for: .normal)
                   
                    
                }
                else if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && totalMedia > 0 && !self.isRemoved{
                    cell?.mosaicView.isHidden = false
                    cell?.mosaicViewCount.setTitle("+\(totalMedia)", for: .normal)
                }
                else{
                    cell?.mosaicView.isHidden = true
                }
                // if value.data?.isThread == 2 && value.data?.postDetails?.threadId != "" {
                
                if (value.data?.isThread == 2 && !(value.data?.isUser?.postId?.isEmpty ?? false) && value.data?.membersList?.count ?? 0 > 1) && value.data?.postDetails?.threadId != "" {
                    self.titleLbl.text = "Loop Conversations"
                    self.isLoopConversation = true
                }
                
                else if value.data?.isTag ?? false && !(value.data?.isClap ?? false) && value.data?.isThread == 0 && value.data?.membersList?.count ?? 0 > 1 {
                    if self.titleLbl.text == "Loop Conversations"{
                        self.titleLbl.text = "Loop Conversations"
                        self.isLoopConversation = true
                    }
                    else if self.titleLbl.text == "Spark Details"{
                        self.titleLbl.text = "Spark Details"
                        self.isLoopConversation = false
                    }
                    else{
                        self.titleLbl.text = "Spark Details"
                        self.isLoopConversation = false
                    }
                    
                }
                
                else if self.titleLbl.text == "Loop Conversations"{
                    self.titleLbl.text = "Loop Conversations"
                    self.isLoopConversation = true
                }
                
               
                else {
                    self.titleLbl.text = "Spark Details"
                    self.isLoopConversation = false
                }
                
                
                
                if value.data?.postDetails?.threadId != "" {
                    
                    SessionManager.sharedInstance.threadId = value.data?.postDetails?.threadId ?? ""
                    //self.tableviewBottomConstraint?.constant = 77
                    //Connect Socket
                    self.textViewBottomConstraint.constant = 0
                    self.inputToolbar.isHidden = false
                    
                    
                    if SocketIOManager.sharedSocketInstance.isConnected {
                        //Emit Thread Room
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":value.data?.postDetails?.threadId ?? "","room":value.data?.postDetails?.threadId ?? ""])
                        }
                    }else{
                        SocketIOManager.sharedSocketInstance.ConnectsToSocket()
                        DispatchQueue.main.async {
                            SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":value.data?.postDetails?.threadId ?? "","room":value.data?.postDetails?.threadId ?? ""])
                        }
                    }
                    
                    self.postId = value.data?.postDetails?._id ?? ""
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        if value.data?.isClap ?? false && value.data?.isTag ?? false && value.data?.isThread == 2 && value.data?.isUser?.postId != ""   {
                            
                            if !self.isPlayerFullScreenDismissed {
                                self.conversationMessageListObserver()
                                self.conversationMessageListAPICall(isVerified: false)
                            }
                        }
                    }
                    
                    
                }else{
                    self.textViewBottomConstraint.constant = -60
                    self.tableviewBottomConstraint?.constant = 0
                    self.inputToolbar.isHidden = true
                }
                
                if value.data?.membersList?.count == 0{
                    self.collectionViewHeightConstraints.constant = 0
                }else {
                    self.collectionViewHeightConstraints.constant = 95
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView?.scrollToBottom(animated: true)
                    self.tableView?.reloadData()
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    
    
    ///This method used to call the observer of tapping the member list to load the api call.
    /// - In the collectionview call the user id select the member detail
    /// - If isUser Post Id is empty save the userpost id
    /// - If  it is same userId and memberlist count > 1
    ///  - Hide more view
    ///  - Else show more view with remove user button
    ///   - If thread Id not empty and isthread == 2 and post id is empty title is "Loop Conversation"
    ///    - If socket is connected emit to room id with name and room
    ///    - After Async method isclap is true and istag is true and isthread == 2 and isPost id not empty and memberlist  > 1 is
    ///     - Call conversation message list and call conversation api call with observer
    ///     - Else hide inputtoolbar
    ///     - If total media > 0 and monetize  == 3 then show the multiple media counts here
    //View Model Setup
    func setupMemberListSelectionViewModel() {
        
        FeedDetailsViewModel.instance.feedDetails.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.feedDetails.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.tableView?.isHidden = false
                self.collectionView?.isHidden = false
                
                //self.messageArray = []
                
                self.isCallBubbleAPI = value.data?.isBubbleRequest ?? false
                
                // SessionManager.sharedInstance.isUserPostId = value.data?.isUser?.postId ?? ""
                if SessionManager.sharedInstance.isUserPostId == "" {
                    SessionManager.sharedInstance.isUserPostId = value.data?.isUser?.postId ?? ""
                }
                
                if SessionManager.sharedInstance.getUserId == value.data?.postDetails?.userId && value.data?.membersList?.count ?? 0 > 1  {
                    if self.isLoading{
                        self.removeMemberBtn.isHidden = true
                        //self.removeUserStackView.isHidden = true
                        self.removeUserBtn.isHidden = true
                        self.headerView.isHidden = true
                    }
                    else{
                        self.removeMemberBtn.isHidden = true
                       // self.removeUserStackView.isHidden = false
                        self.removeUserBtn.isHidden = false
                    }
                    
                }else{
                    self.removeMemberBtn.isHidden = true
                    //self.removeUserStackView.isHidden = true
                    self.removeUserBtn.isHidden = true
                    self.headerView.isHidden = true
                }
                
                if value.data?.postDetails?.threadId != "" {
                    
                    if value.data?.isThread == 2 && !(value.data?.isUser?.postId?.isEmpty ?? false)  {
                        self.titleLbl.text = "Loop Conversations"
                    }
                    
                    else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && SessionManager.sharedInstance.isUserPostId != "" || !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false) && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false){
                        self.titleLbl.text = "Loop Conversations"
                    }
                    
                    
                    else {
                        self.titleLbl.text = "Spark Details"
                    }
                    
                    SessionManager.sharedInstance.threadId = value.data?.postDetails?.threadId ?? ""
                    //self.tableVIewBottomConstraint?.constant = 0
                    //Connect Socket
                    if self.isLoading{
                        self.textViewBottomConstraint.constant = -60
                        self.inputToolbar.isHidden = true
                        self.tableviewBottomConstraint?.constant = 0
                        
                    }
                    else{
                        // self.textViewBottomConstraint.constant = 0
                        self.inputToolbar.isHidden = false
                        //self.tableviewBottomConstraint?.constant = 77
                    }
                    
                    if SocketIOManager.sharedSocketInstance.isConnected {
                        //Emit Thread Room
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":value.data?.postDetails?.threadId ?? "","room":value.data?.postDetails?.threadId ?? ""])
                        }
                    }else{
                        SocketIOManager.sharedSocketInstance.ConnectsToSocket()
                        DispatchQueue.main.async {
                            SocketIOManager.sharedSocketInstance.emitThreadRoomID(param: ["name":value.data?.postDetails?.threadId ?? "","room":value.data?.postDetails?.threadId ?? ""])
                        }
                        
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        if value.data?.isClap ?? false && value.data?.isTag ?? false && value.data?.isThread == 2 && value.data?.isUser?.postId != "" && value.data?.membersList?.count ?? 0 > 1 {
                            
                            self.conversationMessageListObserver()
                            self.conversationMessageListAPICall(isVerified: false)
                            // self.viewModel.receiveMessage()
                        }
                    }
                    
                    
                }else{
                    // self.tableVIewBottomConstraint?.constant = -40
                    self.textViewBottomConstraint.constant = -60
                    self.inputToolbar.isHidden = true
                }
                
                
                let indexPath = IndexPath(row: 0, section: 0)
                let cell = self.tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
                let totalMedia = value.data?.mediaTotal ?? 0
                if totalMedia > 0 && value.data?.isMonetize == 3{
                    //if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId{
                    cell?.mosaicView.isHidden = false
                    cell?.mosaicViewCount.setTitle("+\(totalMedia)", for: .normal)
                    //}
                    //                    else{
                    //                        cell?.mosaicView.isHidden = true
                    //                    }
                    
                }
                else if value.data?.postDetails?.userId == SessionManager.sharedInstance.getUserId && totalMedia > 0{
                    cell?.mosaicView.isHidden = false
                    cell?.mosaicViewCount.setTitle("+\(totalMedia)", for: .normal)
                }
                else{
                    cell?.mosaicView.isHidden = true
                }
                
                
                if value.data?.membersList?.count == 0{
                    self.collectionViewHeightConstraints.constant = 0
                }else {
                    self.collectionViewHeightConstraints.constant = 95
                }
                DispatchQueue.main.async {
                    self.tableView?.scrollToBottom(animated: true)
                    self.tableView?.reloadData()
                    self.collectionView?.reloadData()
                }
                
                
                cell?.playToggle = 1
            }
        }
        
    }
    
    
    
    /// Call the home clap view model  observer here
    ///  - Check the http status code here if 404 post delete view will be hide
    ///  - Show the display as error label
    ///  - else  show the error Aletrt
    ///  - If the value is success in the observer
    ///  - if the data count > 0
    ///  - It will move to the page clapped tag section page, with postid, threadpostid, threaduserid, selected member postid, selected member user id, with the posttype and base anonymous post
    ///  - If is Bubble request is true clapped succesfully
    ///  - else call the api of feed deytails member list
    func setupHomeClapViewModel() {
        
        FeedDetailsViewModel.instance.homeClapModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.postDeleteView.isHidden = false
                self.postDeleteLbl.text = error.localizedDescription
                
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
            
        }
        FeedDetailsViewModel.instance.homeClapModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.clapDataModel = value.data ?? [ClapData]()
                
                if value.data?.count ?? 0 > 0 {
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                    let clappedTagSelectionVC = storyBoard.instantiateViewController(identifier: CLAPPED_TAG_SPARK_SELECTION_STORYBOARD) as! ClappedTagRelatedSparkViewController
                    clappedTagSelectionVC.clapDataModel = self.clapDataModel
                    clappedTagSelectionVC.bubbleUserPostId = self.postId
                    clappedTagSelectionVC.threadpostId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
                    clappedTagSelectionVC.threaduserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                    clappedTagSelectionVC.selectedMemberPostId = self.selectedMemberPostId
                    clappedTagSelectionVC.selectedMemberUserId = self.selectedMemberUserId
                    clappedTagSelectionVC.postType = self.postType
                    clappedTagSelectionVC.delegate = self
                    clappedTagSelectionVC.baseAnonymousPost = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous ?? false
                    self.navigationController?.pushViewController(clappedTagSelectionVC, animated: true)
                } else {
                    
                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.isBubbleRequest ?? false  { //Is came from bubble list
                        
                        self.showErrorAlert(error: "You have clapped successfully!")
                        self.backFromOtherProfileDelegate?.backandReload()
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            
                            
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }else{
                        self.showErrorAlert(error: "You have clapped successfully!")
                        //                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        //                            self.navigationController?.popViewController(animated: true)
                        //                        }
                        self.getFeedDetailsAndMemberList(postId: self.postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: self.isFromBubble ? true : false)
                    }
                    
                    
                    //self.navigationController?.popViewController(animated: true)
                    
                }
                
            }
        }
    }
    
    
    /// Conversation message list api call
    /// - Parameter isVerified: Check whether it is bverified or not by using boolean
    func conversationMessageListAPICall(isVerified:Bool) {
        
        let params = ["threadId":SessionManager.sharedInstance.threadId,
                      "isVerfied":isVerified,
                      "paginator":[
                        "pageSize": limit,
                        "pageNumber":1,
                        "totalPages": 1,
                        "nextPage": nextPageKey,
                        "previousPage": previousPageKey
                      ]] as [String : Any]
        FeedDetailsViewModel.instance.getConversationMessageListNoLoading(params: params)
    }
    
    
    /// Setup the conversation message list  using this observer
    ///  - if message list array size  > 0 and is clap is true and isTag is false and isthread == 2 and threadid not equal to empty and postid not equal to empty  and member list count > 1
    ///  - It will set scroll to bottom
    ///  - If paginator next page > 0 set the loading data false else loading data is true
    //View Model Setup
    func conversationMessageListObserver() {
        //RSLoadingView().showOnKeyWindow()
        FeedDetailsViewModel.instance.conversationMessageList.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.conversationMessageList.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                DispatchQueue.main.async {
                    //self.tableView?.reloadSections(IndexSet(integer: 1), with: .none)
                    //self.tableView?.scrollToBottom(animated: true)
                    self.tableView?.reloadData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    if FeedDetailsViewModel.instance.messageListArray?.count ?? 0 > 0 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0 > 1 {
                        self.messageList = true
                        if !self.isLoadingOldData {
                            self.isLoadingOldData = true
                            self.scrollToBottom()
                            //self.tableView?.scrollToBottom(animated: true)
                        }
                        self.headerView.isHidden = false
                    }
                    
                    self.activityIndicator.isHidden = true
                    self.backBtn.isEnabled = true
                    self.backBtn.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                }
                
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    self.loadingData = false
                }else{
                    self.loadingData = true
                }
                RSLoadingView.hideFromKeyWindow()
            }
        }
        
    }
    
    /// On clicking of previous message button it will load more messages
    @IBAction func loadMoreButtonTapped(sender:UIButton) {
        isLoadingOldData = true
        self.headerView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.backBtn.isEnabled = false
        self.backBtn.isUserInteractionEnabled = false
        self.loadMoreData()
    }
    
    
    /// More button is tapped to show or hide the more view
    @IBAction func moreBtnOnPressed(_ sender: Any) {
        if !isMoreEnabled{
            self.MoreView.isHidden = false
            self.isMoreEnabled = true
        }
        else{
            self.MoreView.isHidden = true
            self.isMoreEnabled = false
        }
        
    }
    
    /// Reaveal identity observer is used to get the idenetity of the anonymous person
    //View Model Setup
    func revealIdentityObserver() {
        
        FeedDetailsViewModel.instance.revealIdentityModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.revealIdentityModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data ?? false == false{ //Reveal request already sent
                    self.showErrorAlert(error: "Loop reveal request already sent")
                }else { //Sent successfully
                    self.showErrorAlert(error: "Loop reveal request sent successfully")
                }
                
            }
        }
        
    }
    
    
    /// Home call method is used to redirect to home page with roor view controller
    func HomeCall() {
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
            let navigationController = UINavigationController(rootViewController: homeVC)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
        
        
    }
    
    
    
    /// Check the tag status observer to  show the alert popup
    /// - If thread status is true and tag status is true Show clap  button
    /// - If threadstatus is false and tag status is true or tagstatus is false then it will be a New spark button
    /// - If thread status is true and tag status is false Show clap button
    ///  - Show all the status in alert view controller as popup
    ///  - When we the button if thread status true and tag status is true  in the alert call the save thread api call and save thread observer
    ///  - If thread status is false and tag status is true or tag status is false check the thread limit using thread limit api call
    ///  - Inside the alert function isTghread == 2 and isTag == true call the clap model api and observer
    ///  - If alert method is clap str then it will be call save api and save thread observer
    //View Model Setup
    func checkTagStatusObserver() {
        
        FeedDetailsViewModel.instance.checkTagStatus.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.postDeleteView.isHidden = false
                
                
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
        }
        FeedDetailsViewModel.instance.checkTagStatus.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                var isNewsSparkStr = ""
                var msgString = ""
                
                if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == true {
                    
                    isNewsSparkStr = "Clap"
                    msgString = "\nIf you wish to create a direct loop use the below button"
                    
                } else if value.data?.threadStatus ?? false == false && value.data?.tagStatus ?? false == true || value.data?.tagStatus ?? false == false {
                    
                    isNewsSparkStr = "New Spark"
                    
                    if value.data?.tagStatus ?? false == true {
                        msgString = "\nIf you wish to create a direct loop use the below buttons"
                    } else {
                        msgString = "\nIf you wish to create a direct loop use the New Spark button"
                        
                    }
                    
                }
                else if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == false{
                    isNewsSparkStr = "Clap"
                    msgString = "\nIf you wish to create a direct loop use the below button"
                    
                }
                
                // Create the alert controller
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
                
                let titleFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.veryLarge)]
                let messageFont = [NSAttributedString.Key.font: UIFont.MontserratRegular(.normal)]
                
                let titleAttrString = NSMutableAttributedString(string: "Loop Request", attributes: titleFont)
                //  let messageAttrString = NSMutableAttributedString(string: "\nIf you wish to create a loop Click the below \(value.data == true ? "Existing Spark" : "Clap")/New Spark button", attributes: messageFont)
                //                let messageAttrString = NSMutableAttributedString(string: value.data?.tagStatus ?? false == true ? "\nIf you wish to create a direct loop use the below buttons" : "\nIf you wish to create a direct loop use the New Spark button", attributes: messageFont)
                
                let messageAttrString = NSMutableAttributedString(string:msgString, attributes: messageFont)
                
                alertController.setValue(titleAttrString, forKey: "attributedTitle")
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                
                
                // Create the actions
                let okAction = UIAlertAction(title: isNewsSparkStr, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("New Post Pressed")
                    
                    if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == true {
                        //self.linkPostId = value.data?.linkpostId ?? ""
                        self.setupSaveThreadObserver()
                        self.saveThreadApiCall(postId: value.data?.linkpostId ?? "")
                        //                        self.clapThreadAPICall(postId: value.data?.linkpostId ?? "")
                        
                        
                    } else if value.data?.threadStatus ?? false == false && value.data?.tagStatus ?? false == true || value.data?.tagStatus ?? false == false {
                        
                        
                        self.checkThreadLimitObserver(monetizeBuyNow: 0, showPayment: false)
                        FeedDetailsViewModel.instance.checkThreadLimitAPICall(postDict: ["threadpostId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "","threaduserId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""])
                    }
                    
                    else if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == false{
                        
                        self.setupSaveThreadObserver()
                        self.saveThreadApiCall(postId: value.data?.linkpostId ?? "")
                        
                    }
                    
                    
                }
                
                var isClapStr = ""
                
                if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == true {
                    
                    isClapStr = "Clap"
                    
                } else if value.data?.threadStatus ?? false == false && value.data?.tagStatus ?? false == true {
                    
                    isClapStr = "Existing Spark"
                }
                else if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == false{
                    
                    isClapStr = "Clap"
                    
                }
                
                let exisitingPostAction = UIAlertAction(title: isClapStr, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    
                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false {
                        self.setupHomeClapViewModel()
                        let clapDict = ["postId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? 0,"isClap": true ,"isBubble":self.isFromBubble,"postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0,"threadId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? 0] as [String : Any]
                        FeedDetailsViewModel.instance.homeClapApiCall(postDict: clapDict as [String : Any])
                        
                    } else {
                        self.setupHomeClapViewModel()
                        let clapDict = ["postId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? 0,"isClap":  true ,"isBubble":self.isFromBubble,"postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0,"threadId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? 0] as [String : Any]
                        FeedDetailsViewModel.instance.homeClapApiCall(postDict: clapDict as [String : Any])
                    }
                }
                
                let clapAction = UIAlertAction(title: isClapStr, style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.setupSaveThreadObserver()
                    self.saveThreadApiCall(postId: value.data?.linkpostId ?? "")
                }
                
                let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                    
                })
                // cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
                
                // Add the actions
                
                
                if value.data?.threadStatus ?? false == false && value.data?.tagStatus ?? false == true {
                    
                    alertController.addAction(exisitingPostAction)
                }
                
                if value.data?.threadStatus ?? false == false && value.data?.tagStatus ?? false == false || value.data?.tagStatus ?? false == true  {
                    alertController.addAction(okAction)
                    
                }
                
                else if value.data?.threadStatus ?? false == true && value.data?.tagStatus ?? false == false{
                    
                    
                    alertController.addAction(clapAction)
                    
                    //alertController.addAction(exisitingPostAction)
                    
                }
                
                //                if value.data == true{
                //                    alertController.addAction(exisitingPostAction)
                //                }
                
                //                if value.data == false && self.viewModel.feedDetails.value?.data?.isClap == true {
                //
                //                }else{
                //                    alertController.addAction(exisitingPostAction)
                //                }
                
                alertController.addAction(cancelButton)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
    }
    
    
    /// Check the thread limit whether the user can join the loop or not
    ///  - If Status 1 thread limit is available and save the tagname, tagId, postid, userid and post type will be save in the session
    ///   - If is monetize == 1 show the payment form
    ///   - if it is monetize  == 2  open create post view controller
    ///   - Else save the tag and set the respost session to true and notify to detail spark method with dimiss to pop view controller
    func checkThreadLimitObserver(monetizeBuyNow : Int, showPayment:Bool) {
        
        FeedDetailsViewModel.instance.checkThreadLimitModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.postDeleteView.isHidden = false
                self.postDeleteLbl.text = error.localizedDescription
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
            
        }
        FeedDetailsViewModel.instance.checkThreadLimitModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                //if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize ?? 0 ==  2{ // if ismonetize 2 go  to create page
                //                    if value.data?.status == 2 {
                //
                //                    }
                if value.data?.status == 1 { //Thread Limit Available
                    SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                    SessionManager.sharedInstance.getTagNameFromFeedDetails = ["tagName":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagName ?? "",
                                                                               "tagID":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId ?? "","postId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "","userId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "","postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? ""]
                    
                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize ?? 0 == 1{ // if ismonetize 2 go  to payment
                        self.showPaymentForm()
                    }
                    else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize ?? 0 == 2{
                        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
                        vc.isFromLoopRepost = false
                        vc.FromLoopMonetize = 2 //isMonetise
                        vc.multiplePost = 0
                        vc.backtoMultiPost = self
                        vc.repostId = self.repostId
                        vc.backSearchDelegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else{
                        //Thread Limit Available
                        SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                        SessionManager.sharedInstance.getTagNameFromFeedDetails = ["tagName":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagName ?? "",
                                                                                   "tagID":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId ?? "","postId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "","userId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "","postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? ""]
                        SessionManager.sharedInstance.isRepost = true
                        NotificationCenter.default.post(name: Notification.Name("FromDetailToCreateSpark"), object: nil)
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: RAMAnimatedTabBarController.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                    
                    
                    
                }
                else{
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                //}
                
                //
                
            }
        }
    }
    
    
    /// Send the thread request using the api call with params
    func saveThreadApiCall(postId:String) {
        
        let params = [
            "threadpostId": postId,
            "threaduserId": SessionManager.sharedInstance.getUserId,
            "linkpostId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ,
            "linkuserId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ,
            "tagId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId
        ]
        
        FeedDetailsViewModel.instance.sendThreadRequest(postDict: params as [String : Any])
        
    }
    
    /// Call the getbubbleListById server
    func getbubbleListByIdObserver() {
        
        FeedDetailsViewModel.instance.checkThreadLimitModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.postDeleteView.isHidden = false
                //self.navigationController?.popViewController(animated: true)
            }
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.checkThreadLimitModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                
            }
        }
        
    }
    
    /// Call the clap thread observer if status == 1then call the view model observer call and get feed detail member list
    func clapThreadObserver() {
        
        FeedDetailsViewModel.instance.clapThreadModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.clapThreadModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            
            
            if value.isOk ?? false {
                
                if value.data?.status == 2 {
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                else if value.data?.status == 1 { //Allow to create repost
                    //FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id
                    self.setupViewModel()
                    self.getFeedDetailsAndMemberList(postId: self.postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: self.isFromBubble ? true : false)
                }
                else{
                    self.setupViewModel()
                    self.getFeedDetailsAndMemberList(postId: self.postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: self.isFromBubble ? true : false)
                }
            }
        }
    }
    
    //View Model Setup
    /// This methoid is used to call the thread request model with the member list api call and observer
    func setupSaveThreadObserver() {
        
        FeedDetailsViewModel.instance.threadRequestModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.threadRequestModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.status == 2 {
                    self.showErrorAlert(error: value.data?.message ?? "")
                } else {
                    SessionManager.sharedInstance.threadId = value.data?.threadId ?? ""
                    self.getFeedDetailsAndMemberList(postId: FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "", threadId:value.data?.threadId ?? "", linkUserId: FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "", isFromBubble:  false)
                }
            }
        }
    }
    
    
    
    /// This method is used to delete the post from the post detail page using post id.
    func deletePostAPICall() {
        
        let params = ["postId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""]
        FeedDetailsViewModel.instance.deletePostApiCall(postDict: params)
    }
    
    
    ///Observer for delete the post and moved back from current page.
    //delete observer setup
    func setupDeletebserver() {
        
        FeedDetailsViewModel.instance.deletePostModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        FeedDetailsViewModel.instance.deletePostModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.data?.status == 1{
                
                //Toast(text: "Spark deleted").show()
                
                //                CustomAlertView.shared.showCustomAlert(title: "Spark me",
                //                                                       message: error,
                //                                                       alertType: .oneButton(),
                //                                                       alertRadius: 30,
                //                                                       btnRadius: 20)
                
                // Create the alert controller
                
                self.showErrorAlert(error: "Spark deleted")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.backfromprofileDelegate?.backandReload()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            else{
                self.showErrorAlert(error: value.data?.message ?? "")
            }
        }
    }
    
    
    
    /// Back button tapped to end all the editing and back to home page will send selected indexPath, Selected Homepage , Posttype and isFrom link
    ///  - Clear the message list array
    ///  - If it is from Post shared it will be move to home page root view
    ///  - If member is not selected set the session selected tab bar to 0
    ///  - If base post id equal to post id delegate to back and reload the with the post id
    ///  - If selectedbar item is 3  using back delegate and notify detail to notification tab
    ///  - Notify search to detail and dismiss the page.
    ///  - Else if member selected and is From notifivcation page
    ///  - If post equal to same base post id then back with backdelegate and dimsiss the page
    ///  - Else call the setup view kodel observer
    @IBAction func backButtonTapped(sender:UIButton) {
        
        self.view.endEditing(true)
        
        self.isRemoved = false
        self.MoreView.isHidden = true
        
        
        
        
        if isFromHomePage {
            getSearchItemDelegate?.getTag(tagId: tagId, tagName: tag_Name, postType: postype)
            delegate?.backToHomeFromDetail(indexPath: selectedHomePageIndexPath, selectedHomePageLimit: selectedHomePageLimit, postType: postType, isFromLink: SessionManager.sharedInstance.isFromLink)
        }
        
        FeedDetailsViewModel.instance.messageListArray = []
        
        if SessionManager.sharedInstance.isPostFromLink{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
            let navigationController = UINavigationController(rootViewController: homeVC)
            // let appdelegate = UIApplication.shared.delegate as! AppDelegate
            //appdelegate.window!.rootViewController = navigationController
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            SessionManager.sharedInstance.isPostFromLink = false
            //self.navigationController?.pushViewController(homeVC, animated: false)
        }
        
        if !isMemberSelected {
            if SessionManager.sharedInstance.selectedIndexTabbar == 0 {
                if baseUserPostId == self.postId{
                    self.backFromOtherProfileDelegate?.backandReload()
                    //self.navigationController?.popViewController(animated: true)
                }
                else{
                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                }
            }
            else if SessionManager.sharedInstance.selectedIndexTabbar == 3 {
                self.backDelegate?.back(postId: "", threadId: "", userId: "", memberList: [MembersList](), messageListApproved:false, isFromLoopConversation: false, isFromNotify: false, isFromHome: false, isFromBubble: false, isThread: 0, linkPostId: "")
                NotificationCenter.default.post(name: Notification.Name("DetailToNotificvationTab"), object: ["index":0])
            }
            else{
                self.backDelegate?.back(postId: "", threadId: "", userId: "",  memberList: [MembersList](), messageListApproved:false, isFromLoopConversation: false, isFromNotify: false, isFromHome: false, isFromBubble: false, isThread: 0, linkPostId: "")
                if isFromSettings{
                    //self.navigationController?.popViewController(animated: true)
                }
                else{
                    NotificationCenter.default.post(name: Notification.Name("searchToDetail"), object: ["index":0])
                }
               
            }
            self.navigationController?.popViewController(animated: true)
        }else if isMemberSelected {
            if isFromNotificationPage{
                
                
                if baseUserPostId == self.postId{
                    self.backDelegate?.back(postId: "", threadId: "", userId: "",  memberList: [MembersList](), messageListApproved:false, isFromLoopConversation: false, isFromNotify: false, isFromHome: false, isFromBubble: false, isThread: 0, linkPostId: "")
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.setupViewModel()
                    getSelectedMemberListPostDetails(postId: baseUserPostId, userId: baseUserLinkUserId)
                    
                }
                
                
            }
            else{
                if baseUserPostId == self.postId{
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.setupViewModel()
                    getFeedDetailsAndMemberList(postId: baseUserPostId, threadId: bseUserThreadId, linkUserId: baseUserLinkUserId, isFromBubble: isFromBubble ? true : false)
                }
            }
            
            isMemberSelected = false
            
            //
            //getSelectedMemberListPostDetails(postId: baseUserPostId, userId: baseUserLinkUserId)
        }
    }
    
    
    /// On tapping remove member button show the list of members in member list detail page.
    @IBAction func removeMemberButtonTapped(_ sender: Any) {
        let memberListVC = self.storyboard?.instantiateViewController(identifier: "MemberListDetailViewController") as! MemberListDetailViewController
        memberListVC.threadId = threadId
        memberListVC.isFromRemoveMember = true
        memberListVC.threadId = SessionManager.sharedInstance.threadId
        memberListVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        memberListVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        memberListVC.delegate = self
        self.navigationController?.present(memberListVC, animated: true, completion: nil)
    }
    
    /// On tappinhg remove user button show the list of member list detail page
    @IBAction func removeUserOnTapped(_ sender: Any) {
        self.MoreView.isHidden = true
        self.isMoreEnabled = false
        let memberListVC = self.storyboard?.instantiateViewController(identifier: "MemberListDetailViewController") as! MemberListDetailViewController
        memberListVC.threadId = threadId
        memberListVC.isFromRemoveMember = true
        memberListVC.threadId = SessionManager.sharedInstance.threadId
        memberListVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        memberListVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        memberListVC.delegate = self
        self.navigationController?.present(memberListVC, animated: true, completion: nil)
    }
    
    
    /// Report user button tapped to report the user from member list page
    @IBAction func reportUserOnPressed(_ sender: Any) {
        self.MoreView.isHidden = true
        self.isMoreEnabled = false
        let memberListVC = self.storyboard?.instantiateViewController(identifier: "MemberListDetailViewController") as! MemberListDetailViewController
        memberListVC.threadId = threadId
        memberListVC.isFromRemoveMember = false
        memberListVC.isReportEnabled = true
        memberListVC.threadId = SessionManager.sharedInstance.threadId
        memberListVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        memberListVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        memberListVC.delegate = self
        self.navigationController?.present(memberListVC, animated: true, completion: nil)
    }
    
    
    @IBAction func reportPostBtnOnPressed(_ sender: Any) {
        self.MoreView.isHidden = true
        self.isMoreEnabled = false
        let vc = self.storyboard?.instantiateViewController(identifier: "ReportViewController") as! ReportViewController
        vc.postId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
        vc.userId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
        vc.displayName = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? ""
        self.navigationController?.present(vc, animated: true)
    }
    
    
    
    /// Delete button is used to delete the post using the delete api call
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to delete this spark?", message: "", preferredStyle: .actionSheet)
        
        
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] (_) in
            
            setupDeletebserver()
            deletePostAPICall()
            
        }))
        
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
        })
        //cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: {
            
        })
        
        
        
        
    }
    
    /// Okay button tapped to close the page and hide the view
    @IBAction func okayBtnOnTapped(_ sender: Any) {
        //self.HomeCall()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}




extension FeedDetailsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - collectionView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isLoading{
            return 1
        }
        else{
            return FeedDetailsViewModel.instance.feedDetails.value?.data?.membersTotal ?? 0 > 0 ? ((FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0) + 1) :  FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0
            
        }
        
        
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    /// Here we are showing the list of members in the member list cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? ThreadMemberListCollectionViewCell
        
        // cell?.viewModelCell = viewModel.setUpThreadMember(indexPath: indexPath.item)
        
        if isLoading{
            cell?.showDummy()
        }
        else{
            cell?.hideDummy()
            if indexPath.item == 0 {
                
                //Set 0th index user id.
                selectedMemberUserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[0].bubbleUserId ?? ""
                
                cell?.bgView.layer.borderWidth = 2.0
                cell?.bgView.layer.borderColor = #colorLiteral(red: 0.2117647059, green: 0.4666666667, blue: 0.4980392157, alpha: 1).cgColor
                cell?.bgView.layer.cornerRadius = 8
                cell?.bgView.clipsToBounds = true
                
                let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].profilePic ?? "")"
                
                if FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].allowAnonymous == true {
                    cell?.imageView.image = #imageLiteral(resourceName: "ananomous_user")
                    cell?.nameLbl.text = "Anonymous User"
                }else{
                    cell?.imageView.setImage(
                        url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].gender == 1 ?  "no_profile_image_male" : FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].gender == 2 ? "no_profile_image_female" : "others"))
                    
                    
                    cell?.nameLbl.text = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].displayName ?? ""
                }
                
                if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId != SessionManager.sharedInstance.getUserId {
                    cell?.grayView.isHidden = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].isClap == false ? false : true
                    cell?.grayView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                }
                
            }else if indexPath.item == 4 {
                
                cell?.imageView.image = #imageLiteral(resourceName: "dummyProfileImage")
                cell?.nameLbl.text = "+\(FeedDetailsViewModel.instance.feedDetails.value?.data?.membersTotal ?? 0) more"
                
            }
            else  {
                
                let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].profilePic ?? "")"
                
                cell?.grayView.isHidden = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].isClap == false ? false : true
                cell?.grayView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                
                cell?.bgView.layer.borderWidth = 0.0
                cell?.bgView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
                cell?.bgView.layer.cornerRadius = 8
                cell?.bgView.clipsToBounds = true
                
                if FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].allowAnonymous == true {
                    cell?.imageView.image = #imageLiteral(resourceName: "ananomous_user")
                    cell?.nameLbl.text = "Anonymous User"
                }else{
                    cell?.imageView.setImage(
                        url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].gender == 1 ?  "no_profile_image_male" : FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].gender == 2 ? "no_profile_image_female" : "others"))
                    
                    
                    cell?.nameLbl.text = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].displayName ?? ""
                }
                
            }
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 4 - 10 , height: 85)
    }
    
    
    
    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose line spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive lines in a section.
    ///  - If you do not implement this method, the flow layout uses the value in its minimumLineSpacing property to set the space between lines instead. Your implementation of this method can return a fixed value or return different spacing values for each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    
    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    
    
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsets(top: 5,left: 0,bottom: 5,right: 0)
    }
    
    //    fileprivate func revealIdentityAPICall(_ indexPath: IndexPath) {
    //        let param = ["threadId":viewModel.feedDetails.value?.data?.membersList?[indexPath.item].threadId ?? "",
    //                     "userId":viewModel.feedDetails.value?.data?.membersList?[indexPath.item].bubbleUserId ?? "",
    //                     "postId":viewModel.feedDetails.value?.data?.membersList?[indexPath.item].postId ?? "",
    //                     "timestamp":Int(NSDate().timeIntervalSince1970)] as [String : Any]
    //
    //        viewModel.revealIdentityAPICall(params: param)
    //    }
    //
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    ///  - If index = 0 pressed noting we will be return
    ///  - If index = 4 it will open the member list detail page
    ///  - Else it will open the coressig post of the member
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if indexPath.item == 0 {
            return
        }
        
        self.nextPageKey = 1
        
        if indexPath.item == 4 {
            self.MoreView.isHidden = true
            self.isMoreEnabled = false
            let memberListVC = self.storyboard?.instantiateViewController(identifier: "MemberListDetailViewController") as! MemberListDetailViewController
            memberListVC.threadId = threadId
            memberListVC.isFromRemoveMember = false
            memberListVC.threadId = SessionManager.sharedInstance.threadId
            memberListVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            memberListVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            memberListVC.delegate = self
            self.navigationController?.present(memberListVC, animated: true, completion: nil)
        } else {
            
            self.MoreView.isHidden = true
            self.isMoreEnabled = false
            //Leave Room
            //let newDict = ["user_id":SessionManager.sharedInstance.getUserId,"oldroom":SessionManager.sharedInstance.threadId]
            // SocketIOManager.sharedSocketInstance.leaveFromRoom(param: newDict)
            
            FeedDetailsViewModel.instance.messageListArray = []
            
            //setupMemberListSelectionViewModel()
            setupViewModel()
            
            // viewModel.receiveMessage()
            
            isMemberSelected = true
            isRemoved = false
            
            // if !isNewLoading{
            selectedMemberAnonymous = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].allowAnonymous ?? false
            selectedMemberUserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].bubbleUserId ?? ""
            
            self.postId = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].postId ?? ""
            self.myPostId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
            
            getSelectedMemberListPostDetails(postId: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].postId ?? "", userId: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].bubbleUserId ?? "")
            
            
            //}
            //            else{
            //                if isFromConnectionList{
            //                    selectedMemberAnonymous = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].allowAnonymous ?? false
            //                    selectedMemberUserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].bubbleUserId ?? ""
            //
            //                    self.postId = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].postId ?? ""
            //                    //getSelectedMemberListPostDetails(postId: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].postId ?? "", userId: FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?[indexPath.item].bubbleUserId ?? "")
            //                }
            //
            //                else{
            //                    //setupMemberListSelectionViewModel()
            //                    selectedMemberAnonymous = self.membersList[indexPath.item].allowAnonymous ?? false
            //                    selectedMemberUserId =  self.membersList[indexPath.item].bubbleUserId ?? ""
            //                    self.postId = self.membersList[indexPath.item].postId ?? ""
            //                    //getSelectedMemberListPostDetails(postId: self.membersList[indexPath.item].postId ?? "", userId: self.membersList[indexPath.item].bubbleUserId ?? "")
            //                    self.isNewLoading = false
            //                }
            //
            //            }
            
        }
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        cell?.playerController?.player?.pause()
    }
}


extension FeedDetailsViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else if section == 1 {
            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0 > 1 {
                if FeedDetailsViewModel.instance.messageListArray?.count ?? 0 == 0  {
                    if isLoading{
                        return 0
                    }
                    else{
                        return 1
                    }
                }else {
                    return FeedDetailsViewModel.instance.messageListArray?.count ?? 0
                }
            }else{
                return 1
            }
        }
        return 0
        
        //   return section == 0 ? 1 : FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" ? FeedDetailsViewModel.instance.messageListArray?.count ?? 0 == 0 ? 1 :  FeedDetailsViewModel.instance.messageListArray?.count ?? 0  : 1
    }
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    /// - If indexpath section  == 0 then call Show the post here with image, text, video, audio or document and send the view model cell api setup
    /// - If indexpath.section == 1
    ///  - Check isclap true and isTag true and isThread 2 and threadid not equal to empty and postid not equal to empty and member list > 1 then input tool bar will be hide else input toolbar will be shown
    ///  - If message list array count is 0 show no data tableview cell
    ///  - If message from same userid it will show current sender  chat text message cell
    ///  - Else it will show chat receive message cell
    /// - Else
    ///  - Show clap table view cell
    ///  - 1)  If Threadcount  == thread limit and is thread not 1 then show the member limit exceeded
    ///  - 2 ) If isclap true and isTag true and thread 2 and thread id empty or not empty and own user id "You can't send loop request to your own spark"
    ///  - 3)  If iclap true and isTag true and thread 2 and thread id empty  It will be "You're no longer a member in this loop"
    ///  - 4) If  isclap true and isTag true and thread 2 and isUserPostId not equal to empty
    ///   -  i) If it monetise 1 show buy now  button if monetise 2 show continue button else show "clap" button
    ///  - 5) If isclap true and isTag true and thread 2 and isUserpostid is empty
    ///    - i)  If it monetise 1 show buy now  button if monetise 2 show continue button else show "Connect" button
    ///  - 6) If isclap true and isTag true and thread 0
    ///    - i) If it monetise 1 show buy now  button if monetise 2 show continue button else show "Connect" button
    ///  - 7)  If isclap true and isTag true and thread 0 show "Loop request has been sent. Waiting for the users approval"
    ///  - 8) If isclap false and isTag false
    ///    - i)  If it monetise 1 show buy now  button if monetise 2 show continue button else show "Connect" button
    ///  - 9)  If isclap true and isTag false
    ///    - i) If it monetise 1 show buy now  button if monetise 2 show continue button else show "Connect" button
    ///  - 10)  If isclap false and isTag true
    ///    -  i) If it monetise 1 show buy now  button if monetise 2 show continue button else show "Connect" button
    ///    Else
    ///    - i) If is thread 2 and isuserpostid not empty threadid not empty, isuserpost id not empty and member list  > 1
    ///    - ii) Show Clap Button
    ///     - Else if thread id == 0
    ///     - i) show connect button
    ///     - Else
    ///     - i) Show connect button
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedDetailTableViewCell", for: indexPath) as? FeedDetailTableViewCell
            else { preconditionFailure("Failed to load collection view cell") }
            
            if isLoading{
                cell.showDummy()
            }
            else{
                cell.hideDummy()
                cell.videoFullScreenDelegate = self
                cell.backtoFeedDelegate = self
                cell.viewModelCell = FeedDetailsViewModel.instance.setUpPostDetails(indexPath: indexPath)
                if isFromNotificationPage{
                    
                    cell.myPostId = postId
                    cell.myUserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                    cell.myThreadId = bseUserThreadId
                    
                    //                    connectionListVC.basepostId = postId
                    //                    connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                    //                    connectionListVC.basethreadId = bseUserThreadId
                    
                }
                else{
                    cell.myPostId = postId
                    cell.myUserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                    cell.myThreadId = bseUserThreadId
                    
                    //                    cell.myPostId = self.myPostId
                    //                    cell.myUserId = self.myUserId
                    //                    cell.myThreadId = self.myThreadId
                }
                cell.linkPostId = SessionManager.sharedInstance.isUserPostId
                cell.isThreadId = FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread ?? 0
                cell.isFromLoop = self.isLoopConversation
                cell.isFromNotification = isFromNotificationPage
                cell.isFromBubble = isFromBubble
                //let isNft = FeedDetailsViewModel.instance
                cell.clapBtn.tag = indexPath.row
                cell.connectionImgBtn.tag = indexPath.row
                cell.viewImgBtn.tag = indexPath.row
                cell.profileBtn.tag = indexPath.row
                cell.feedTableDelegate = self
                cell.morefeedTableDelegate = self
                cell.socketDelagete = self
                cell.shareBtn.tag = indexPath.item
                cell.isMonetize = FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize ?? 0
                cell.totalMedia = FeedDetailsViewModel.instance.feedDetails.value?.data?.mediaTotal ?? 0
                let PostType = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0
                if PostType == 3{
                    cell.shareBtn.isHidden = true
                }
                else if PostType == 4{
                    cell.shareBtn.isHidden = true
                }
                else{
                    cell.shareBtn.isHidden = false
                }
                let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareLink(_:)))
                cell.shareBtn.addGestureRecognizer(shareTap)
                cell.shareBtn.isUserInteractionEnabled = true
            }
            
            //cell.shareBtn.tag = indexPath.item
            
            return cell
        }
        
        else if indexPath.section == 1 {
            
            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0 > 1 {
                
                if isLoading{
                    self.textViewBottomConstraint.constant = -60
                    self.inputToolbar.isHidden = true
                    
                }
                else{
                    // self.textViewBottomConstraint.constant = 0
                    self.inputToolbar.isHidden = false
                    //self.tableVIewBottomConstraint?.constant = 0
                }
                
                
                
                if FeedDetailsViewModel.instance.messageListArray?.count == 0  {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NoDataTableViewCell
                    else { preconditionFailure("Failed to load collection view cell") }
                    
                    cell.imgView.image = #imageLiteral(resourceName: "noChatImage")
                    cell.noDataLbl.text = "There is no loop history"
                    
                    return cell
                }
                
                
                if FeedDetailsViewModel.instance.messageListArray?[indexPath.row].from == SessionManager.sharedInstance.getUserId {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTextMsgSender", for: indexPath) as? ChatTextMsgSender
                    else { preconditionFailure("Failed to load collection view cell") }
                    
                    let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].profilePic ?? "")"
                    
                    if FeedDetailsViewModel.instance.messageListArray?[indexPath.row].allowAnonymous ?? false {
                        cell.profileImgView?.image = #imageLiteral(resourceName: "ananomous_user")
                    }else {
                        cell.profileImgView?.setImage(
                            url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
                            placeholder: #imageLiteral(resourceName: FeedDetailsViewModel.instance.messageListArray?[indexPath.row].gender == 1 ?  "no_profile_image_male" : FeedDetailsViewModel.instance.messageListArray?[indexPath.row].gender == 2 ? "no_profile_image_female" : "others"))
                        
                        
                    }
                    
                    // cell.nameLbl?.text = viewModel.messageListArray?[indexPath.row].displayName ?? ""
                    cell.messageLbl?.text = FeedDetailsViewModel.instance.messageListArray?[indexPath.row].message ?? ""
                    //cell.txtViewHeightConstraints?.constant = cell.messageLbl?.contentSize.height ?? CGFloat()
                    
                    let timeStampStr = "\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].timestamp ?? 0)"
                    let dateWithTime = Helper.sharedInstance.convertTimeStampToDOBWithTimeReturnDate(timeStamp: timeStampStr).timeAgoForSenderReceiverMeaages()//.timeAgoForSenderReceiverMeaages()
                    
                    cell.dateLabel?.text = dateWithTime
                    //                    cell.dateLabel?.text = Helper.sharedInstance.convertTimeStampToHours(timeStamp: "\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].timestamp ?? 0)")
                    
                    return cell
                }
                else {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTextMsgReceiver", for: indexPath) as? ChatTextMsgReceiver
                    else { preconditionFailure("Failed to load collection view cell") }
                    
                    let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].profilePic ?? "")"
                    
                    if FeedDetailsViewModel.instance.messageListArray?[indexPath.row].allowAnonymous ?? false {
                        cell.profileImgView?.image = #imageLiteral(resourceName: "ananomous_user")
                        cell.nameLbl?.text = "Anonymous User"
                    }else {
                        cell.profileImgView?.setImage(
                            url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
                            placeholder: #imageLiteral(resourceName: FeedDetailsViewModel.instance.messageListArray?[indexPath.row].gender == 1 ?  "no_profile_image_male" : FeedDetailsViewModel.instance.messageListArray?[indexPath.row].gender == 2 ? "no_profile_image_female" : "others"))
                        
                        
                        cell.nameLbl?.text = FeedDetailsViewModel.instance.messageListArray?[indexPath.row].displayName ?? ""
                    }
                    
                    cell.anonymousDelegate = self
                    cell.anonymousBtn?.tag = indexPath.row
                    cell.messageLbl?.text = FeedDetailsViewModel.instance.messageListArray?[indexPath.row].message ?? ""
                    let timeStampStr = "\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].timestamp ?? 0)"
                    let dateWithTime = Helper.sharedInstance.convertTimeStampToDOBWithTimeReturnDate(timeStamp: timeStampStr).timeAgoForSenderReceiverMeaages()//.timeAgoForSenderReceiverMeaages()
                    
                    cell.dateLabel?.text = dateWithTime
                    //                    cell.dateLabel?.text = Helper.sharedInstance.convertTimeStampToHours(timeStamp: "\(FeedDetailsViewModel.instance.messageListArray?[indexPath.row].timestamp ?? 0)")
                    
                    
                    return cell
                }
            }
            else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClapTableViewCell", for: indexPath) as? ClapTableViewCell
                else { preconditionFailure("Failed to load collection view cell") }
                cell.clapDelegate = self
                cell.clapBtn?.tag = indexPath.row
                cell.clapImgView?.isHidden = true
                cell.buyNowbtn.tag = indexPath.row
                
                if isLoading{
                    cell.showDummy()
                }
                else{
                    cell.hideDummy()
                    self.textViewBottomConstraint.constant = -60
                    self.inputToolbar.isHidden = true
                    self.tableviewBottomConstraint.constant = 0
                    //self.tableVIewBottomConstraint?.constant = -40
                    
                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadCount ?? 0 == FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadLimit ?? 0 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread != 1 {
                        cell.clapBtn?.isHidden = true
                        cell.createSparkBtn?.isHidden = true
                        cell.cthreadRequestBtn?.isHidden = true
                        cell.clapImgView?.isHidden = true
                        cell.buyNowbtn.isHidden = true
                        cell.priceLbl.isHidden = true
                        cell.descpLbl?.text = "Members Limit Exceeded"
                    }
                    else
                    {
                        
                        
                        // if from profile
                        if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && (FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId == "" || FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "") && SessionManager.sharedInstance.getUserId == FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId
                        {
                            cell.clapBtn?.isHidden = true
                            cell.createSparkBtn?.isHidden = true
                            cell.cthreadRequestBtn?.isHidden = true
                            cell.clapImgView?.isHidden = true
                            cell.buyNowbtn.isHidden = true
                            cell.priceLbl.isHidden = true
                            cell.descpLbl?.text = "You can't send loop request to your own spark"
                            //                         if isFromNotificationPage {
                            //                             cell.descpLbl?.text = ""
                            //                         }else{
                            //                             cell.descpLbl?.text = "You can't send loop request to your own spark"
                            //                         }
                            
                        }
                        else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId == "" {
                            cell.clapBtn?.isHidden = true
                            cell.createSparkBtn?.isHidden = true
                            cell.cthreadRequestBtn?.isHidden = true
                            cell.clapImgView?.isHidden = true
                            cell.buyNowbtn.isHidden = true
                            cell.priceLbl.isHidden = true
                            cell.descpLbl?.text = "You're no longer a member in this loop"
                            
                            //                        if isFromNotificationPage {
                            //                            cell.descpLbl?.text = ""
                            //                        }else{
                            //                            cell.descpLbl?.text = "You're no longer a member in this loop"
                            //                        }
                        }
                        //                    else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && (FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId == "" || FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "") && SessionManager.sharedInstance.getUserId == FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId  {
                        //                        cell.clapBtn?.isHidden = true
                        //                        cell.createSparkBtn?.isHidden = true
                        //                        cell.cthreadRequestBtn?.isHidden = true
                        //                        cell.clapImgView?.isHidden = true
                        //                        cell.descpLbl?.text = "You can't send loop request to your own spark"
                        //                    }
                        
                        //                    else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId == "" {
                        //
                        //                        cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Clap for this Spark"
                        //                        cell.clapBtn?.isHidden = false
                        //                        cell.createSparkBtn?.isHidden = true
                        //                        cell.cthreadRequestBtn?.isHidden = true
                        //                        cell.clapImgView?.isHidden = false
                        //                    }
                        
                        else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && SessionManager.sharedInstance.isUserPostId != "" {
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Clap for this Spark"
                                cell.clapBtn?.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.isHidden = true
                                cell.priceLbl.isHidden = true
                                self.monetizeInterlink = true
                                
                            }
                        }
                        
                        else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && SessionManager.sharedInstance.isUserPostId == "" {
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                                cell.clapBtn?.isHidden = true
                                cell.createSparkBtn?.isHidden = false
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.isHidden = true
                                cell.priceLbl.isHidden = true
                                self.monetizeInterlink = false
                            }
                        }
                        
                        
                        
                        
                        else if (FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false)  && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 0) {
                            //Show Connect here
                            
                            
                            //Do razor payment here
                            
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = true
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = false
                                cell.clapImgView?.isHidden = false
                                cell.descpLbl?.text = "If you wish to create loop request Click below connect button"
                                self.monetizeInterlink = false
                            }
                            
                            
                            
                            
                        } else if (FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false)  && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 1) {
                            
                            cell.clapBtn?.isHidden = true
                            cell.createSparkBtn?.isHidden = true
                            cell.cthreadRequestBtn?.isHidden = true
                            cell.clapImgView?.isHidden = false
                            cell.descpLbl?.text = "Loop request has been sent. Waiting for the users approval"
                            
                        }
                        
                        else if !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false)  && !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) {
                            
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                                cell.clapBtn?.isHidden = true
                                cell.createSparkBtn?.isHidden = false
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                self.inputToolbar.isHidden = true
                                cell.buyNowbtn.isHidden = true
                                cell.priceLbl.isHidden = true
                                self.monetizeInterlink = false
                                
                            }
                            // self.tableVIewBottomConstraint?.constant = -40
                            
                        } else if (FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false)  && !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) {
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                cell.descpLbl?.text = "You have clapped this spark. If you wish to create loop request kindly create spark using above sparkTag."
                                cell.clapBtn?.isHidden = true
                                cell.createSparkBtn?.isHidden = false
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.isHidden = true
                                cell.priceLbl.isHidden = true
                                self.monetizeInterlink = false
                                
                            }
                        }
                        else if !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false) && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) {
                            
                            
                            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = false
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Join now", for: .normal)
                                cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                                cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                                
                                self.monetizeInterlink = false
                            }
                            else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                                cell.clapBtn?.isHidden = true
                                cell.buyNowbtn.isHidden = false
                                cell.priceLbl.isHidden = true
                                cell.createSparkBtn?.isHidden = true
                                cell.cthreadRequestBtn?.isHidden = true
                                cell.clapImgView?.isHidden = false
                                cell.buyNowbtn.setTitle("Continue", for: .normal)
                                cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                                self.monetizeInterlink = false
                            }
                            else{
                                
                                if self.isUserPostId != "" || isCallBubbleAPI {
                                    cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Clap for this Spark"
                                    
                                    cell.clapBtn?.isHidden = false
                                    cell.createSparkBtn?.isHidden = true
                                    cell.cthreadRequestBtn?.isHidden = true
                                    cell.clapImgView?.isHidden = false
                                    cell.buyNowbtn.isHidden = true
                                    cell.priceLbl.isHidden = true
                                    self.monetizeInterlink = true
                                    self.isClapped = true
                                    
                                }
                                else{
                                    
                                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && SessionManager.sharedInstance.isUserPostId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0 > 1{
                                        
                                        cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Clap for this Spark"
                                        
                                        cell.clapBtn?.isHidden = false
                                        cell.createSparkBtn?.isHidden = true
                                        cell.cthreadRequestBtn?.isHidden = true
                                        cell.clapImgView?.isHidden = false
                                        cell.buyNowbtn.isHidden = true
                                        cell.priceLbl.isHidden = true
                                        self.monetizeInterlink = true
                                        self.isClapped = true
                                        
                                    }
                                    else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 0 {
                                        cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                                        cell.clapBtn?.isHidden = true
                                        cell.createSparkBtn?.isHidden = false
                                        cell.cthreadRequestBtn?.isHidden = true
                                        cell.clapImgView?.isHidden = false
                                        cell.buyNowbtn.isHidden = true
                                        cell.priceLbl.isHidden = true
                                        self.monetizeInterlink = false
                                    }
                                    else{
                                        cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                                        cell.clapBtn?.isHidden = true
                                        cell.createSparkBtn?.isHidden = false
                                        cell.cthreadRequestBtn?.isHidden = true
                                        cell.clapImgView?.isHidden = false
                                        cell.buyNowbtn.isHidden = true
                                        cell.priceLbl.isHidden = true
                                        self.monetizeInterlink = false
                                    }
                                    
                                    //}
                                    
                                    
                                    //                                    if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 0 && isFromHomePage{
                                    //                                        cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                                    //                                        cell.clapBtn?.isHidden = true
                                    //                                        cell.createSparkBtn?.isHidden = false
                                    //                                        cell.cthreadRequestBtn?.isHidden = true
                                    //                                        cell.clapImgView?.isHidden = false
                                    //                                        cell.buyNowbtn.isHidden = true
                                    //                                        cell.priceLbl.isHidden = true
                                    //                                        self.monetizeInterlink = false
                                    //                                    }
                                    //                                    else{
                                    //
                                    //                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            }
                            //                            else {
                            //
                            //                                if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 1{
                            //                                    cell.clapBtn?.isHidden = true
                            //                                    cell.buyNowbtn.isHidden = false
                            //                                    cell.priceLbl.isHidden = false
                            //                                    cell.createSparkBtn?.isHidden = true
                            //                                    cell.cthreadRequestBtn?.isHidden = true
                            //                                    cell.clapImgView?.isHidden = false
                            //                                    cell.buyNowbtn.setTitle("Join now", for: .normal)
                            //                                    cell.priceLbl.text = "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencySymbol ?? "")\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)"
                            //                                    cell.descpLbl?.text = "Pay to join this \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Loop"
                            //                                    self.monetizeInterlink = false
                            //                                }
                            //                                else if FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 2{
                            //                                    cell.clapBtn?.isHidden = true
                            //                                    cell.buyNowbtn.isHidden = false
                            //                                    cell.priceLbl.isHidden = true
                            //                                    cell.createSparkBtn?.isHidden = true
                            //                                    cell.cthreadRequestBtn?.isHidden = true
                            //                                    cell.clapImgView?.isHidden = false
                            //                                    cell.buyNowbtn.setTitle("Continue", for: .normal)
                            //                                    cell.descpLbl?.text = "Your payment was successful to join this Loop, Click the below button"
                            //                                    self.monetizeInterlink = false
                            //                                }
                            //                                else{
                            //                                    cell.descpLbl?.text = "If you want to connect with \(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User" : FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "") Spark, Click below button"
                            //                                    cell.clapBtn?.isHidden = true
                            //                                    cell.createSparkBtn?.isHidden = false
                            //                                    cell.cthreadRequestBtn?.isHidden = true
                            //                                    cell.clapImgView?.isHidden = false
                            //                                    cell.buyNowbtn.isHidden = true
                            //                                    cell.priceLbl.isHidden = true
                            //                                    self.monetizeInterlink = false
                            //                                }
                            //
                            //                            }
                        }
                    }
                }
                
                
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    
    /// Asks the delegate for the height to use for a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
    ///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        if isLoading{
        //            if indexPath.section == 1{
        //                if FeedDetailsViewModel.instance.messageListArray?.count ?? 0 == 0{
        //                    return 0
        //                }
        //                else{
        //                    return 300
        //                }
        //            }
        //            else{
        //                return 300
        //            }
        //        }
        //        else{
        return indexPath.section == 1  ? FeedDetailsViewModel.instance.messageListArray?.count ?? 0 == 0 ? 270 :  UITableView.automaticDimension : 400
        //        }
        
        //return indexPath.section == 1  ? FeedDetailsViewModel.instance.messageListArray?.count ?? 0 == 0 ? 300 :  UITableView.automaticDimension : 400
        //return UITableView.automaticDimension
    }
    
    
    
    /// Asks the delegate for the estimated height of a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be. Return automaticDimension if you have no estimate.
    ///  - Providing an estimate the height of rows can improve the user experience when loading the table view. If the table contains variable height rows, it might be expensive to calculate all their heights and so lead to a longer load time. Using estimation allows you to defer some of the cost of geometry calculation from load time to scrolling time.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //  return indexPath.section == 1 ? 300 : UITableView.automaticDimension
        return UITableView.automaticDimension
    }
    
    
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    /// - Parameters:
    ///   - tableView: The table view informing the delegate of this impending event.
    ///   - cell: A cell that tableView is going to use when drawing the row.
    ///   - indexPath: An index path locating the row in tableView.
    ///   - A table view sends this message to its delegate just before it uses cell to draw a row, thereby permitting the delegate to customize the cell object before it is displayed. This method gives the delegate a chance to override state-based properties set earlier by the table view, such as selection and background color. After the delegate returns, the table view sets only the alpha and frame properties, and then only when animating rows as they slide in or out.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if indexPath.section == 0 {
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.mediaUrl ?? "")"
            
            switch FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.mediaType ?? 0 {
                
            case 5:
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
                docVC.url = fullMediaUrl
                self.present(docVC, animated: true, completion: nil)
                
            case 2:
              
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
                vc.url = fullMediaUrl
                vc.modalPresentationStyle = .popover
                self.isPlayerFullScreenDismissed = false
                self.navigationController?.present(vc, animated: true, completion: nil)
                //}
                
                
                
                
            default:
                break
            }
        }
    }
    
    
    /// Asks the delegate for the height to use for the header of a particular section.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: An index number identifying a section of tableView .
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) of the header for section.
    /// - Use this method to specify the height of custom header views returned by your tableView(_:viewForHeaderInSection:) method.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerBgView
    }
    
    
 

    /// Asks the delegate for a view to display in the header of the specified section of the table view.
    /// - Parameters:
    ///   - tableView: The table view asking for the view.
    ///   - section: The index number of the section containing the header view.
    /// - Returns: A UILabel, UIImageView, or custom view to display at the top of the specified section.
    /// - If you implement this method but don’t implement tableView(_:heightForHeaderInSection:), the table view calculates the height automatically, or uses the value of sectionHeaderHeight if set.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" && !loadingData && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.messageListArray?.count ?? 0 > 0 {
                return 40
            }
            return 0
        }
        return 0
    }
    
    /// Share the link with other user
    @objc func shareLink(_ sender: UITapGestureRecognizer){
        print("Tap shared")
        // let indexPath = sender.view?.tag  https://www.spark.synctag.com/Post/622067804af026223442f19c/_id62062a9041a18f4601254816/t_id
        let userId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
        let post_id = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
        let t_id = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? ""
        let url = "https://www.sparkme.synctag.com/Post/\(post_id)/_id\(userId)/t_id\(t_id)"
        self.createShortUrl(urlString: url)
    }
    
    
    /// While pressing the full screen button
//    @objc func callFullscreenplaybtn(sender:UIButton){
//
//
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        let cell = tableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
//        //if cell?.player?.timeControlStatus == .playing{
//        cell?.player?.pause()
//        let currentTime = cell?.player?.currentTime() ?? CMTime()
//        let currentSeconds = CMTimeGetSeconds(currentTime)
//        let fullMediaUrl = cell?.viewModelCell?.getPostedThumbnailUrl ?? ""
//        let vc = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
//        vc.modalPresentationStyle = .fullScreen
//        vc.playerDelegate = self
//        vc.thumNail = fullMediaUrl
//        vc.url = cell?.viewModelCell?.getPostedMediaUrl ?? ""
//        vc.currentSeconds = Double(currentSeconds)
//        self.present(vc, animated: true, completion: nil)
//
//        //}
//
//
//    }
}

extension FeedDetailsViewController: feedTableDelegate{
    
    
    /// Profile button is tapped to open the connection list user profile page
    func profileButtonTapped(sender: UIButton) {
        if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
            
            if isFromNotificationPage{
                connectionListVC.basepostId = postId
                connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                connectionListVC.basethreadId = bseUserThreadId
            }
            else{
                
                connectionListVC.basepostId = postId
                connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                connectionListVC.basethreadId = bseUserThreadId
                
                //                connectionListVC.basepostId = myPostId
                //                connectionListVC.baseuserId = myUserId
                //                connectionListVC.basethreadId = myThreadId
            }
            connectionListVC.linkPostId = SessionManager.sharedInstance.isUserPostId
            connectionListVC.backDelegate = self
            connectionListVC.isMessageList = self.messageList
            connectionListVC.isLoopConversation = isLoopConversation
            connectionListVC.isFromNotification = isFromNotificationPage
            connectionListVC.isFromHomePage = isFromHomePage
            connectionListVC.isFromBubble = isFromBubble
            connectionListVC.isThread = FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread ?? 0
            //connectionListVC.messageListArray = FeedDetailsViewModel.instance.messageListArray
            connectionListVC.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    /// Profile button is tapped to open the connection list user profile page
    func profileButtonTapped(sender: UITapGestureRecognizer) {
        if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
            connectionListVC.backDelegate = self
            if isFromNotificationPage{
                connectionListVC.basepostId = postId
                connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                connectionListVC.basethreadId = bseUserThreadId
            }
            else{
                
                
                connectionListVC.basepostId = postId
                connectionListVC.baseuserId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
                connectionListVC.basethreadId = bseUserThreadId
                //                connectionListVC.basepostId = myPostId
                //                connectionListVC.baseuserId = myUserId
                //                connectionListVC.basethreadId = myThreadId
            }
            
            connectionListVC.linkPostId = SessionManager.sharedInstance.isUserPostId
            connectionListVC.isMessageList = self.messageList
            connectionListVC.isLoopConversation = isLoopConversation
            connectionListVC.isFromNotification = isFromNotificationPage
            connectionListVC.isFromHomePage = isFromHomePage
            connectionListVC.isFromBubble = isFromBubble
            connectionListVC.isThread = FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread ?? 0
            //connectionListVC.messageListArray = FeedDetailsViewModel.instance.messageListArray
            connectionListVC.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    
    /// Show the views of member list using the overlay page
    func homeView(sender: UIButton) {
        if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.viewCount ?? 0 > 0 {
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            if !isNewLoading{
                slideVC.userId = postId//FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
            }
            else{
                slideVC.userId = postId//baseUserPostId
            }
            //
            
            if isLoopConversation{
                slideVC.myUserId = myUserId
                slideVC.myPostId = postId//myPostId
                slideVC.myThreadId = myThreadId
            }
            slideVC.type = 1
            slideVC.delegate = self
            slideVC.backdelegate = self
            slideVC.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList
            slideVC.isFromLoopConversation = self.isLoopConversation
            slideVC.isFromNotification = isFromNotificationPage
            slideVC.isFromHome = isFromHomePage
            debugPrint(slideVC.userId)
            self.present(slideVC, animated: true, completion: nil)
        }
    }
    
    /// Clapof member shown in the overlay page
    func homeClap(sender: UIButton) {
        if FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.clapCount ?? 0 > 0 {
            
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            if !isNewLoading{
                slideVC.userId = postId//FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
            }
            else{
                slideVC.userId = postId//baseUserPostId
            }//FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""//feedListData[sender.tag].postId ?? ""
            if isLoopConversation{
                slideVC.myUserId = myUserId
                slideVC.myPostId = postId//myPostId
                slideVC.myThreadId = myThreadId
            }
            slideVC.type = 2
            slideVC.delegate = self
            slideVC.backdelegate = self
            slideVC.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList
            slideVC.isFromLoopConversation = self.isLoopConversation
            slideVC.isFromNotification = isFromNotificationPage
            slideVC.isFromHome = isFromHomePage
            debugPrint(slideVC.userId)
            self.present(slideVC, animated: true, completion: nil)
        }
    }
    
    /// Show the poptip of each tags
    func tagButtonTapped(sender: UIButton) {
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: self.viewModel.feedListData[sender.tag].tagName ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
        
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: easyTipView?.frame.size.width ?? 0.0, height: easyTipView?.frame.size.height ?? 0.0))
        easyTipView?.addSubview(btn)
        btn.tag = sender.tag
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(tipViewButtonTapped(sender:)), for: .touchUpInside)
    }
    
    ///On pressing the tag open the poptip
    @objc func tipViewButtonTapped(sender:UIButton){
        debugPrint("Tip button Tapped")
        SessionManager.sharedInstance.saveUserTagDetails = ["tagId": self.viewModel.feedListData[sender.tag].tagId ?? "","tagName": self.viewModel.feedListData[sender.tag].tagName ?? ""]
        
        // self.tabBarController?.selectedIndex = 1
        UserDefaults.standard.set(false, forKey: "isFireOnceForTag") //Bool
        NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIcon"), object: ["isFireOnceForTag":true])
    }
    
}

extension FeedDetailsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension FeedDetailsViewController {
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
    
    /// Setup the poptip here
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

extension FeedDetailsViewController : moreMediaDelegate{
    /// Open the multiple media list here
    func openMediaList(sender: UIButton, postType:Int) {
        //let mediaTotal = FeedDetailsViewModel.instance.feedDetails.value?.data?.mediaTotal ?? 0
        //if mediaTotal > 0 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isMonetize == 3{
        let vc = UIStoryboard(name: "Thread", bundle: nil).instantiateViewController(withIdentifier: "MultipleFeedViewController") as! MultipleFeedViewController
        vc.postId = repostId
        vc.userName = self.userName
        vc.profilePic = proPic
        vc.tagName = tagName
        vc.gender = proGender
        vc.postDate = postDate
        vc.postType = postType
        vc.userId = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        //}
    }
    
    
}



extension FeedDetailsViewController : clapDelegate {
    /// On pressing the buy now button or continue button call tthe check thread limit api calls
    func BuyNowOrContinueFunction(sender: UIButton) {
        print("Buy Now or Continue")
        
        
        let monetizeBuyNow = 2
        self.checkThreadLimitObserver(monetizeBuyNow: monetizeBuyNow, showPayment: true)
        let params : [String : Any] = [
            "threadpostId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "",
            "threaduserId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? ""
        ]
        FeedDetailsViewModel.instance.chcekMonetizeLimitApiCall(postDict: params)
        
        
        //showPaymentForm()
        
        
    }
    
    
    /*   func threadRequestFunction(sender: UIButton) {
     checkTagStatusObserver()
     viewModel.checkTagStatusAPICall(params: ["tagId":self.viewModel.feedDetails.value?.data?.postDetails?.tagId ?? ""])
     
     // Create the alert controller
     let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
     
     let titleFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.veryLarge)]
     let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.large)]
     
     let titleAttrString = NSMutableAttributedString(string: "Loop Request", attributes: titleFont)
     let messageAttrString = NSMutableAttributedString(string: "If you wish to create loop request choose anyone of the below button.", attributes: messageFont)
     
     alertController.setValue(titleAttrString, forKey: "attributedTitle")
     alertController.setValue(messageAttrString, forKey: "attributedMessage")
     
     // Create the actions
     let okAction = UIAlertAction(title: "New Post", style: UIAlertAction.Style.default) {
     UIAlertAction in
     NSLog("OK Pressed")
     
     SessionManager.sharedInstance.homeFeedsSwippedObject = nil
     SessionManager.sharedInstance.getTagNameFromFeedDetails = ["tagName":self.viewModel.feedDetails.value?.data?.postDetails?.tagName ?? "",
     "tagID":self.viewModel.feedDetails.value?.data?.postDetails?.tagId ?? "","postId":self.viewModel.feedDetails.value?.data?.postDetails?._id ?? "","userId":self.viewModel.feedDetails.value?.data?.postDetails?.userId ?? ""]
     NotificationCenter.default.post(name: Notification.Name("FromDetailToCreateSpark"), object: nil)
     for controller in self.navigationController!.viewControllers as Array {
     if controller.isKind(of: RAMAnimatedTabBarController.self) {
     self.navigationController!.popToViewController(controller, animated: true)
     break
     }
     }
     
     }
     let existingPost = UIAlertAction(title: "Existing Post", style: UIAlertAction.Style.default) {
     UIAlertAction in
     NSLog("Existing Post Pressed")
     
     let clapDict = ["postId": self.viewModel.feedDetails.value?.data?.postDetails?._id ?? 0,"isClap": true  ] as [String : Any]
     self.viewModel.homeClapApiCall(postDict: clapDict as [String : Any])
     }
     
     let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
     alertController.dismiss(animated: true, completion: nil)
     
     })
     cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
     
     // Add the actions
     alertController.addAction(okAction)
     alertController.addAction(existingPost)
     alertController.addAction(cancelButton)
     
     // Present the controller
     self.present(alertController, animated: true, completion: nil)
     }
     */
    
    /// reply button action when clap and reply button shown
    func createSparkFunction(sender: UIButton) {
        checkTagStatusObserver()
        FeedDetailsViewModel.instance.checkTagStatusAPICall(params: ["tagId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.tagId ?? "","postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0,"postId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? 0])
    }
    
    /// call the clap function foe clap thread api and observer
    func clapFunction(sender: UIButton) {
        
        //        if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId == "" {
        //
        //
        //        }
        
        if !(FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false) && (FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false) && SessionManager.sharedInstance.isUserPostId != "" || FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId == "" && SessionManager.sharedInstance.isUserPostId != "" {
            self.setupHomeClapViewModel()
            clapThreadObserver()
            clapThreadAPICall(postId: SessionManager.sharedInstance.isUserPostId)
            if isFromBubble{
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        else {
            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false {
                
                let clapDict = ["postId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? 0,"isClap":  FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false ,"isBubble":self.isFromBubble,"postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0,"threadId":threadId] as [String : Any]
                FeedDetailsViewModel.instance.homeClapApiCall(postDict: clapDict as [String : Any])
                
            } else {
                let clapDict = ["postId": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? 0,"isClap":  FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false ,"isBubble":self.isFromBubble,"postType":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postType ?? 0,"threadId":threadId] as [String : Any]
                FeedDetailsViewModel.instance.homeClapApiCall(postDict: clapDict as [String : Any])
            }
        }
    }
    
}

extension FeedDetailsViewController: GrowingTextViewDelegate {
    
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        textView.textColor = UIColor.black
        guard range.location == 0 else {
            return true
        }
        
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        //return
//        if textView.text.count > 0{
//            self.sendBtn.isEnabled = false
//        }
//        else{
//            self.sendBtn.isEnabled = true
//
//        }
        return self.textLimit(existingText: textView.text,
                              newText: text,
                              limit: 5000) && newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollToBottom()
    }
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}


extension FeedDetailsViewController {
    
    /// Send the mesasage check the internet and socket connected after that send the message
    func sendMessage(){
        InternetSpeed().testDownloadSpeed(withTimout: 2.0) { [self] megabytesPerSecond, error in
            print("mb\(megabytesPerSecond)")
            if megabytesPerSecond > 1.0{
                
                DispatchQueue.main.async {
                    if Connection.isConnectedToNetwork(){
                        //self.ifNetworkChanged()
                        print("Connected")
                        
                        let text = growingTxtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)
                       
                        if growingTxtView?.text?.count ?? 0 >= 1 && text?.isEmpty ?? false {
                            self.showErrorAlert(error: "Enter the valid input message")
                            self.view.endEditing(true)
                            return
                        }
                        
                        if !SocketIOManager.sharedSocketInstance.isConnected {
                            SocketIOManager.sharedSocketInstance.ConnectsToSocket()
                        }
                        
                        if (growingTxtView?.text ?? "").isEmpty {
                            return
                        }
                        
                        let param = ["from": SessionManager.sharedInstance.getUserId,
                                     "to": SessionManager.sharedInstance.threadId,
                                     "message": text ?? "",//growingTxtView?.text ?? "",
                                     "displayName": SessionManager.sharedInstance.saveUserDetails["currentUsername"] ?? "",
                                     "profilePic": SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] ?? "",
                                     "timestamp": Int(NSDate().timeIntervalSince1970),
                                     "allowAnonymous":FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.allowAnonymous ?? false,
                                     "postId":SessionManager.sharedInstance.isUserPostId,
                                     "gender":FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.gender ?? 0] as [String : Any]
                        
                        SocketIOManager.sharedSocketInstance.emitMessageToOpponent(param: param)
                        if SocketIOManager.sharedSocketInstance.isConnected{
                            self.growingTxtView?.text = ""
                            //self.sendBtn.isEnabled = false
                        }
                        
                        
                        
                        
                    }
                    else{
                        self.growingTxtView.resignFirstResponder()
                        let alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
                        
                        
                        
                        let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                            // ... Do something
                            internetRetry()
                            self.growingTxtView.resignFirstResponder()
                            
                        }
                        alertController.addAction(OKAction)
                        
                        self.present(alertController, animated: true) {
                            // ... Do something
                        }
                        
                    }
                    
                }
                
            }
            else{
                //self.growingTxtView.resignFirstResponder()
                DispatchQueue.main.async {
                    //self.growingTxtView.text = ""
                    let alertController = UIAlertController(title: "Poor network", message: "Please check your internet connection or try again later", preferredStyle: .alert)
                    
                    
                    
                    let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                        // ... Do something
                        internetRetry()
                        self.growingTxtView.resignFirstResponder()
                        
                    }
                    alertController.addAction(OKAction)
                    
                    self.present(alertController, animated: true) {
                        // ... Do something
                    }
                }
                
            }
        }
    }
    
    /// On pressing the send messagew button
    @IBAction func sendMessageButtonTapped(sender:UIButton) {
        
        //viewModel.receiveMessage()
        NotificationCenter.default.addObserver(self,selector: #selector(statusManager),name: .flagsChanged,object: nil)
        updateUserInterface()
        self.sendMessage()
        
        
    }
    
    /// Scroll to bottom of the page when the message received or sent
    func scrollToBottom() {
        
        if((FeedDetailsViewModel.instance.messageListArray?.count ?? 0) > 1 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && !SessionManager.sharedInstance.threadId.isEmpty) {
            let indexPath = IndexPath(row: (FeedDetailsViewModel.instance.messageListArray?.count ?? 0) - 1, section: 1)
            
            let isIndexValid = FeedDetailsViewModel.instance.messageListArray?.indices.contains(indexPath.row)
            if isIndexValid == true {
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
    }
    
    
    
    /// retry the internbet and connect the socket
    func internetRetry(){
        if Connection.isConnectedToNetwork(){
            // ifNetworkChanged()
            print("Connected")
            SocketIOManager.sharedSocketInstance.delegate = self
            SocketIOManager.sharedSocketInstance.ConnectsToSocket()
            
            FeedDetailsViewModel.instance.receiveMessage()
            
            receiveBaseUserCloseThread()
            receiveMemberCloseThread()
            
            if SocketIOManager.sharedSocketInstance.isConnected {
                SocketIOManager.sharedSocketInstance.closeThreadEmit(param: ["postId":SessionManager.sharedInstance.isUserPostId,"threadId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? "","userId":SessionManager.sharedInstance.getUserId,"status":1])
            }
            
        }
        else{
            self.alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
            
            
            
            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                // ... Do something
                internetRetry()
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ... Do something
            }
            
        }
    }
    
    /// Exit the loop  after connecting socket remove member from the loop
    func exitloop(){
        
        if Connection.isConnectedToNetwork(){
            print("Connected")
            
            if SocketIOManager.sharedSocketInstance.isConnected {
                SocketIOManager.sharedSocketInstance.closeThreadEmit(param: ["postId":SessionManager.sharedInstance.isUserPostId,"threadId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? "","userId":SessionManager.sharedInstance.getUserId,"status":1])
            }
            
        }
        else{
            self.alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
            
            
            
            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                // ... Do something
                self.exitloop()
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ... Do something
            }
            
        }
        
    }
    
    
    
    /// Add more context is used to redirct with create post view controller
    @IBAction func addmoreContextButtonTapped(sender:UIButton) {
        print(postUserId)
        print(memberCount)
        print(SessionManager.sharedInstance.getUserId)
        self.MoreView.isHidden = true
        self.isMoreEnabled = false
        if SessionManager.sharedInstance.getUserId == postUserId && memberCount > 1 {
            print("move")
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
            vc.isFromLoopRepost = true
            vc.FromLoopMonetize = 1 //isMonetise
            vc.multiplePost = 1
            vc.repostId = self.repostId
            //vc.postType = self.postType
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
    /// End the conversation button tapped to exit from the loop
    @IBAction func endConversationButtonTapped(sender:UIButton) {
        
        let alert = UIAlertController(title: "Exit Loop", message: "Do you want to exit from this loop?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            
            self.exitloop()
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    
    /// Base close thread is used to remove the member or exit from loop
    ///  - Status:
    ///   - If Status is 1 then it will exit the user from the loop
    ///   - If Status is 2 then it will remove the member from the loop
    func receiveBaseUserCloseThread() {
        
        SocketIOManager.sharedSocketInstance.newsocket.on("basecloseThread") { data, ack in
            print("Base User Close Thread",data[0])
            
            let receivedMsgDict = data[0] as? NSDictionary
            
            self.view.endEditing(true)
            if receivedMsgDict?.value(forKey: "status") as? Int ?? 0 == 2 { //status - 2 - popup
                self.showErrorAlert(error: "Someone left from this loop")
                
                //                FeedDetailsViewModel.instance.messageListArray = []
                //                self.setupViewModel()
                //                self.getFeedDetailsAndMemberList(postId: self.postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: self.isFromBubble ? true : false)
            }else{
                self.threadPopUpCancelBtn.isHidden = true
                self.threadPopUpBgView.isHidden = false
            }
        }
    }
    
    
    
    /// Member close thread is used to remove the member or exit from loop
    ///  - Status:
    ///   - If Status is 1 then it will exit the user from the loop
    ///   - If Status is 2 then it will remove the member from the loop
    func receiveMemberCloseThread() {
        
        SocketIOManager.sharedSocketInstance.newsocket.on("membercloseThread") { data, ack in
            print("Member Close Thread",data[0])
            self.view.endEditing(true)
            let receivedMsgDict = data[0] as? NSDictionary
            
            if receivedMsgDict?.value(forKey: "status") as? Int ?? 0 == 2 { //status - 2 - popup
                self.showErrorAlert(error: "Someone left from this loop")
                //self.navigationController?.popViewController(animated: true)
                //FeedDetailsViewModel.instance.messageListArray = []
                if !self.isRemoved{
                    self.setupViewModel()
                    FeedDetailsViewModel.instance.messageListArray = []
                    
                    //self.getFeedDetailsAndMemberList(postId: self.postId, threadId: SessionManager.sharedInstance.threadId, linkUserId: SessionManager.sharedInstance.userIdFromSelectedBubbleList, isFromBubble: self.isFromBubble ? true : false)
                    
                    self.getSelectedMemberListPostDetails(postId: self.postId, userId: FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "")
                    self.isRemoved = true
                }
                //
            }else{
                self.threadPopUpCancelBtn.isHidden = true
                self.threadPopUpBgView.isHidden = false
                
            }
        }
    }
}

extension FeedDetailsViewController : anonymousDelegate {
    
    /// Anonymous user can get the identity nby using this method
    func anonymousFunction(sender: UIButton) {
        
        revealIdentityObserver()
        
        if FeedDetailsViewModel.instance.messageListArray?[sender.tag].allowAnonymous ?? false {
            
            // Create the alert controller
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            let titleFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.veryLarge)]
            let messageFont = [NSAttributedString.Key.font: UIFont.MontserratRegular(.normal)]
            
            let titleAttrString = NSMutableAttributedString(string: "Reveal Request", attributes: titleFont)
            let messageAttrString = NSMutableAttributedString(string: "\nAre you sure want to give reveal request to this member?", attributes: messageFont)
            
            alertController.setValue(titleAttrString, forKey: "attributedTitle")
            alertController.setValue(messageAttrString, forKey: "attributedMessage")
            
            // Create the actions
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                let revealIdentityDict = [
                    "threadId":FeedDetailsViewModel.instance.messageListArray?[sender.tag].threadId ?? "",
                    "userId":FeedDetailsViewModel.instance.messageListArray?[sender.tag].from ?? "",
                    "postId":FeedDetailsViewModel.instance.messageListArray?[sender.tag].postId ?? "",
                    "timestamp":Int(NSDate().timeIntervalSince1970),
                    "revealPostId":FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId ?? "",
                    "revealUserId":FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.userId ?? ""
                ] as [String : Any]
                FeedDetailsViewModel.instance.revealIdentityAPICall(params: revealIdentityDict)
                
            }
            
            let cancelButton = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelButton)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


extension FeedDetailsViewController {
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //
    //        if scrollView == tableView {
    //
    //            if (scrollView.contentOffset.y <= 20)
    //            {
    //                loadMoreData()
    //            }
    //        }
    //    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData  {
            self.loadingData = true
            self.nextPageKey = FeedDetailsViewModel.instance.conversationMessageList.value?.data?.paginator?.nextPage ?? 1
            
            if FeedDetailsViewModel.instance.feedDetails.value?.data?.isClap ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isTag ?? false && FeedDetailsViewModel.instance.feedDetails.value?.data?.isThread == 2 && FeedDetailsViewModel.instance.feedDetails.value?.data?.isUser?.postId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId != "" && FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList?.count ?? 0 > 1 {
                
                print(previousPageKey)
                
                conversationMessageListAPICall(isVerified: FeedDetailsViewModel.instance.conversationMessageList.value?.data?.paginator?.isVerfied ?? false)
                
                
            }
        }
    }
    
    
    /// Initialise the razor payment here
    ///  - Set the base post id, base user id, userid
    ///  - Set the currency type, Save the mobile number, email
    private func showPaymentForm(){
        razorpay = RazorpayCheckout.initWithKey(Endpoints.razorPayTestKey.rawValue, andDelegate: self)
        print(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0)
        let monetizeAmount = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.monetizeAmount ?? 0
        print(monetizeAmount * 100)
        let notes : [String : Any ] = [
            "basePostId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "",
            "baseUserId":FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.userId ?? "",
            "userId":SessionManager.sharedInstance.getUserId,
            "amount":monetizeAmount
        ]
        
        let retry : [String : Any ] = [
            "enabled":true,
            "max_count":4
        ]
        
        
        let instruments : [[String: Any]] = [
            ["method": "upi"],["method": "card"],["method": "netbanking"]
            
        ]
        
        
        let banks : [String : Any] = [
            "name" : "All payment methods",
            "instruments" : instruments
        ]
        
        
        let preferences : [String : Any] = [
            "show_default_blocks" : false
        ]
        let Sequence : [String] = [
            "block.banks"
        ]
        
        let blocks : [String:Any] = [
            "banks" : banks
        ]
        
        let Display : [String : Any] = [
            "blocks" : blocks,
            "preferences":preferences,
            "sequence":Sequence
        ]
        let config : [String : Any] = [
            "display" : Display
        ]
        
        
        let options: [AnyHashable:Any] = [
            "prefill": [
                "contact": SessionManager.sharedInstance.saveMobileNumber,
                "email": SessionManager.sharedInstance.saveEmail
            ],
            
            "image": "https://sparkdevelop.blob.core.windows.net/sparkdevelop/tQ9nFOD.png",
            "name" : "Spark me",
            "amount" : monetizeAmount * 100,
            "currency": FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.currencyCode ?? "",
            "theme": [
                "color": "#528FF0"
            ],
            "send_sms_hash":true,
            "notes":notes,
            "retry":retry,
            "config":config
            //"order_id": "order_DBJOWzybf0sJbb12121"
            // and all other options
        ]
        
        print(options)
        if let rzp = self.razorpay {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
}

extension FeedDetailsViewController : threadRequestDelegate, receivedMessageDelegate {
    
    /// Receive the message and scroll to bottom
    func receivedMessageDetails() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
            self.scrollToBottom()
        }
    }
    
    /// Threadrequest details call the selected member post id, member userid and post id
    /// - Call the api of feed detail member list
    func threadRequestDetails(selectedMemberPostId: String, selectedMemberUserId: String, postId: String) {
        isFromThreadRequestPage = true
        //isCallBubbleAPI = false
        //isMemberSelected = false
        
        getFeedDetailsAndMemberList(postId: FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? "", threadId: SessionManager.sharedInstance.threadId, linkUserId: selectedMemberUserId, isFromBubble:  false)
    }
}


///Popup
extension FeedDetailsViewController {
    
    /// Okay button tapped to hide the popview and dismiss the navigation
    @IBAction func okButtonTapped(sender:UIButton) {
        threadPopUpBgView.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonTapped(sender:UIButton) {
        
        
    }
}

//Payment delegate
extension FeedDetailsViewController: RazorpayPaymentCompletionProtocol{
    /// On payment error it will show the alert
    func onPaymentError(_ code: Int32, description str: String) {
        print("Payment failed")
        self.showErrorAlert(error: str)
    }
    
    
    /// On payment success need pass the payment id will alert success
    ///  - If monetize interlink Call the clap thread observer
    ///   - i) Call the clap thread monetize api calll with monetize id
    ///  - Else move to create post page
    ///
    func onPaymentSuccess(_ payment_id: String) {
        print("Payment success")
        self.showErrorAlert(error: "Payment successful")
        
        if monetizeInterlink{
            self.isNewLoading = true
            clapThreadObserver()
            clapThreadMonetizeAPICall(postId: myBasePostMonetizeId)
        }
        else{
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CreatePostViewController") as! CreatePostViewController
            vc.isFromLoopRepost = false
            vc.FromLoopMonetize = 2 //isMonetise
            vc.multiplePost = 0
            //vc.monetizeBuyNow = monetizeBuyNow
            vc.repostId = self.repostId
            vc.backSearchDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    
    
}


extension FeedDetailsViewController : getPlayerVideoAudioIndexDelegateForDetailPage {
    
    /// Video player full screen dismiss pass the bubble api boolean to true
    func videoPlayerFullScreenDismiss() {
        isPlayerFullScreenDismissed = false
        //self.membersList = FeedDetailsViewModel.instance.feedDetails.value?.data?.membersList ?? [MembersList]()
        //isNewLoading = false
        isNewLoading = true
        // self.backDelegate = nil
        
        if !isFromBubble {
            isCallBubbleAPI = true
        }
    }
}
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension UITableView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - frame.size.height
        if y < 0 { return }
        setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }
}
