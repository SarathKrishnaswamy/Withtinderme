//
//  FeedSearchViewController.swift
//  Spark
//
//  Created by Gowthaman P on 04/08/21.
//

import UIKit
import AVKit
import EasyTipView
import RSLoadingView
import SwiftyGif
import CCBottomRefreshControl
import UIView_Shimmer

protocol backFromImageDelegate{
    func backfromimage()
}


protocol fromFeedDelegate{
    func isFromBack()
}

protocol getSearchItemDelegate{
    func getTag(tagId:String, tagName:String, postType:Int)
}


/**
 Search - By default shows Global Monetized Post list and based on the input the post list will be shown.
 */
class FeedSearchViewController: UIViewController, backToHomeFromDetailPage,getPlayerVideoDelegate,backFromOverlay,backFromImageDelegate,backfromFeedDelegate, TagListViewDelegate, getSearchItemDelegate {
    
    /// It is used to back to select the delegate
    func back(postId: String, threadId: String, userId: String, memberList:[MembersList], messageListApproved:Bool, isFromLoopConversation:Bool, isFromNotify:Bool, isFromHome:Bool, isFromBubble:Bool, isThread:Int, linkPostId:String) {
        self.isNewLoading = true
        
    }
    
    func getTag(tagId: String, tagName: String, postType: Int) {
        self.isNewLoading = true
       
       
    }
    
    /// back from the image page
    func backfromimage() {
        isPlayerFullScreenDismissed = false
        tagSelectedForSearch = true
    }
    
   
    
    /// back from home detail page 
    func backToHomeFromDetail(indexPath: Int, selectedHomePageLimit: Int, postType: Int, isFromLink:Bool) {
        isFromDetailPage = true
        tagSelectedForSearch = true
        let IndexPath = IndexPath(row: indexPath, section: 0)
        let cell = collectionView?.cellForItem(at: IndexPath) as? NewsCardCollectionCell
        //searchBar?.placeholder = "Search here"
        //searchBar?.text = ""
        //selectedTagId = ""
        //setupViewModel()
        //viewModel.feedListData = []
        
       // getFeedList(text: "", tagId: "")
        
      
        
        //print(indexPath.row)
    }
    
    
    /// Dsimiss overlay with the userId and indexPath have been used to open the ConnectionList other user profile page
    func dismissOverlay(userId: String, IndexPath: Int) {
        print("Back from view")
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        connectionListVC.indexPath = IndexPath
        connectionListVC.backDelegate = self
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
    
   // @IBOutlet private weak var searchBar:SearchBar?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var SearchView:UIView!
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchHereLbl: UILabel!
    @IBOutlet weak var tagViewLbl: UILabel!
    
    
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var globalIcon: UIImageView!
    @IBOutlet weak var globalLbl: UILabel!
    
    
    var isFromDetailPage = false
    
    let viewModel = FeedSearchViewModel()
    var homeBaseModel : homeBaseModel?
    var trailingBoolForSwipe = Bool()
    var selectedIndexPath = 0
    var limit = 10
    var nextPageKey = 1
    var previousPageKey = 1
    let refreshControl = UIRefreshControl()
    var clappedTagName = ""
    
    //paginator
    var loadingData = false
    var isAPICalled = false
    
    var selectedTag = ""
    var selectedTagId = ""
    
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet var noMoreView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tagView: UIView!
    
   
    var playedVideoIndexPath = 0
    
    var repostSwippedDataIndexPath = 0
    
    // Thread popup objects
    @IBOutlet weak var threadPopUpBgView: UIView!
    
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpMaybeLaterBtn: UIButton!
    @IBOutlet weak var threadPopUpStartThreadBtn: UIButton!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var SearchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagViewWidth: NSLayoutConstraint!
    
    var clapDataModel = [ClapData]()
    
    var threadpostId = ""
    var threaduserId = ""
    var tagSelectedForSearch = false
    
    var isLoadMore = false
    
    var currentIndexPath = IndexPath(row : 2, section : 0)
    private var lastContentOffset: CGFloat = 0
    
    var isFreshDataLoad = false
    
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    
    var isPlayerFullScreenDismissed = false
    var isLoading = false
    var isNewLoading = false
    var nft = 0
    var monetize = 1
    var postType = 1
    var tagArray = [String]()
    
    /// Get the feed list with view model api call
    fileprivate func getFeedList(text:String,tagId:String) {
        self.viewModel.feedListData = []
        let params = [
            "postType" :postType,
            "coordinates":[postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0 : 0.0,postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0 : 0.0],
            "monetize": monetize,
            "nft": nft,
            "text" : text,
            "tagId":tagId,
            "paginator":[
                "nextPage": 1,
                "pageSize": limit,
                "pageNumber": 1,
                "totalPages" : 1,
                "previousPage" : 1]
            
        ] as [String : Any]
        viewModel.searchFeedListApiCallNoLoading(postDict: params)
    }
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.SearchView.layer.borderWidth = 0.0
        SearchView.layer.borderColor = UIColor.lightGray.cgColor
        SearchView.layer.masksToBounds = true
        SearchView.layer.cornerRadius = 7.0
        self.closeBtn.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.closeBtn.frame.width, height: self.closeBtn.frame.height))
        self.closeBtn.layer.cornerRadius = self.closeBtn.frame.width/2
        self.closeBtn.isHidden = true
        limit = 20
        self.globalView.isHidden = true
        self.tagList.delegate = self
        self.tagList.isHidden = true
        self.globalView.layer.masksToBounds = true
        self.globalView.layer.cornerRadius = 6.0
        self.SearchViewHeight.constant = 50
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchTapped(_:)))
        self.SearchView.addGestureRecognizer(tap)
        self.tagList.textFont = UIFont(name: "Montserrat-Regular", size: 14) ?? UIFont()
        

        //setupHomeClapViewModel(indexPath: <#Int#>)
        self.collectionView?.setContentOffset(.zero, animated: true)

        
//        self.searchBar?.delegate = self
//        searchBar?.backgroundImage = UIImage()
//        searchBar?.searchTextField.clearButtonMode = .never
//        searchBar?.setValue("Clear", forKey: "cancelButtonText")
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.init(hexString: "#358383")], for: .normal)
//        searchBar?.showsCancelButton = true
        tagView.isHidden = true
        tagView.layer.cornerRadius = 4.0
        tagView.layer.masksToBounds = true
        noMoreView.isHidden = true
        threadPopUpBgView.isHidden = true
        //]setupViewModel()
        //setupHomeClapViewModel()
       // searchBar?.isUserInteractionEnabled = false
        
        
     
        
        easyTipViewSetUp()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    
    /// Global selected
    func globalSelected(){
        self.searchHereLbl.isHidden = true
        self.searchImage.isHidden = true
        self.globalView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        self.globalLbl.text = "Global"
        self.globalLbl.textColor = .white
        self.globalIcon.image = UIImage(named: "global")
        self.globalView.layer.borderWidth = 0.0
        self.postType = 1
        self.closeBtn.isHidden = false

    }
    
    ///Local selected
    func localSelected(){
        self.searchHereLbl.isHidden = true
        self.searchImage.isHidden = true
        self.globalView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        self.globalLbl.text = "Local"
        self.globalLbl.textColor = .white
        self.globalIcon.image = UIImage(named: "local")
        self.globalView.layer.borderWidth = 0.0
        self.postType = 2
        self.closeBtn.isHidden = false
        
    }
    
    /// Social has been selected
    func socialSelected(){
        self.searchHereLbl.isHidden = true
        self.searchImage.isHidden = true
        self.globalView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        self.globalLbl.text = "Social"
        self.globalLbl.textColor = .white
        self.globalIcon.image = UIImage(named: "social")
        self.globalView.layer.borderWidth = 0.0
        self.postType = 3
        self.closeBtn.isHidden = false
    }
    
   /// closed selected
    func closedSelected(){
        self.searchHereLbl.isHidden = true
        self.searchImage.isHidden = true
        self.globalView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        self.globalLbl.text = "Closed"
        self.globalLbl.textColor = .white
        self.globalIcon.image = UIImage(named: "closed")
        self.globalView.layer.borderWidth = 0.0
        self.postType = 4
        self.closeBtn.isHidden = false
    }
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if !isNewLoading{
            isLoading = true
            //self.collectionView.reloadData()
            
            
            refreshControl.attributedTitle = NSAttributedString(string: "Loading new Sparks")
            refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            collectionView?.addSubview(refreshControl)
            
        
            self.tabBarController?.tabBar.isHidden = false
            //self.tabBarItem.image = UIImage(named: "Search_Color")
            setupViewModel(isCleared: false)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            

            
            isFreshDataLoad = true
            let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
            let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
            if cell?.isFullscreen == true{
                cell?.isFullscreen = false
            }
            cell?.activityLoader.isHidden = true
            
            if !(SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String ?? "").isEmpty {
               // searchBar?.text = SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String
                print("My Posttype pressed is")
                print(SessionManager.sharedInstance.saveUserTagDetails["postType"] as? Int ?? 0)
                let myPosttype = SessionManager.sharedInstance.saveUserTagDetails["postType"] as? Int ?? 0
                self.globalView.isHidden = false
                if myPosttype == 1{
                    self.globalSelected()
                }
                else if myPosttype == 2{
                    self.localSelected()
                }
                else if myPosttype == 3{
                    self.socialSelected()
                    
                }
                else if myPosttype == 4{
                    self.closedSelected()
                }
                
                self.tagView.isHidden = false
                self.tagList.isHidden = false
                self.SearchViewHeight.constant = 50
                self.tagViewWidth.constant = 70
                self.monetize = 0
                if monetize == 0{
                    self.tagList.isHidden = true
                }
                self.nft = 0
                self.tagViewLbl.text =  SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String ?? ""
                selectedTag = SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String ?? ""
                selectedTagId = SessionManager.sharedInstance.saveUserTagDetails["tagId"] as? String ?? ""
                self.viewModel.feedListData = []
                self.tagViewLbl.text = selectedTag
                getFeedList(text: SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String ?? "", tagId: SessionManager.sharedInstance.saveUserTagDetails["tagId"] as? String ?? "")
            }
            else {
                
                self.globalView.isHidden = true
                self.tagView.isHidden = true
                self.tagList.isHidden = true
                self.SearchViewHeight.constant = 50
                self.closeBtn.isHidden = true
                self.searchImage.isHidden = false
                self.searchHereLbl.isHidden = false
                self.monetize = 1
                self.nft = 0
                //self.postType = 1
                self.selectedTag = ""
                self.selectedTagId = ""
                if !tagSelectedForSearch {
                    if !isPlayerFullScreenDismissed  && !isFromDetailPage && !SessionManager.sharedInstance.isImageFullViewed { ////Not called when video full screen dismissed
                        ///
                        self.postType = 1
                        setupViewModel(isCleared: false)
                        self.scrollToIndex(index: 0)
                        getFeedList(text: "", tagId: "")
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    }else{
                        isLoading = false
                        SessionManager.sharedInstance.isImageFullViewed = false
                    }
                }
                if !tagSelectedForSearch{
                    if selectedTag.isEmpty {
                        //searchBar?.placeholder = "Search here"
                        //searchBar?.text = ""
                        selectedTagId = ""
                    }
                }
                else{
                    isLoading = false
                }
                
                threadPopUpBgView.isHidden = true
                threadPopUpBgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
            }
            
        }
        else{
            isNewLoading = false
        }
        
       
//        let bottomRefreshController = UIRefreshControl()
//        bottomRefreshController.triggerVerticalOffset = 50
//        bottomRefreshController.attributedTitle =  NSAttributedString(string: "Loading Sparks")
//        bottomRefreshController.tintColor = UIColor.defaultTintColor
//        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
//        collectionView.bottomRefreshControl = bottomRefreshController
        
        SessionManager.sharedInstance.isBoolForInshortsLayout = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "NewsCardCollectionCell", bundle: nil), forCellWithReuseIdentifier: "NewsCardCollectionCell")
        self.collectionView.register(UINib.init(nibName: "MonetizeNewscardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MonetizeNewscardCollectionViewCell")
    }
    
    
    ///api call for loading more data
    @objc func refreshBottom() {
         //api call for loading more data
         loadMoreData()
    }
    
    func scrollToIndex(index:Int) {
        let rect = self.collectionView?.layoutAttributesForItem(at:IndexPath(row: index, section: 0))?.frame
         self.collectionView?.scrollRectToVisible(rect!, animated: false)
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
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFromDetailPage = false
        easyTipView?.dismiss()

//        isPlayerFullScreenDismissed = false
        SessionManager.sharedInstance.saveUserTagDetails["tagName"] = ""
        SessionManager.sharedInstance.saveUserTagDetails["tagId"] = ""
        SessionManager.sharedInstance.saveUserTagDetails["postType"] = 1
        self.isNewLoading = false
//        self.globalView.isHidden = true
//        self.postType = 1
//        self.closeBtn.isHidden = true
//        self.searchImage.isHidden = false
//        self.searchHereLbl.isHidden = false
//        self.viewModel.feedListData = []
//        self.selectedTag = ""
//        self.selectedTagId = ""
//        getFeedList(text: "", tagId: "")
//        self.tagView.isHidden = true
//        self.tagList.removeAllTags()
//        self.tagList.isHidden = true
//        self.SearchViewHeight.constant = 40
//        self.isNewLoading = false
//        self.monetize = 1
//        if searchBar?.text?.isEmpty == true{
//            selectedTag = ""
//            selectedTagId = ""
//        }
//        else{
//            selectedTag = ""
//            selectedTagId = ""
//        }
        
        tagSelectedForSearch = false
        
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
        
       
        
        //self.collectionView?.setContentOffset(.zero, animated: true)
        
        SessionManager.sharedInstance.saveUserTagDetails = [:]
    }
    
    
    /// Dismiss the Full screen video when we have the video to play
    func fullVideoScreenDismiss(currentSeconds:Double){
        
        isPlayerFullScreenDismissed = true
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        let newTime = CMTime(seconds: Double(currentSeconds), preferredTimescale: 600)
        cell?.player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        cell?.player?.pause()
        cell?.playToggle = 1
       
    }
    
    /// Refresh the page by when swipping from top of the page in tableview
    /// - call the api to load
    @objc func refresh(_ sender: AnyObject) {
        
        if !isNewLoading{
            self.collectionView.reloadData()
            self.isLoading = true
            viewModel.feedListData = []
           // self.searchBar?.text = ""
           // selectedTagId = ""
            print(SessionManager.sharedInstance.saveUserTagDetails["tagName"] as? String ?? "")
            print(SessionManager.sharedInstance.saveUserTagDetails["tagId"] as? String ?? "")
            refreshControl.endRefreshing()
            getFeedList(text: selectedTag, tagId: selectedTagId)
            
            //getNotificationPreviousListValues(PageNumber: 1, PageSize: limit, tagId: selectedTagId)
        }
        else{
            
        }
        
        
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
     
    
    /// When app moved to foreground 
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
    
    
    
    /// Tapped on search view it will the search tag feed page
    @objc func touchTapped(_ sender: UITapGestureRecognizer) {
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        
        cell?.playerController?.player?.pause()
        cell?.avplayer?.pause()
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let searchVC = storyBoard.instantiateViewController(identifier: "SearchTagFeedViewController") as! SearchTagFeedViewController
        searchVC.delegate = self
        searchVC.isFromSearch = true
        searchVC.delegate = self
        if self.globalView.isHidden == true{
            
        }
        else{
            
            searchVC.SearchTag = selectedTag
            searchVC.tagId = selectedTagId
            searchVC.nft = nft
            searchVC.postType = postType
            searchVC.monetize = monetize
        }
        
        // searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true, completion: nil)
    }
    
    
    ///Clear all button tapped to clear all the tag inside search page
    @IBAction func clearAllBtnOnPressed(_ sender: Any) {
        viewModel.feedListData = []
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        
        cell?.playerController?.player?.pause()
        cell?.avplayer?.pause()
        self.tagList.removeAllTags()
        self.tagList.isHidden = true
        self.tagView.isHidden = true
        self.tagViewLbl.text = ""
        self.globalView.isHidden = true
        self.SearchViewHeight.constant = 50
        self.closeBtn.isHidden = true
        self.searchImage.isHidden = false
        self.searchHereLbl.isHidden = false
        self.postType = 1
        self.selectedTag = ""
        self.selectedTagId = ""
        self.nft = 0
        self.monetize = 1
        setupViewModel(isCleared: true)
        getFeedList(text: "", tagId: "")
        
        self.scrollToIndex(index: 0)
    }
    
    

    
    
   
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    /// Declare the tableview scroll to pause the player when it is playing
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method as the user’s finger touches up as it’s moving during a scrolling operation; the scroll view continues to move a short distance afterwards. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        //
        
        
        
        if viewModel.feedListData.count > 0{
            
            guard let indexPath = collectionView.indexPathsForVisibleItems.first else {
                return
            }

            
            
            let monetize = viewModel.feedListData[indexPath.item].monetize ?? 0
            if monetize == 1{
                let cell = collectionView?.cellForItem(at: indexPath) as? MonetizeNewscardCollectionViewCell
                
                //cell?.audioAnimationBg.stopAnimatingGif()
                cell?.avplayer?.pause()
                cell?.playerController?.player?.pause()
                
            }
            else{
                let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                
                //cell?.audioAnimationBg.stopAnimatingGif()
                cell?.avplayer?.pause()
                cell?.playerController?.player?.pause()
            }
        }
        
       
        
        
      
        

    }
    
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        
////        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
////        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
//        //cell?.audioAnimationBg.stopAnimatingGif()
////        for cell in collectionView.visibleCells {
////            let indexPath = collectionView.indexPath(for: cell)
////            let cell = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? NewsCardCollectionCell
////            if viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0 == 1{
////                print("Inside If \(viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0)")
////                cell?.monetizeView.isHidden = false
////                cell?.removeGestureRecognizer(cell?.rightSwipe ?? UIGestureRecognizer())
////                cell?.contentView.addGestureRecognizer(cell?.leftSwipe ?? UIGestureRecognizer())
////            }
////            else{
////                print("Inside else \(viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0)")
////                cell?.monetizeView.isHidden = true
////                cell?.contentView.addGestureRecognizer(cell?.rightSwipe ?? UIGestureRecognizer())
////                cell?.contentView.addGestureRecognizer(cell?.leftSwipe ?? UIGestureRecognizer())
////            }
////
////
////        }
//        
//        let visibleCells = self.collectionView.visibleCells
//                for cell in visibleCells {
//                    let indexPath = collectionView.indexPath(for: cell)
//                    let monetize = viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0
//                    
//                    if monetize == 1{
//                        let cells = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? MonetizeNewscardCollectionViewCell
//                        if self.collectionView.bounds.contains(cell.frame) { // condition here should do the trick to find cells which are completely visible in collection view
//                            print("Completed cell")
//                            //cells?.playerRemove()
//                            cells?.playerController?.player?.pause()
//                            cells?.avplayer?.pause() //probably you can play video here
//                        }
//                        else {
//                            cells?.playerController?.player?.pause()
//                            cells?.avplayer?.pause()  //you can pause video here
//                        }
//                    }
//                    else{
//                        let cells = collectionView.cellForItem(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as? NewsCardCollectionCell
//                        if self.collectionView.bounds.contains(cell.frame) { // condition here should do the trick to find cells which are completely visible in collection view
//                            print("Completed cell")
//                            //cells?.playerRemove()
//                            cells?.playerController?.player?.pause()
//                            cells?.avplayer?.pause() //probably you can play video here
//                        }
//                        else {
//                            cells?.playerController?.player?.pause()
//                            cells?.avplayer?.pause()  //you can pause video here
//                        }
//                    }
//                    
//                    
//                  
//                }
//    
//        
//         
////
//        
//    }
    
    /// When the scroll getting ends it will dismiss the pop tip of tag
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        easyTipView?.dismiss()
    }
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData  {
            self.loadingData = true
            noMoreView.isHidden = true
            self.nextPageKey = self.viewModel.homeBaseModel.value?.data?.paginator?.nextPage ?? 0
            getMoreFeedList(PageNumber: nextPageKey, PageSize: limit, tagId: selectedTagId)
        }
        else {
            self.noMoreView.isHidden = true
        }
    }
    
    
    /// Check the thread limit with observer of api call
    func checkThreadLimitObserver(indexPath:Int) {
        
        viewModel.checkThreadLimitModel.observeError = { [weak self] error in
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
        viewModel.checkThreadLimitModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.status == 2 {
                    self.showErrorAlert(error: value.data?.message ?? "")
                }
                else if value.data?.status == 1 { //Allow to create repost
                    SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                    SessionManager.sharedInstance.homeFeedsSwippedObject = self.viewModel.feedListData[self.repostSwippedDataIndexPath]
                    self.tabBarController?.selectedIndex = 2
                    SessionManager.sharedInstance.isRepost = true
                }
                
            }
        }
        
    }
    
    
    ///Check the thread limit with observer value and check for loop joining
    func checkThreadLimitObserverForClapAndLoopCreation(indexPath:Int) {
        
        viewModel.checkThreadLimitModelForClapAndLoopRequest.observeError = { [weak self] error in
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
                    clappedTagSelectionVC.backDelegate = self
                    self.navigationController?.pushViewController(clappedTagSelectionVC, animated: true)
                }
                
            }
        }
        
    }
    
    /// Gwt more feed list with the search api call
    func getMoreFeedList(PageNumber:Int,PageSize:Int,tagId:String) {
        
        let params = [
            "postType" :postType,
            "coordinates":[postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0 : 0.0,postType == 2 ? SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0 : 0.0],
            "monetize": monetize,
            "nft": nft,
            "text" : selectedTag,
            "tagId":tagId,
            "paginator":[
                "nextPage": nextPageKey,
                "pageSize": limit,
                "pageNumber": 1,
                "totalPages" : 1,
                "previousPage" : 1]
            
        ] as [String : Any]
        viewModel.searchFeedListApiCallNoLoading(postDict: params)
    }
    
    ///View Model Setup with observing the value to the pagination and get the reload data of api call
    func setupViewModel(isCleared:Bool) {
        
        viewModel.homeBaseModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.refreshControl.endRefreshing()
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.homeBaseModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.refreshControl.endRefreshing()
                self.collectionView.bottomRefreshControl?.endRefreshing()
                
                SessionManager.sharedInstance.homeFeedsSwippedObject = nil
                SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
                
                if self.viewModel.feedListData.count > 0 {
                    
                    if self.viewModel.homeBaseModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.feedListData.count > 0 { //Loading
                        self.isAPICalled = true
                        self.noDataImg.isHidden = true
                        self.noDataLbl.isHidden = true
                        self.collectionView?.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            self.activityIndicator.startAnimating()
                            self.isLoading = false
                            //                            self.noMoreView.isHidden = true
                            self.collectionView?.reloadData()
                            //self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                            self.loadingData = false
                            //self.loadingPreviousData = false
                        }
                    }else { //No extra data available
                        self.isAPICalled = true
                        self.noDataImg.isHidden = true
                        self.noDataLbl.isHidden = true
                        self.collectionView?.isHidden = false
                        DispatchQueue.main.async {
                            
                            self.collectionView?.reloadData()
                    
                            self.loadingData = true
                            self.isLoading = false
                            //self.loadingPreviousData = true
                            //                            self.noMoreView.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }

                }else{
                    self.loadingData = true
                    self.isLoading = false
                    //                    self.noMoreView.isHidden = true
                    self.noDataImg.isHidden = false
                    self.noDataLbl.isHidden = false
                    self.collectionView?.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
            
            if isCleared == true{
                self.collectionView.setContentOffset(.zero, animated: false)
            }
            
        }
        
    }
    
    /// If post deleted use the remove method to remove the current cell and refresh
    func remove(_ i: Int) {

        viewModel.feedListData.remove(at: i)
        

        let indexPath = IndexPath(row: i, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
        self.collectionView.reloadItems(at: [indexPath])
        
//        self.collectionView.performBatchUpdates({
//            self.collectionView.deleteItems(at: [indexPath])
//        }) { (finished) in
//
//        }

    }
    
    
    ///Setup the home clap model to clap the post
    func setupHomeClapViewModel(indexPath:Int) {
        
        viewModel.homeClapModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.remove(indexPath)
                self.showErrorAlert(error: error.localizedDescription)
            }
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.homeClapModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.clapDataModel = value.data ?? [ClapData]()
                
                if self.clapDataModel.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.threadPopUpBgView.isHidden = false
                        self.threadPopUpDesclbl.text = "You have clapped \(self.clappedTagName) spark \nDo you want continue to create a Loop"
                    }
                }
            }
            
        }
        
    }
    
    /// Search button tapped to get the Search tag page to search the tags
    @IBAction func searchButtonTapped(sender:UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let searchVC = storyBoard.instantiateViewController(identifier: "SearchTagFeedViewController") as! SearchTagFeedViewController
        searchVC.delegate = self
        searchVC.SearchTag = selectedTag
        searchVC.tagId = selectedTagId
        searchVC.nft = nft
        searchVC.monetize = monetize
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    
}

//#MARK: Start Thread View Actions
extension FeedSearchViewController {
    
    /// It will hide the thread pop bg view
    @IBAction func mayBeLaterButtonTapped(sender:UIButton) {
        threadPopUpBgView.isHidden = true
    }
    
    /// Start thread button tapped to check the limit with post id and user id
    @IBAction func startThreadButtonTapped(sender:UIButton) {
        checkThreadLimitObserverForClapAndLoopCreation(indexPath: sender.tag)
        
        viewModel.checkThreadLimitAPICallForClapAndLoopRequest(postDict: ["threadpostId":self.viewModel.feedListData[selectedIndexPath].postId ?? "","threaduserId":self.viewModel.feedListData[selectedIndexPath].userId ?? ""])
    }
}



extension FeedSearchViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
extension UITabBarController{
    func setUpImagaOntabbar(_ selectedImage : [UIImage], _ image : [UIImage], _ title : [String]?){
        
        for (index,vals) in image.enumerated(){
            
            if let tab = self.tabBar.items?[index]{
                
                tab.image = image[index]
                tab.image = selectedImage[index]
                if let tile = title?[index]{
                    tab.title = title?[index]
                }
                
            }
        }
    }
}

extension FeedSearchViewController : selectedTagDelegate {
    /// Select the tag details with tag  searching and set the post type with tag name, monetize and nft
    /// - Set the tag width according to tag id
    /// - If monetize 1 and if country code is +91 set the rs symbol and apply dollar symbol
    func selectedTagDetails(tagId: String, tagName: String, postType:Int, monetize:Int, NFT:Int) {
        tagSelectedForSearch = true
        selectedTag = tagName
        selectedTagId = tagId
        debugPrint(selectedTag)
        //searchBar?.text = selectedTag
        self.monetize = monetize
        self.nft = NFT
        self.collectionView.reloadData()
        self.isLoading = true
        self.tagList.removeAllTags()
        self.setupViewModel(isCleared: false)
        self.viewModel.feedListData = []
        self.postType = postType
        self.tagArray.removeAll()
        
        if tagId == ""{
            self.tagViewWidth.constant = 0
        }
        else{
            self.tagViewWidth.constant = 70
        }
        if monetize == 1{
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                self.tagList.isHidden = false
                self.tagArray.append("₹")
            }
            else{
                self.tagList.isHidden = false
                self.tagArray.append("$")
            }
            
        }else{
            //self.tagArray.contains { element in
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                self.tagArray.removeAll { element in
                    element == "₹"
                }
            }
            else{
                self.tagArray.removeAll { element in
                    element == "$"
                }
            }
            //}
        }
        if NFT == 1{
            self.tagList.isHidden = false
            self.tagArray.append("NFT")
        }
        else{
            self.tagArray.removeAll { element in
                element == "NFT"
            }
        }
        if tagArray.count == 0{
            self.tagList.isHidden = true
        }
        if tagId != ""{
            self.tagView.isHidden = false
            self.SearchViewHeight.constant = 50
            self.tagViewLbl.text = tagName
        }
        else{
            self.tagView.isHidden = true
            self.SearchViewHeight.constant = 50
        }
        
        
        self.tagList.addTags(self.tagArray)
        
        if postType == 1{
            self.globalView.isHidden = false
            self.globalSelected()
        }
        else if postType == 2{
            self.globalView.isHidden = false
            self.localSelected()
        }
        else if postType == 3{
            self.globalView.isHidden = false
            self.socialSelected()
        }
        else if postType == 4{
            self.globalView.isHidden = false
            self.closedSelected()
        }
        
        getFeedList(text: selectedTag, tagId: selectedTagId)
    }
    
    
    // MARK: TagListViewDelegate
    ///Press the and set the title string with tag selected and tagview selected
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    
    ///Tag button removed  if NFT or Monetize and remove from array
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        if title == "NFT"{
            self.nft = 0
            self.isLoading = true
            self.scrollToIndex(index: 0)
            //self.collectionView.setContentOffset(.zero, animated: false)
        }
        else if title == "₹"{
            self.monetize = 0
            self.isLoading = true
            self.scrollToIndex(index: 0)
            //self.collectionView.setContentOffset(.zero, animated: false)
        }
        else if title == "$"{
            self.monetize = 0
            self.isLoading = true
            self.scrollToIndex(index: 0)
            //self.collectionView.setContentOffset(.zero, animated: false)
        }
        self.viewModel.feedListData = []
        self.getFeedList(text: selectedTag, tagId: selectedTagId)
        
        sender.removeTagView(tagView)
        //tagList.isHidden = true

        //apiCallForBubbleTagList(text: "", PageNumber: 1, PageSize: self.limit, isBoolForHandlingLoadMoreData: false)
        //collectionView?.reloadData()
        
    }
    
    
    /// Tag Close button used to close the tag button
    @IBAction func tagCLoseBtn(_ sender: Any) {
        self.selectedTagId = ""
        self.selectedTag = ""
        self.tagView.isHidden = true
        self.SearchViewHeight.constant = 50
        self.viewModel.feedListData = []
        if selectedTagId == ""{
            self.tagViewWidth.constant = 0
        }
        else{
            self.tagViewWidth.constant = 70
        }
        SessionManager.sharedInstance.saveUserTagDetails["tagName"] = ""
        SessionManager.sharedInstance.saveUserTagDetails["tagId"] = ""
        self.getFeedList(text: selectedTag, tagId: selectedTagId)
    }
    
    
    
    /// Tag clear button is used to clear all the tags and call the api
    @IBAction func tagClearBtn(_ sender: Any) {
        self.selectedTagId = ""
        self.selectedTag = ""
        SessionManager.sharedInstance.saveUserTagDetails["tagName"] = ""
        SessionManager.sharedInstance.saveUserTagDetails["tagId"] = ""
        self.SearchViewHeight.constant = 50
        self.viewModel.feedListData = []
        self.isLoading = true
        self.scrollToIndex(index: 0)
        self.getFeedList(text: selectedTag, tagId: selectedTagId)
    }
    
    
}

extension FeedSearchViewController : getPlayerVideoAudioIndexDelegate {
    
    /// Call view observer
    func callViewObserver(){
        viewModel.eyeShotModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            print(error)
            //self.refreshControl.endRefreshing()
        }
        viewModel.eyeShotModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
        }
    }
    
    
   
    ///Player full screen dismiss for player loading
    func videoPlayerFullScreenDismiss() {
        isPlayerFullScreenDismissed = false
        self.isNewLoading = true
    }
    
    /// get the playing video index with the view observer and call views
    func getPlayVideoIndex(index: Int) {
        debugPrint(index)
        playedVideoIndexPath = index
        self.callViewObserver()
        //print(sender)
        self.callViews(postId: self.viewModel.feedListData[index].postId ?? "")
        
    }
    
    
    func playViewed(sender: Int) {
        //print("Eyeshot")
        
    }
    
    func callAudioAnimation(isPlaying: Bool) {
        if isPlaying == true{
            
        }
        else{
            
        }
    }
    
}

extension FeedSearchViewController {
    
    ///Setup the poptip to show if bio is more
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

extension FeedSearchViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITextViewDelegate {
    
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
            return viewModel.feedListData.count
        }
        
        
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isLoading{
            let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MonetizeNewscardCollectionViewCell", for: indexPath) as! MonetizeNewscardCollectionViewCell
            cells.showDummy()
            return cells
        }
        else{
            let monetize = viewModel.feedListData[indexPath.item].monetize ?? 0
            
            if monetize == 1{
                
                let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MonetizeNewscardCollectionViewCell", for: indexPath)
                if let cell = cells as? MonetizeNewscardCollectionViewCell {
                    
                    if isLoading{
                        cell.showDummy()
                    }
                    else{
                        cell.hideDummy()
                        if self.viewModel.feedListData.count > 0 {
                            
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
                                cell.activityLoader.isHidden = true
                                
                                
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
                                cell.activityLoader.isHidden = true
                                cell.activityLoader.sendSubviewToBack(cell.contentBgImgView)
                            
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                print(fullMediaUrl)
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                cell.contentsImageView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                
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
                                cell.videoBgView.isUserInteractionEnabled = true
                                cell.audioAnimationBg.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.mediaType = 3
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].thumbNail ?? "")"
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.mediaUrl = self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.playOrPauseVideo(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
                                
                            case 4 ://Audio
                                
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                
                               
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                //cell.videoPlayBtn.isHidden = false
                                cell.videoBgView.tag = indexPath.item
                                cell.playBtn.tag = indexPath.item
                    
                          
                                cell.videoBgView.isUserInteractionEnabled = true
                                cell.audioAnimationBg.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.mediaType = 4
                                //cell.audioAnimationBg.contentMode = .scaleAspectFit
                              
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                               
                                cell.mediaUrl = fullMediaUrl
                                cell.AudioplayOrPauseVideo(url:fullMediaUrl, parent: self, play: false)//(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self)
                               
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
                                cell.activityLoader.isHidden = true
                                
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
                            cell.collectionDelegate = self
                            cell.tagBtn.tag = indexPath.item
                            cell.rightViewBtn.tag = indexPath.item
                            cell.leftViewBtn.tag = indexPath.item
                            cell.contentBgView.tag = indexPath.item
                            cell.profileBtn.tag = indexPath.item
                            cell.titleLabel.tag = indexPath.item
                            cell.currencySymbol.text = viewModel.feedListData[indexPath.item].currencySymbol ?? ""
                            let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.feedListData[indexPath.item].createdDate ?? 0)")
                            cell.dateLabel.text = convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
                            
                            if self.viewModel.feedListData[indexPath.item].mediaType != 1 {
                                cell.postContentLabel.text = viewModel.feedListData[indexPath.item].postContent
                                if viewModel.feedListData[indexPath.item].postContent?.isEmpty ?? false {
                                    cell.contentLblHeightConstraints.constant = 0
                                    
                                } else {
                                    let heightOfText = (viewModel.feedListData[indexPath.item].postContent)?.height(withConstrainedWidth: self.view.frame.size.width, font: UIFont.MontserratMedium(.large)) ?? CGFloat.init()
                                    
                                    cell.contentLblHeightConstraints.constant = heightOfText + 15
                                    
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
                            
                            cell.postTypeImgView.isHidden = false
                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                                cell.monetizeView.isHidden = false
                                cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                cell.monetizeView.isHidden = true
                                cell.contentView.addGestureRecognizer(cell.rightSwipe)
                                cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0
                            
                            let postType = self.viewModel.feedListData[indexPath.item].postType
                            
                            switch postType {
                            case 1:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "globalGray")
                            case 2:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "localGray")
                            case 3:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "SocialGray")
                            case 4:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "closedGray")
                            default:
                                break
                            }
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
                                cell.activityLoader.isHidden = true
                                
                                cell.txtView.delegate = self
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
                                cell.activityLoader.isHidden = true
                                cell.activityLoader.sendSubviewToBack(cell.contentBgImgView)
                            
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                print(fullMediaUrl)
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                cell.contentsImageView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                
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
                                cell.videoBgView.isUserInteractionEnabled = true
                                cell.audioAnimationBg.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.mediaType = 3
                                
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].thumbNail ?? "")"
                                cell.contentBgImgView.setImage(
                                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                                    placeholder: UIImage(named: "NoImage"))
                                cell.mediaUrl = self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                                cell.playOrPauseVideo(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
                                
                            case 4 ://Audio
                                
                                cell.delegate = self
                                cell.videoBgView.tag = indexPath.item
                                cell.bgViewForText.isHidden = true
                                cell.videoBgView.isHidden = false
                                cell.contentsImageView.isHidden = true
                                cell.contentBgImgView.isHidden = true
                                
                               
                                cell.contentBgImgView.contentMode = .scaleAspectFill
                                //cell.videoPlayBtn.isHidden = false
                                cell.videoBgView.tag = indexPath.item
                    
                          
                                cell.videoBgView.isUserInteractionEnabled = true
                                cell.audioAnimationBg.isHidden = true
                                cell.activityLoader.isHidden = true
                                cell.mediaType = 4
                                //cell.audioAnimationBg.contentMode = .scaleAspectFit
                              
                                
                                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
                                let isNft = self.viewModel.feedListData[indexPath.item].nft ?? 0
                                if isNft == 0{
                                    cell.nftImage.isHidden = true
                                }
                                else{
                                    cell.nftImage.isHidden = false
                                }
                               
                                cell.mediaUrl = fullMediaUrl
                                cell.AudioplayOrPauseVideo(url:fullMediaUrl, parent: self, play: false)//(url: self.viewModel.feedListData[indexPath.item].mediaUrl ?? "", parent: self)
                               
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
                                cell.activityLoader.isHidden = true
                                
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
                            cell.collectionDelegate = self
                            cell.tagBtn.tag = indexPath.item
                            cell.rightViewBtn.tag = indexPath.item
                            cell.leftViewBtn.tag = indexPath.item
                            cell.contentBgView.tag = indexPath.item
                            cell.profileBtn.tag = indexPath.item
                            cell.titleLabel.tag = indexPath.item
                            cell.currencySymbol.text = viewModel.feedListData[indexPath.item].currencySymbol ?? ""
                            let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.feedListData[indexPath.item].createdDate ?? 0)")
                            cell.dateLabel.text = convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
                            
                            if self.viewModel.feedListData[indexPath.item].mediaType != 1 {
                                cell.postContentLabel.text = viewModel.feedListData[indexPath.item].postContent
                                if viewModel.feedListData[indexPath.item].postContent?.isEmpty ?? false {
                                    cell.contentLblHeightConstraints.constant = 0
                                    
                                } else {
                                    let heightOfText = (viewModel.feedListData[indexPath.item].postContent)?.height(withConstrainedWidth: self.view.frame.size.width, font: UIFont.MontserratMedium(.large)) ?? CGFloat.init()
                                    
                                    cell.contentLblHeightConstraints.constant = heightOfText + 15
                                    
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
                            
                            cell.postTypeImgView.isHidden = false
                            
                            if viewModel.feedListData[indexPath.item].monetize ?? 0 == 1{
                                cell.monetizeView.isHidden = false
                                cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            else{
                                cell.monetizeView.isHidden = true
                                cell.contentView.addGestureRecognizer(cell.rightSwipe)
                                cell.contentView.addGestureRecognizer(cell.leftSwipe)
                            }
                            cell.monetize = viewModel.feedListData[indexPath.row].monetize ?? 0
                            
                            let postType = self.viewModel.feedListData[indexPath.item].postType
                            
                            switch postType {
                            case 1:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "globalGray")
                            case 2:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "localGray")
                            case 3:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "SocialGray")
                            case 4:
                                cell.postTypeImgView.image = #imageLiteral(resourceName: "closedGray")
                            default:
                                break
                            }
                        }
                    }
                    
                    return cell
                }
            }
            
        }
        
        
        
        
        return UICollectionViewCell.init()
    }
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        let lastElement = viewModel.feedListData.count - 1
        if indexPath.item == lastElement {
            self.noMoreView.isHidden = false
            loadMoreData()
        }
    }
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.viewModel.feedListData.count > 0 {
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.item].mediaUrl ?? "")"
            
            
            if self.viewModel.feedListData[indexPath.item].mediaType == 2 {
                
                let isViewed = self.viewModel.feedListData[indexPath.item].isViewed ?? false
                
                if isViewed == false{
                    self.viewModel.feedListData[indexPath.item].isViewed = true
                    self.callViews(postId: self.viewModel.feedListData[indexPath.item].postId ?? "")
                }
                
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
                vc.url = fullMediaUrl
                vc.modalPresentationStyle = .popover
                //self.isPlayerFullScreenDismissed = false
                vc.delegate = self
                navigationController?.present(vc, animated: true, completion: nil)
//                let imageInfo   = GSImageInfo(image: UIImage(), imageMode: .aspectFit, imageHD: URL(string: fullMediaUrl))
//                let imageViewer = GSImageViewerController(imageInfo: imageInfo)
//                imageViewer.backgroundColor = UIColor.black
//                //self.navigationController?.setNavigationBarHidden(false, animated: true)
//                imageViewer.navigationItem.title = self.viewModel.feedListData[indexPath.item].allowAnonymous == true ? "Anonymous User's Spark Image" : "\(self.viewModel.feedListData[indexPath.item].profileName ?? "")'s Spark Image"
//               // navigationController?.navigationBar.barTintColor = UIColor.white
//                SessionManager.sharedInstance.isImageFullViewed = true
//                if #available(iOS 14.0, *) {
//                    imageViewer.navigationItem.backButtonDisplayMode = .minimal
//                } else {
//                    // Fallback on earlier versions
//                }
////                imageViewer.dismissCompletion = {
////                    self.navigationController?.setNavigationBarHidden(true, animated: true)
////                }
//                navigationController?.present(imageViewer, animated: true, completion: nil)
            }
            else if self.viewModel.feedListData[indexPath.item].mediaType == 5
            {
                DispatchQueue.main.async {
                    RSLoadingView().showOnKeyWindow()
                }
                let isViewed = self.viewModel.feedListData[indexPath.item].isViewed ?? false
                
                
                if isViewed == false{
                    self.viewModel.feedListData[indexPath.item].isViewed = true
                    self.callViews(postId: self.viewModel.feedListData[indexPath.item].postId ?? "")
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
                    docVC.url = fullMediaUrl
                    self.present(docVC, animated: true, completion: nil)
                }
               
            }
        }
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
    
    /// Scroll view did scroll offset will change
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            print("Move Up")
            for cell in collectionView.visibleCells {
                let indexPath = collectionView.indexPath(for: cell)
                print(indexPath)
                
                if viewModel.feedListData.count > 0{
                    let monetize = viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0
                    if monetize == 1{
                        let cell = collectionView?.cellForItem(at: indexPath ?? IndexPath()) as? MonetizeNewscardCollectionViewCell
                        
                        //cell?.audioAnimationBg.stopAnimatingGif()
                        cell?.avplayer?.pause()
                        cell?.playerController?.player?.pause()
                        
                    }
                    else{
                        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                        
                        //cell?.audioAnimationBg.stopAnimatingGif()
                        cell?.avplayer?.pause()
                        cell?.playerController?.player?.pause()
                    }
                }
            }
            
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            print("Move Down")
            for cell in collectionView.visibleCells {
                let indexPath = collectionView.indexPath(for: cell)
                print(indexPath)
                if viewModel.feedListData.count > 0{
                    let monetize = viewModel.feedListData[indexPath?.item ?? 0].monetize ?? 0
                    if monetize == 1{
                        let cell = collectionView?.cellForItem(at: indexPath ?? IndexPath()) as? MonetizeNewscardCollectionViewCell
                        
                        //cell?.audioAnimationBg.stopAnimatingGif()
                        cell?.avplayer?.pause()
                        cell?.playerController?.player?.pause()
                        
                    }
                    else{
                        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
                        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
                        
                        //cell?.audioAnimationBg.stopAnimatingGif()
                        cell?.avplayer?.pause()
                        cell?.playerController?.player?.pause()
                    }
                }
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
    
    
}

extension FeedSearchViewController : collectionDelegate {
    
    /// On pressing the name label  profile button open the other user profile page
    func profileButtonSelection(sender: Int) {
        if viewModel.feedListData[sender].allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = viewModel.feedListData[sender].userId ?? ""
            connectionListVC.backDelegate = self
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    
    /// Get the post detail observer to open the feed detail page
    func GetPostDetailsObserver(indexPath: Int) {
        
        viewModel.GetPostDetailsModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.remove(indexPath)
            }
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.GetPostDetailsModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                if value.data?.status == 2{
                    self.remove(indexPath)
                }
                else{
                    if self.viewModel.feedListData.count > 0 {
                        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                        detailVC.postId = value.data?.postId ?? ""
                        detailVC.threadId = value.data?.threadId ?? ""
                        SessionManager.sharedInstance.threadId = value.data?.threadId ?? ""
                        
                        detailVC.myPostId = value.data?.postId ?? ""
                        detailVC.myThreadId = value.data?.threadId ?? ""
                        
                        detailVC.tagId = self.selectedTagId
                        detailVC.tag_Name = self.selectedTag
                        detailVC.postype = self.postType
                        
                        detailVC.isFromBubble = false
                        detailVC.isFromHomePage = true
                        detailVC.delegate = self
                        detailVC.backDelegate = self
                        detailVC.getSearchItemDelegate = self
                        SessionManager.sharedInstance.selectedIndexTabbar = 1
                        //NotificationCenter.default.post(name: Notification.Name("detailToCreatePostBackButton"), object: ["index":0])
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                

                
            }
        }
        
    }
    
    /// Content view selected will tap to get the post detail observer with the view model
    func contentViewDidSelect(sender: Int) {
        
        let detailsDict = [
            "postId": self.viewModel.feedListData[sender].postId ?? ""
        ]
        GetPostDetailsObserver(indexPath: sender)
        viewModel.getPostDetailsById(postDict: detailsDict)
        
        
    }
    
    /// Home view used to open the over lay view to check the viewed membres
    func homeView(sender: UIButton) {
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
    
    /// Show the list users when pressed on the clap count
    func homeClap(sender: UIButton) {
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
    
    
    /// Tag button tapped to open the tag view with the list
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
    
    /// Tip View button tapped to show the pop tip tag
    @objc func tipViewButtonTapped(sender:UIButton){
        debugPrint("Tip button Tapped")
        SessionManager.sharedInstance.saveUserTagDetails = ["tagId": self.viewModel.feedListData[sender.tag].tagId ?? "","tagName": self.viewModel.feedListData[sender.tag].tagName ?? ""]
        debugPrint(SessionManager.sharedInstance.saveUserTagDetails)
        self.tabBarController?.selectedIndex = 1
    }
    
    ///  Left button used to check the thread limit and check for repost
    func leftButtonDetailsTapped(sender: UIButton) {
        
        self.checkThreadLimitObserver(indexPath: sender.tag)
        
        self.repostSwippedDataIndexPath = sender.tag
        
        self.viewModel.checkThreadLimitAPICall(postDict: ["threadpostId":self.viewModel.feedListData[sender.tag].postId ?? "","threaduserId":self.viewModel.feedListData[sender.tag].userId ?? ""])
    }
    
    
    /// right button tapped to clap the post
    func rightButtonDetailsTapped(sender: UIButton) {
        
        if !(self.viewModel.feedListData[sender.tag].isClap ?? false) {
            self.trailingBoolForSwipe = true
            self.selectedIndexPath = sender.tag
            var isBubble = false
            if viewModel.feedListData[sender.tag].monetize ?? 0 == 1{
               isBubble = true
            }
            else{
                isBubble = false
            }
            
            let clapDict = ["postId": self.viewModel.feedListData[sender.tag].postId ?? "","isClap": false,"isBubble":isBubble,"postType":self.viewModel.feedListData[sender.tag].postType ?? 0,"threadId":self.viewModel.feedListData[sender.tag].threadId ?? ""] as [String : Any]
            
            self.setupHomeClapViewModel(indexPath: sender.tag)
            
            self.viewModel.homeClapApiCall(postDict: clapDict as [String : Any])
            
            self.viewModel.feedListData[sender.tag].clapCount = ((self.viewModel.feedListData[sender.tag].clapCount ?? 0) + 1)
            
            self.viewModel.feedListData[sender.tag].isClap = true
            
            self.clappedTagName = self.viewModel.feedListData[sender.tag].tagName ?? ""
            
            self.threadpostId = self.viewModel.feedListData[sender.tag].postId ?? ""
            self.threaduserId = self.viewModel.feedListData[sender.tag].userId ?? ""
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        
    }
    
    ///Call the api with post id and set the api call
    func callViews(postId:String){
        let params = ["postId":postId] as! [String : Any]
        self.viewModel.viewedApiCallNoLoading(postDict: params)
    }
    
}


//extension FeedSearchViewController : UISearchBarDelegate{
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
//        let searchVC = storyBoard.instantiateViewController(identifier: "SearchTagFeedViewController") as! SearchTagFeedViewController
//        searchVC.delegate = self
//        searchVC.isFromSearch = true
//
//       // searchVC.modalPresentationStyle = .fullScreen
//        self.present(searchVC, animated: true, completion: nil)
//           //self.present(UINavigationController(rootViewController: SearchViewController()), animated: false, completion: nil)
//       }
//
//   
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        //self.searchBar?.text = ""
//        selectedTagId = ""
//        //self.searchBar?.setShowsCancelButton(false, animated: true)
//        self.collectionView.reloadData()
//        self.isLoading = true
//        setupViewModel()
//        viewModel.feedListData = []
//
//        getFeedList(text: "", tagId: "")
//
//    }
//}
