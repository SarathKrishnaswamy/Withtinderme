//
//  CreatePostViewController.swift
//  Spark
//
//  Created by adhash on 29/06/21.
//

import UIKit
import RAMAnimatedTabBarController
import CoreLocation
import AVFoundation
import Photos
import MobileCoreServices
import SafariServices
import LRSpotlight
import LabelSwitch
import Kingfisher
import DTGradientButton
import MessageUI


protocol FromProfileDelegate{
    func fromMonetize()
}

/**
 This class helps  user to post  own Audio, Video, Image, Document and Text
 */
class CreatePostViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate, UITextViewDelegate,getSelectedClosedConnectionList,LabelSwitchDelegate,backtoMultipostDelegate, MFMailComposeViewControllerDelegate, FromProfileDelegate {
    func back() {
        //self.backtoMultiPost?.back()
        SessionManager.sharedInstance.selectedIndexTabbar = 1
        self.navigationController?.popViewController(animated: true)
        self.backSearchDelegate?.backSearch()
    }
    
    
    func closedConnectionList(friendsList: [String]) {
        closedConnectionArrayList = friendsList
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        questionCell?.threadLimitTxtFld.isUserInteractionEnabled = false
        questionCell?.threadLimitTxtFld.text = "\(closedConnectionArrayList.count)"
    }
    
    @IBOutlet weak var footerView:UIView?
    @IBOutlet weak var tableView:UITableView?
    
    //Media Upload View
    @IBOutlet weak var fromCameraView:UIView?
    @IBOutlet weak var fromGalleryView:UIView?
    @IBOutlet weak var audioView:UIView?
    @IBOutlet weak var attachmentView:UIView?
    
    
    @IBOutlet weak var createSparkLbl: UILabel!
    
    
    
    let viewModel = CreatePostViewModel()
    
    var selectedButton: UIButton? = nil
    
    var selectedTxtViewBool = Bool()
    
    var toolbarBottomConstraint: NSLayoutConstraint?
    
    var locationManager = CLLocationManager()
    
    var latLong = [String:Any]()
    
    var isAnonymousUserOn = false
    
    var nftSpark = Int()
    
    var postType = 1
    
    var colorPickerViewFrame: CGFloat?
    
    var isFromLoopRepost = false
    
    @IBOutlet weak var colorPickerCollectionView:UICollectionView?
    
    @IBOutlet weak var colorPickerBgView:UIView?
    
    @IBOutlet weak var alertView: UIView!
    
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var okayBtn: UIButton!
    
    var settingViewModel = LoginViewModel()
    
    var selectedColor = ""
    
    var selectedTxtColor = ""
    
    var audioDocumentStr = ""
    
    var closedConnectionArrayList = [String]()
    
    var HomeFeedsArray:HomeFeeds?
    
    var typedQuestionDict = [String:Any]()
    
    var isFromAttachmentToEdit = false
    
    var nodess = [SpotlightNode]()
    
    var attachmentViewModel = AttachmentViewModel()
    
    var nftParam = Int()
    
    var monetizeParam = Int()
    
    var isMonetize = 0
    
    var currenyCode = ""
    
    var currencySymbol = ""
    
    var FromLoopMonetize = 0
    
    var multiplePost = 0
    
    var repostId = ""
    
    var monetizeBuyNow = 0
    
    var backtoMultiPost : backtoMultipostDelegate?
    
    var backSearchDelegate : backtoSearchDelegate?
    
    var isAgree = 0
    
    
    
    func fromMonetize() {
        self.setupNftViewModel()
        self.attachmentViewModel.createNftPostApiCall()
    }
    
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    /// - View adjustment handled while we typing more text lines
    /// - Audio, Video, Doc, Image maximum size handled for NFT Post based on settings api value- mediaMax
    /// - suppose if user having monetize post option means we should follow two main things
    /// - i) User didn't fill basic information or
    /// - ii) User didn't fill payout information for monetize post we are showing KYC alert to user
    /// - Run time permission checks for all media attachments like Audio,Video,Image,Document
    /// - if flag- repostId- not empty - Repost Scenario  isRepost = true else false
    /// - if flag- repostId- not empty - Repost Scenario  isRepost = true & if flag mPostTypeId==4 means closed user post- disable textViewUserCount and Switch anonymous button
    /// - if flag- repostId- not empty & flag - multiplePost == 1 & flag-FromLoopMonetize == 3 - comes under repost-isRepost=true & multiple post upload functionality - so we need to hidden some unwanted views (ie) constraintParentView
    /// - if flag - mSparkId- not empty & flag- monetizePostBuyNow==2 - comes under repost functionality-isRepost=true but need to disable anonymous user and monetize switch
    /// - getNFTById api called based on this response we have shown nft and monetize post switch to user
   
    override func viewWillAppear(_ animated: Bool) {
        
        self.isMonetize = 0
        self.nftSpark = 0
        isAnonymousUserOn = false
        self.alertView.isHidden = true
        
        if FromLoopMonetize == 1 && multiplePost == 1{
            self.createSparkLbl.text = "Edit your Spark"
            let indexPath = IndexPath(row: 0, section: 0)
            let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
            questionCell?.topHeightConstraint.constant = 0
            
            self.tableView?.reloadData()
        }
        else if FromLoopMonetize == 2 && multiplePost == 0{
            let indexPath = IndexPath(row: 0, section: 0)
            let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
            questionCell?.topHeightConstraint.constant = 140
            questionCell?.switchView.isHidden = true
            questionCell?.anonymousImage.isHidden = true
            questionCell?.monetizeSwitch.isHidden = true
            tableView?.rowHeight = UITableView.automaticDimension
            tableView?.estimatedRowHeight = 100
            self.tableView?.reloadData()
        }
        else{
            self.createSparkLbl.text = "Create your Spark"
            //self.setupCreatePostViewModel()
           self.setupNftViewModel()
            self.attachmentViewModel.createNftPostApiCall()
            
            if SessionManager.sharedInstance.isSkip{
                
                self.alertView.isHidden = false
                self.cancelBtn.layer.borderColor = UIColor.splashStartColor.cgColor
                self.cancelBtn.setTitleColor(UIColor.splashStartColor, for: .normal)
                self.cancelBtn.layer.cornerRadius = 6.0
                self.cancelBtn.layer.borderWidth = 1.0
                
                self.okayBtn.layer.cornerRadius = 6.0
                self.okayBtn.layer.masksToBounds = true
                self.okayBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
                
            }
            else{
                self.tabBarController?.tabBar.isHidden = true
                
                NotificationCenter.default.addObserver(self, selector: #selector(moveToHomePage), name: Notification.Name("UploadCompleted"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(stayInCreatePost), name: Notification.Name("popToCreatePost"), object: nil)
                
//                NotificationCenter.default.addObserver(self, selector: #selector(repostUploadCancelled), name: Notification.Name("RepostUploadCancelled"), object: nil)
               // NotificationCenter.default.addObserver(self, selector: #selector(pushRedirectionFCM(notification:)), name: Notification.Name("PushRedirectionFCM"), object: nil)
                
                let indexPath = IndexPath(row: 0, section: 0)
                let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
                questionCell?.topHeightConstraint.constant = 140
                //questionCell?.txtView?.text = "Tell your thoughts that create Sparks"
                questionCell?.threadLimitTxtFld.text = "\(SessionManager.sharedInstance.settingData?.data?.minThreadLimit ?? 0)"
                //questionCell?.txtViewImgView.isHidden = false
                questionCell?.txtView?.delegate = self
                questionCell?.txtView?.textContainer.maximumNumberOfLines = 4
                questionCell?.txtView?.textContainer.lineBreakMode = .byTruncatingTail
                questionCell?.LblCountTextView.text  = "\(0)/180"
                
                tableView?.rowHeight = UITableView.automaticDimension
                tableView?.estimatedRowHeight = 100
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
            
            
            
           
        }
        
        
        
        
        
        
        
        
     
        
    }
    
    
    
    ///Once we click the push notification it will redirect to open the post detail page.
    @objc func pushRedirectionFCM(notification:NSNotification) {
        
        let postId = "\((notification.object as? [String:Any])?["postId"] as? String ?? "")"
        let threadId = "\((notification.object as? [String:Any])?["threadId"] as? String ?? "")"
        let userId = "\((notification.object as? [String:Any])?["userId"] as? String ?? "")"
        let notifyType = "\((notification.object as? [String:Any])?["typeOfnotify"] as? String ?? "")"
        
        if notifyType == "1" || notifyType == "2" || notifyType == "3" {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
            detailVC.notificationPostId = postId
            detailVC.threadId = threadId
            detailVC.userId = userId
            SessionManager.sharedInstance.threadId = threadId
            detailVC.isFromBubble = false
            detailVC.isFromHomePage = false
            detailVC.isFromNotificationPage = true
            detailVC.postType = self.postType
            //detailVC.delegate = self
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            
            self.navigationController?.pushViewController(detailVC, animated: true)
            
        }else if notifyType == "5" || notifyType == "6" { //Approval and Reveal request
            
            NotificationCenter.default.post(name: Notification.Name("SelectNotificationTabBar"), object: nil)
            
            self.tabBarController?.tabBar.isHidden = false
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PushRedirectionFCM"), object: nil)
        
    }
    
    /// Adjust the textsize to vertically center
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    
//    @objc func repostUploadCancelled() {
//        //Nil after repost success
//        //        SessionManager.sharedInstance.homeFeedsSwippedObject = nil
//        //        SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
//
//    }
    
    /// Dismiss and move to home page from create post page
    @objc func moveToHomePage() {
        
        self.tabBarController?.selectedIndex = 0
        typedQuestionDict = [:]
        isAnonymousUserOn = false
        //Nil after repost success
        SessionManager.sharedInstance.homeFeedsSwippedObject = nil
        SessionManager.sharedInstance.getTagNameFromFeedDetails = nil
        
        //Dismiss Audio Model VC
        self.dismiss(animated: true, completion: nil)
    }
    
    ///Stay  in create post when it is back from attachment page.
    @objc func stayInCreatePost() {
        
        self.tabBarController?.selectedIndex = 2
        
        isFromAttachmentToEdit = true
        
        isAnonymousUserOn = typedQuestionDict["allowAnonymous"] as? Bool ?? false
        
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
        
    }
    
    /// Cancel button on pressed the alert will be hidden and it will check with the selected tab bar
    @IBAction func cancelBtnOnPressed(_ sender: Any) {
        self.alertView.isHidden = true
        UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
        NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
    }
    
    
    /// If Okay button on Pressed it will redirect to open the edit profile page.
    @IBAction func okayBtnOnPressed(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let editProfileVC = storyBoard.instantiateViewController(identifier: EDIT_BIO_STORYBOARD) as! EditProfileTableViewController
        editProfileVC.isFromProfile = false
        editProfileVC.isFromCreatePost = false
        editProfileVC.isSkipped = true
        editProfileVC.fromEditProfile = self
        editProfileVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    /// - It will empty all the NFT property value
    /// - Keyboard rise up and keyboard close have some notification
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNftViewModel()
        self.attachmentViewModel.createNftPostApiCall()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        fromGalleryView?.dropShadow()
        fromCameraView?.dropShadow()
        attachmentView?.dropShadow()
        audioView?.dropShadow()
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
        
        let charPro0 = UserDefaults.standard.string(forKey: "charPro0") ?? ""
        print(charPro0)
        DispatchQueue.main.async {
            
            self.tableView?.reloadData()
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
        
    }
    
    
    
    ///Location manager delegate to set the coordintes of latitute and longitude
    /// - Parameters:
    ///     - manager: CLLocationManager to detect the current location
    ///     - locations: Array of CLLocation to set the latitude and longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        latLong = ["lat":locValue.latitude,"long":locValue.longitude]
        locationManager.stopUpdatingLocation()
    }
    
    ///View Model Setup
    /// Here it will navigate to home page  when its discarded
    func setupCreatePostViewModel() {
        
        viewModel.createPostModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.createPostModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
    }
    
    ///Set the nft view model and observe the values and set the cancel button
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
            self.isAgree = value.nftData?.isAgree ?? 0
            SessionManager.sharedInstance.isSkip = value.nftData?.isSkip ?? false
            DispatchQueue.main.async {

                if SessionManager.sharedInstance.isSkip{
                    
                    self.alertView.isHidden = false
                    self.cancelBtn.layer.borderColor = UIColor.splashStartColor.cgColor
                    self.cancelBtn.setTitleColor(UIColor.splashStartColor, for: .normal)
                    self.cancelBtn.layer.cornerRadius = 6.0
                    self.cancelBtn.layer.borderWidth = 1.0
                    
                    self.okayBtn.layer.cornerRadius = 6.0
                    self.okayBtn.layer.masksToBounds = true
                    self.okayBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
                    
                }
                else{
                    self.alertView.isHidden = true
                }

            }
            
        }
    
    }
    
    
    /// Save button tapped to redirect next page
    ///  - Validate the set of items selected or the text field is typed or not
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        //Moving placeholder
        if questionCell?.txtView?.text == "Tell your thought that create Spark" {
            //questionCell?.txtView?.contentInset = UIEdgeInsets(top: 0.0,left: 0.0,bottom: 0,right: 0.0)
            //questionCell?.txtViewImgView.isHidden = false
        }
        
        guard let textValue = questionCell?.txtView?.text, textValue != "Tell your thought that create Spark" else {
            self.showErrorAlert(error: "Add your thoughts to create Spark")
            //questionCell?.txtView?.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        let text = questionCell?.txtView?.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if questionCell?.txtView?.text?.count ?? 0 >= 1 && text?.isEmpty ?? false {
            
            self.showErrorAlert(error: "Add your thoughts to create spark")
            self.view.endEditing(true)
            return
        }
        
  
        if questionCell?.threadLimitTxtFld?.text == "0" {
            //self.showErrorAlert(error: "Kindly choose at least one closed connection")
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        guard let threadMemberLimtValue = questionCell?.threadLimitTxtFld?.text, Int(threadMemberLimtValue) ?? 0 > 0 else {
            self.showErrorAlert(error: "Kindly input loop members limit")
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        if nftSpark == 1 && isMonetize == 1{
            self.showErrorAlert(error: "Spark text's don't support NFT/Monetize")
            //questionCell?.nftSwitch.isEnable = false
            questionCell?.nftSwitch?.curState = .L
            questionCell?.monetizeSwitch.curState = .L
            questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = true
            nftSpark = 0
            isMonetize = 0
        }
        else if nftSpark == 1{
            self.showErrorAlert(error: "Spark text's don't support NFT")
            //questionCell?.nftSwitch.isEnable = false
            questionCell?.nftSwitch?.curState = .L
            nftSpark = 0
        }
        else if isMonetize == 1{
            self.showErrorAlert(error: "Spark text doesn't support monetize")
            //questionCell?.nftSwitch.isEnable = false
            questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = true
            questionCell?.monetizeSwitch?.curState = .L
            isMonetize = 0
        }
        else{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
            typedQuestionDict = ["mediaType":MediaType.Text.rawValue,"bgColor":selectedColor,"textColor":selectedTxtColor,"textViewValue":textValue,"threadLimit":threadMemberLimtValue,"allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 2 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
            editImageVC.typedQuestionDict = typedQuestionDict
            editImageVC.FromLoopMonetize = self.FromLoopMonetize
            editImageVC.multiplePost = self.multiplePost
            editImageVC.repostId = repostId
            editImageVC.backtoMultipostDelegate = self
            //self.navigationController?.pushViewController(editImageVC, animated: false)
            self.present(editImageVC, animated: true, completion: nil)
        }
        
       
        
    }
    
    /// Create post api call for text
    /// - Parameter dict: Set the dictionary as params to send as view model
    func createPostApiCallForText(dict:[String:Any]) {
        
        viewModel.createPostApiCall(postDict: dict)
    }
    
    /// DImiss the keyboard for when we cliched on textview
    @objc override func dismissKeyboard() {
        view.endEditing(true)
        self.view.frame.origin.y = 0
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        if questionCell?.txtView?.text == "Tell your thought that create Spark" {
            //questionCell?.txtView?.contentInset = UIEdgeInsets(top: 0.0,left: 0.0,bottom: 0,right: 0.0)
            //questionCell?.txtViewImgView.isHidden = false
        }
        
    }
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let questionCell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as? inputCell
        
        
        if SessionManager.sharedInstance.isMonetize == 0{
            questionCell?.monetizeSwitch.isHidden = true
        }
        else{
            questionCell?.monetizeSwitch.isHidden = false
        }
        
        if SessionManager.sharedInstance.isRepost{
            
            questionCell?.monetizeSwitch.isHidden = true
        }
        
        
        if FromLoopMonetize == 1 && multiplePost == 1{
            questionCell?.topHeightConstraint.constant = 0
            questionCell?.textViewBgViewHeightConstraints.constant = 700//questionCell?.bgView.frame.height ?? CGFloat()
        }
        
        else if FromLoopMonetize == 2 && multiplePost == 0{
            self.monetizeParam = 0
            questionCell?.anonymousImage.isHidden = true
            questionCell?.switchView.isHidden = true
            questionCell?.monetizeSwitch.isHidden = true
            switch UIDevice.current.screenType {

            case .iPhone_XR_11:
                questionCell?.textViewBgViewHeightConstraints.constant = 500

            case .iPhone_11Pro:
                break

            case .iPhone_12Mini:
                break

            case .iPhone_12ProMax:
                questionCell?.textViewBgViewHeightConstraints.constant = 530

            case .iPhone_12_12Pro:
                break

            case .iPhones_6_6s_7_8:
                questionCell?.textViewBgViewHeightConstraints.constant = 320

            case .iPhones_5_5s_5c_SE:
                questionCell?.textViewBgViewHeightConstraints.constant = 320

            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                break

            default:
                break
            }
        }
        
        else{
            questionCell?.topHeightConstraint.constant = 140
            switch UIDevice.current.screenType {

            case .iPhone_XR_11:
                questionCell?.textViewBgViewHeightConstraints.constant = 500

            case .iPhone_11Pro:
                break

            case .iPhone_12Mini:
                break

            case .iPhone_12ProMax:
                questionCell?.textViewBgViewHeightConstraints.constant = 530

            case .iPhone_12_12Pro:
                break

            case .iPhones_6_6s_7_8:
                questionCell?.textViewBgViewHeightConstraints.constant = 320

            case .iPhones_5_5s_5c_SE:
                questionCell?.textViewBgViewHeightConstraints.constant = 320

            case .iPhones_6Plus_6sPlus_7Plus_8Plus:
                break

            default:
                break
            }
        }
        //else{
            
            //
            //questionCell?.anonymousUserSwitch?.transform = CGAffineTransform(scaleX: 1, y: 1)
             let profilePic = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] ?? "")"
             questionCell?.profileImgView?.setImage(
                 url: URL.init(string: profilePic) ?? URL(fileURLWithPath: ""),
                 placeholder: #imageLiteral(resourceName: SessionManager.sharedInstance.saveGender == 1 ?  "no_profile_image_male" : SessionManager.sharedInstance.saveGender == 2 ? "no_profile_image_female" : "others"))
     //        questionCell?.txtView?.textContainer.maximumNumberOfLines = 4
     //        questionCell?.txtView?.textContainer.lineBreakMode = .byWordWrapping
             questionCell?.profileImgView?.layer.cornerRadius = 5.0
                    
           
             
             
             questionCell?.nameLbl?.text = "\(SessionManager.sharedInstance.saveUserDetails["currentUsername"] ?? "")"
             questionCell?.threadLimitTxtFld.isUserInteractionEnabled = true

             questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[0].desc
             
             postType = Int(SessionManager.sharedInstance.settingData?.data?.postType?[0].id ?? "") ?? 0
             resetBtn()
             if SessionManager.sharedInstance.settingData?.data?.postType?[0].id == "1" {
                 
                 questionCell?.globalBtn?.isHidden = false
                 questionCell?.globalBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8391417861, green: 0.8392631412, blue: 0.8391152024, alpha: 1)
                 questionCell?.globalBtn?.layer.borderWidth = 0.5
                 questionCell?.globalBtn?.layer.cornerRadius = 6
                 questionCell?.globalBtn?.setTitleColor(#colorLiteral(red: 0.5390875936, green: 0.5287923813, blue: 0.5464160442, alpha: 1), for: .normal)
                 questionCell?.globalBtn?.setTitle(SessionManager.sharedInstance.settingData?.data?.postType?[0].name, for: .normal)
                 questionCell?.globalBtn?.tag = 0
                 questionCell?.globalBtn?.addTarget(self, action: #selector(postCategorySelectionTapped(sender:)), for: .touchUpInside)
                 
                 
             } else {
                 questionCell?.globalBtn?.isHidden = true
             }
             if SessionManager.sharedInstance.settingData?.data?.postType?[1].id == "2" {
                 questionCell?.localBtn?.isHidden = false
                 questionCell?.localBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.localBtn?.layer.borderColor = #colorLiteral(red: 0.8391417861, green: 0.8392631412, blue: 0.8391152024, alpha: 1)
                 questionCell?.localBtn?.layer.borderWidth = 0.5
                 questionCell?.localBtn?.layer.cornerRadius = 6
                 questionCell?.localBtn?.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                 questionCell?.localBtn?.setTitle(SessionManager.sharedInstance.settingData?.data?.postType?[1].name, for: .normal)
                 questionCell?.localBtn?.tag = 1
                 questionCell?.localBtn?.addTarget(self, action: #selector(postCategorySelectionTapped(sender:)), for: .touchUpInside)
                 
             } else {
                 questionCell?.localBtn?.isHidden = true
             }
             if SessionManager.sharedInstance.settingData?.data?.postType?[2].id == "3" {
                 questionCell?.socialBtn?.isHidden = false
                 questionCell?.socialBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.socialBtn?.layer.borderColor = #colorLiteral(red: 0.8391417861, green: 0.8392631412, blue: 0.8391152024, alpha: 1)
                 questionCell?.socialBtn?.layer.borderWidth = 0.5
                 questionCell?.socialBtn?.layer.cornerRadius = 6
                 questionCell?.socialBtn?.setTitleColor(#colorLiteral(red: 0.5390875936, green: 0.5287923813, blue: 0.5464160442, alpha: 1), for: .normal)
                 questionCell?.socialBtn?.setTitle(SessionManager.sharedInstance.settingData?.data?.postType?[2].name, for: .normal)
                 questionCell?.socialBtn?.tag = 2
                 questionCell?.socialBtn?.addTarget(self, action: #selector(postCategorySelectionTapped(sender:)), for: .touchUpInside)
                 
                 
             } else {
                 questionCell?.socialBtn?.isHidden = true
             }
             if SessionManager.sharedInstance.settingData?.data?.postType?[3].id == "4" {
                 questionCell?.cloasedBtn?.isHidden = false
                 questionCell?.cloasedBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.cloasedBtn?.layer.borderColor = #colorLiteral(red: 0.8391417861, green: 0.8392631412, blue: 0.8391152024, alpha: 1)
                 questionCell?.cloasedBtn?.layer.borderWidth = 0.5
                 questionCell?.cloasedBtn?.layer.cornerRadius = 6
                 questionCell?.cloasedBtn?.setTitleColor(#colorLiteral(red: 0.5390875936, green: 0.5287923813, blue: 0.5464160442, alpha: 1), for: .normal)
                 questionCell?.cloasedBtn?.setTitle(SessionManager.sharedInstance.settingData?.data?.postType?[3].name, for: .normal)
                 questionCell?.cloasedBtn?.tag = 3
                 questionCell?.cloasedBtn?.addTarget(self, action: #selector(postCategorySelectionTapped(sender:)), for: .touchUpInside)
                 
                 
             } else {
                 questionCell?.cloasedBtn?.isHidden = true
             }
             
             
             questionCell?.txtView?.delegate = self
             
             questionCell?.anonymousUserSwitch?.addTarget(self, action: #selector(anonymousUserButtonTapped(sender:)), for: .valueChanged)
             questionCell?.anonymousUserSwitch?.isOn = false
             
            // questionCell?.nftSwitch?.addTarget(self, action: #selector(NftUserButtonTapped(sender:)), for: .valueChanged)
             //questionCell?.nftSwitch?.isEnable = false
             questionCell?.nftSwitch?.delegate = self
             questionCell?.nftSwitch?.circleShadow = false
             questionCell?.nftSwitch?.fullSizeTapEnabled = true
             questionCell?.nftSwitch?.curState = .L
             
             
             questionCell?.monetizeSwitch?.delegate = self
             questionCell?.monetizeSwitch?.circleShadow = false
             questionCell?.monetizeSwitch?.fullSizeTapEnabled = true
             questionCell?.monetizeSwitch?.curState = .L
             
             
             
             
             self.nftSpark = 0
             
             //Create or initiate an instance of the custom view you would like to use on top of the keyboard.
             //The code below simply creates a green plain bar, but you can go ahead and add any buttons and other elements you need.
             let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
             customView.backgroundColor = .white
             
             let doneBtn = UIButton(frame: CGRect(x: customView.frame.origin.x + customView.frame.size.width - 60, y: 0, width: 60, height: 45))
             doneBtn.setTitle("Done", for: .normal)
             doneBtn.setTitleColor(.black, for: .normal)
             doneBtn.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
             
             customView.addSubview(doneBtn)
             colorPickerBgView?.frame = CGRect(x: 0, y: 2, width: customView.frame.origin.x + customView.frame.size.width - 60, height: 45)
             customView.addSubview(colorPickerBgView ?? UIView())
             questionCell?.txtView?.inputAccessoryView = customView
             
             questionCell?.txtView?.backgroundColor = UIColor.init(hexString: SessionManager.sharedInstance.settingData?.data?.appColor?[0].bgColour ?? "")
             
             questionCell?.txtView?.textColor = UIColor.init(hexString: SessionManager.sharedInstance.settingData?.data?.appColor?[0].textColour ?? "")
             
             //questionCell?.txtViewImgView.isHidden = true
             
             selectedColor = SessionManager.sharedInstance.settingData?.data?.appColor?[0].bgColour ?? ""
             selectedTxtColor = SessionManager.sharedInstance.settingData?.data?.appColor?[0].textColour ?? ""
             
             //Thread limit txt field done button
             let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
             doneToolbar.barStyle = .default
             let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
             let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
             let items = [flexSpace, done]
             doneToolbar.items = items
             doneToolbar.sizeToFit()
             questionCell?.threadLimitTxtFld?.inputAccessoryView = doneToolbar
             questionCell?.threadLimitTxtFld.delegate = self
             
             questionCell?.globalBtn?.isUserInteractionEnabled = true
             questionCell?.localBtn?.isUserInteractionEnabled = true
             questionCell?.socialBtn?.isUserInteractionEnabled = true
             questionCell?.cloasedBtn?.isUserInteractionEnabled = true
             questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = true
         
             if SessionManager.sharedInstance.homeFeedsSwippedObject != nil || SessionManager.sharedInstance.getTagNameFromFeedDetails?.count ?? 0 > 0  {
                 
                 questionCell?.globalBtn?.isUserInteractionEnabled = false
                 questionCell?.localBtn?.isUserInteractionEnabled = false
                 questionCell?.socialBtn?.isUserInteractionEnabled = false
                 questionCell?.cloasedBtn?.isUserInteractionEnabled = false
                 
                 
                 if SessionManager.sharedInstance.homeFeedsSwippedObject != nil {
                     postType = SessionManager.sharedInstance.homeFeedsSwippedObject?.postType ?? 0

                 } else {
                     postType = SessionManager.sharedInstance.getTagNameFromFeedDetails?["postType"] as? Int ?? 0

                 }
                 questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[postType - 1].desc
                 questionCell?.txtView?.text = "Tell your thought that create Spark"
                 
                 questionCell?.threadLimitTxtFld.text = "\(SessionManager.sharedInstance.settingData?.data?.minThreadLimit ?? 0)"

                 
                 switch postType {
                 case 1:
                     updateButtonSelection(questionCell?.globalBtn ?? UIButton())
                 case 2:
                     updateButtonSelection(questionCell?.localBtn ?? UIButton())
                 case 3:
                     updateButtonSelection(questionCell?.socialBtn ?? UIButton())
                 case 4:
                     
                     questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = false
                     questionCell?.threadLimitTxtFld.text = "1"
                     questionCell?.threadLimitTxtFld.isUserInteractionEnabled = false
                     updateButtonSelection(questionCell?.cloasedBtn ?? UIButton())
                   //Pass selected closed post user id
                     if SessionManager.sharedInstance.homeFeedsSwippedObject != nil {
                         closedConnectionArrayList.append(SessionManager.sharedInstance.homeFeedsSwippedObject?.userId ?? "")
                     } else {
                         closedConnectionArrayList.append(SessionManager.sharedInstance.getTagNameFromFeedDetails?["userId"] as? String ?? "")
                     }
                 default:
                     break
                 }
                 
                 if isFromAttachmentToEdit {
                     questionCell?.anonymousUserSwitch?.isOn = typedQuestionDict["allowAnonymous"] as? Bool ?? false
                     questionCell?.txtView?.text = typedQuestionDict["textViewValue"] as? String ?? ""
                     questionCell?.threadLimitTxtFld.text = typedQuestionDict["threadLimit"] as? String ?? ""
                     questionCell?.txtView?.backgroundColor = UIColor.init(hexString: typedQuestionDict["bgColor"] as? String ?? "")
                     questionCell?.txtView?.textColor = UIColor.init(hexString: typedQuestionDict["textColor"] as? String ?? "")
                     questionCell?.LblCountTextView.textColor = UIColor.init(hexString: typedQuestionDict["textColor"] as? String ?? "")
                     selectedColor = typedQuestionDict["bgColor"] as? String ?? ""
                     selectedTxtColor = typedQuestionDict["textColor"] as? String ?? ""
                     
                 }
                 
             }
             else if isFromAttachmentToEdit { //To edit create post input data
                 
                 
                 questionCell?.anonymousUserSwitch?.isOn = typedQuestionDict["allowAnonymous"] as? Bool ?? false
                 questionCell?.txtView?.text = typedQuestionDict["textViewValue"] as? String ?? ""
                 questionCell?.threadLimitTxtFld.text = typedQuestionDict["threadLimit"] as? String ?? ""
                 questionCell?.txtView?.backgroundColor = UIColor.init(hexString: typedQuestionDict["bgColor"] as? String ?? "")
                 questionCell?.txtView?.textColor = UIColor.init(hexString: typedQuestionDict["textColor"] as? String ?? "")
                 questionCell?.LblCountTextView.textColor = UIColor.init(hexString: typedQuestionDict["textColor"] as? String ?? "")
                 selectedColor = typedQuestionDict["bgColor"] as? String ?? ""
                 selectedTxtColor = typedQuestionDict["textColor"] as? String ?? ""
                 postType = typedQuestionDict["postType"] as? Int ?? 1
                 
                 selectedButton?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
                 selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                 selectedButton?.layer.borderWidth = 0.5
                 selectedButton?.layer.cornerRadius = 6
                 selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
                 
                 questionCell?.globalBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.localBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.socialBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 questionCell?.cloasedBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                 
                 switch typedQuestionDict["postType"] as? Int {
                 case 1:
                     updateButtonSelection(questionCell?.globalBtn ?? UIButton())
                 case 2:
                     updateButtonSelection(questionCell?.localBtn ?? UIButton())
                 case 3:
                     updateButtonSelection(questionCell?.socialBtn ?? UIButton())
                 case 4:
                     questionCell?.threadLimitTxtFld.isUserInteractionEnabled = false
                     updateButtonSelection(questionCell?.cloasedBtn ?? UIButton())
                 default:
                     break
                 }
                 
             }else{
                 questionCell?.txtView?.text = "Tell your thought that create Spark"
                 //questionCell?.txtView?.contentInset = UIEdgeInsets(top: 0.0,left: 0.0,bottom: 0,right: 0.0)
                 //questionCell?.txtViewImgView.isHidden = false
                 
                 questionCell?.threadLimitTxtFld.text = "\(SessionManager.sharedInstance.settingData?.data?.minThreadLimit ?? 0)"

                 updateButtonSelection(questionCell?.globalBtn ?? UIButton())
                 
                 
                 
                 
             }
             
             if SessionManager.sharedInstance.createPageisProfileUpdatedOrNot == false //&& SessionManager.sharedInstance.isProfileUpdatedOrNot == false
             {
                 
                 if !SessionManager.sharedInstance.isSkip{
                     if SessionManager.sharedInstance.isMonetize == 1 && SessionManager.sharedInstance.isNFT == 1{
                         
                         if questionCell?.switchView.isHidden == true && questionCell?.monetizeSwitch.isHidden == true{
                             self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark as NFT", target: .view(questionCell?.nftSwitch ?? UIView()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: "")
                             ]
                         }
                         
                         else if questionCell?.monetizeSwitch.isHidden == true{
                             self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark as NFT", target: .view(questionCell?.nftSwitch ?? UIView()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark anonymously", target: .view(questionCell?.switchView ?? UISwitch()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: "")
                             ]
                         }
                         
                         else{
                             self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark as NFT", target: .view(questionCell?.nftSwitch ?? UIView()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark anonymously", target: .view(questionCell?.switchView ?? UISwitch()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: ""),
                                            SpotlightNode(text: "Turn ON this toggle to post your Spark for monetization", target: .view(questionCell?.monetizeSwitch ?? UIView()), roundedCorners: true, imageName: "")
                             ]
                         }
                         
                        
                     }
                    
                     else  if SessionManager.sharedInstance.isNFT == 1 {
                         self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Turn ON this toggle to post your Spark as NFT", target: .view(questionCell?.nftSwitch ?? UIView()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Turn ON this toggle to post your Spark anonymously", target: .view(questionCell?.switchView ?? UISwitch()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: "")]
                     }
                     
                     else if SessionManager.sharedInstance.isMonetize == 1{
                         self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Turn ON this toggle to post your Spark anonymously", target: .view(questionCell?.switchView ?? UISwitch()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Turn ON this toggle to post your Spark for monetization", target: .view(questionCell?.monetizeSwitch ?? UIView()), roundedCorners: true, imageName: "")
                                       ]
                     }
                     
                     else{
                         self.nodess = [SpotlightNode(text: "Use this option to post your Spark globally", target: .view(questionCell?.globalBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark locally 25km from your location", target: .view(questionCell?.localBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark to all your connections", target: .view(questionCell?.socialBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Use this option to post your Spark directly to another Spark user", target: .view(questionCell?.cloasedBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Turn ON this toggle to post your Spark anonymously", target: .view(questionCell?.switchView ?? UISwitch()), roundedCorners: true, imageName: ""),
                                        SpotlightNode(text: "Set limit here to define how many Spark users you want to add for your Spark post", target: .view(questionCell?.threadLimitTxtFld ?? UITextField()), roundedCorners: true, imageName: "")]
                     }
                     //threadLimitTxtFld
                     Spotlight().startIntro(from: self, withNodes: nodess)
                     SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = true
                     SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
                 }
                 
                 
          
             }
             
             
        if SessionManager.sharedInstance.isNFT == 0{
     //            questionCell?.createSparkLblHeight.constant = 0
     //            questionCell?.CreateNftSparkviewHeight.constant = 0
     //            questionCell?.CreateNftLbl.isHidden = true
                 questionCell?.nftSwitch.isHidden = true
             }
             else{
     //            questionCell?.createSparkLblHeight.constant = 27
     //            questionCell?.CreateNftSparkviewHeight.constant = 20
     //            questionCell?.CreateNftLbl.isHidden = false
                 questionCell?.nftSwitch.isHidden = false
             }
             
         
             
             if SessionManager.sharedInstance.saveCountryCode == "+91"{
                 let ls = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
                 let rs = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray )
                 questionCell?.monetizeSwitch.setConfig(left: ls, right: rs)
                 self.currenyCode = "INR"
                 self.currencySymbol = "₹"
             }
             else if SessionManager.sharedInstance.saveCountryCode == ""{
                 let ls = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
                 let rs = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray)
                 questionCell?.monetizeSwitch.setConfig(left: ls, right: rs)
                 self.currenyCode = "INR"
                 self.currencySymbol = "₹"
             }
             else{
                 let ls = LabelSwitchConfig(text: "$", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
                 let rs = LabelSwitchConfig(text: "$", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray)
                 questionCell?.monetizeSwitch.setConfig(left: ls, right: rs)
                 self.currenyCode = "USD"
                 self.currencySymbol = "$"
             }
       // }
       
        
        
       
        
        return questionCell ?? UITableViewCell()
        
    }
    
    
    
/// Asks the delegate for the height to use for a row in a specified location.
/// - Parameters:
///   - tableView: The table view requesting this information.
///   - indexPath: An index path that locates a row in tableView.
/// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    /// Update the selected button to highlight as gradient
    func updateButtonSelection(_ sender: UIButton){
        
        selectedButton = sender
        selectedButton?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 6
        selectedButton?.layer.masksToBounds = true
        selectedButton?.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    
    /// Reset all the buttons when its highlighted already
    func resetBtn(){
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        questionCell?.globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        questionCell?.globalBtn?.layer.borderWidth = 0.5
        questionCell?.globalBtn?.layer.cornerRadius = 6
        questionCell?.globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        questionCell?.globalBtn?.layer.masksToBounds = true
        
        questionCell?.localBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        questionCell?.localBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        questionCell?.localBtn?.layer.borderWidth = 0.5
        questionCell?.localBtn?.layer.cornerRadius = 6
        questionCell?.localBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        questionCell?.localBtn?.layer.masksToBounds = true
        
        questionCell?.socialBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        questionCell?.socialBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        questionCell?.socialBtn?.layer.borderWidth = 0.5
        questionCell?.socialBtn?.layer.cornerRadius = 6
        questionCell?.socialBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        questionCell?.socialBtn?.layer.masksToBounds = true

        
        
        questionCell?.cloasedBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        questionCell?.cloasedBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        questionCell?.cloasedBtn?.layer.borderWidth = 0.5
        questionCell?.cloasedBtn?.layer.cornerRadius = 6
        questionCell?.cloasedBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        questionCell?.cloasedBtn?.layer.masksToBounds = true

    }
    
    
    
    ///Select the post type you want to post as global, local, social, closed
    @objc func postCategorySelectionTapped(sender:UIButton) {
        
        closedConnectionArrayList = []
        
        if(selectedButton == nil) { // No previous button was selected
            
            updateButtonSelection(sender)
            
        } else{ // User have already selected a button
            
            if(selectedButton != sender){ // Not the same button
                
                selectedButton?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
                selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                selectedButton?.layer.borderWidth = 0.5
                selectedButton?.layer.cornerRadius = 6
                selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
                selectedButton?.layer.masksToBounds = true
                updateButtonSelection(sender)
            }
            
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        questionCell?.threadLimitTxtFld.isUserInteractionEnabled = true
        questionCell?.threadLimitTxtFld.text = "\(SessionManager.sharedInstance.settingData?.data?.minThreadLimit ?? 0)"
        
        if sender.tag == 0 {
            postType = sender.tag + 1
            // need to save current location
            questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[sender.tag].desc
        } else if sender.tag == 1 {
            
            
            selectedButton?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
            selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            selectedButton?.layer.borderWidth = 0.5
            selectedButton?.layer.cornerRadius = 6
            selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
            selectedButton?.layer.masksToBounds = true
            
            questionCell?.globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
            questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            questionCell?.globalBtn?.layer.borderWidth = 0.5
            questionCell?.globalBtn?.layer.cornerRadius = 6
            questionCell?.globalBtn?.layer.masksToBounds = true
            questionCell?.globalBtn?.setTitleColor(UIColor.white, for: .normal)
            postType = 1
            
            let locationManager = CLLocationManager()

            //if CLLocationManager.locationServicesEnabled() {
                
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

                            })
                        self.present(alert, animated: true)
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Access")
                        
                        questionCell?.globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
                        questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                        questionCell?.globalBtn?.layer.borderWidth = 0.5
                        questionCell?.globalBtn?.layer.cornerRadius = 6
                        questionCell?.globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
                        questionCell?.globalBtn?.layer.masksToBounds = true
                        
                        selectedButton?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
                        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                        selectedButton?.layer.borderWidth = 0.5
                        selectedButton?.layer.cornerRadius = 6
                        selectedButton?.layer.masksToBounds = true
                        selectedButton?.setTitleColor(UIColor.white, for: .normal)
                        
                        postType = sender.tag + 1
                        // need to call api and show close list
                        questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[sender.tag].desc
                        
                        
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

                                })
                            self.present(alert, animated: true)
                            
                            case .authorizedAlways, .authorizedWhenInUse:
                                print("Access")
                            
                           
                            
                            postType = sender.tag + 1
                            // need to call api and show close list
                            questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[sender.tag].desc
                            
                            @unknown default:
                                break
                        }
                    
                }
//            } else {
//                print("Location services are not enabled")
//            }
            
        }
        else if sender.tag == 2 {
            postType = sender.tag + 1
            // need to call api and show close list
            questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[sender.tag].desc
            //clear global btn bg color
            questionCell?.globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
            questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            questionCell?.globalBtn?.layer.borderWidth = 0.5
            questionCell?.globalBtn?.layer.cornerRadius = 6
            questionCell?.globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
            questionCell?.globalBtn?.layer.masksToBounds = true
        }else if sender.tag == 3 {
            postType = sender.tag + 1
            questionCell?.globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
            questionCell?.globalBtn?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            questionCell?.globalBtn?.layer.borderWidth = 0.5
            questionCell?.globalBtn?.layer.cornerRadius = 6
            questionCell?.globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
            questionCell?.globalBtn?.layer.masksToBounds = true
            
            // need to call api and show close list
            questionCell?.postTypeDescLabl?.text = SessionManager.sharedInstance.settingData?.data?.postType?[sender.tag].desc
            
            questionCell?.threadLimitTxtFld.isUserInteractionEnabled = false
            questionCell?.threadLimitTxtFld.text = "0"
            
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
        }
        
    }

    /// Photo button is tapped to select the photos from gallery or snap from camera
    @IBAction func photoButtonTapped(sender:UIButton) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
    
        if questionCell?.threadLimitTxtFld?.text == "0" {
            //self.showErrorAlert(error: "Kindly choose at least one closed connection")
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        guard let threadMemberLimtValue = questionCell?.threadLimitTxtFld?.text, Int(threadMemberLimtValue) ?? 0 > 0 else {
            self.showErrorAlert(error: "Kindly input loop members limit")
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        let photoVC = self.storyboard?.instantiateViewController(identifier: "PhotoModelViewController") as! PhotoModelViewController
        typedQuestionDict = ["mediaType":MediaType.Image.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
        photoVC.currenyCode = self.currenyCode
        photoVC.currencySymbol = self.currencySymbol
        photoVC.nftParam = self.nftSpark
        photoVC.monetizeSpark = self.isMonetize
        photoVC.typedQuestionDict = typedQuestionDict
        photoVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
        photoVC.multiplePost = self.multiplePost
        photoVC.repostId = self.repostId
        photoVC.isFromPhotoSelection = true
        photoVC.backMultiPostdelegate = self
        photoVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        photoVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        self.navigationController?.present(photoVC, animated: true, completion: nil)
        
    }
    
    /// Audio button is tapped to select the mp3 audio file or record the audio
    @IBAction func audioButtonTapped(sender:UIButton) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
      
        if questionCell?.threadLimitTxtFld?.text == "0" {
            //self.showErrorAlert(error: "Kindly choose at least one closed connection")
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        guard let threadMemberLimtValue = questionCell?.threadLimitTxtFld?.text, Int(threadMemberLimtValue) ?? 0 > 0 else {
            self.showErrorAlert(error: "Kindly input loop members limit")
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        let photoVC = self.storyboard?.instantiateViewController(identifier: "PhotoModelViewController") as! PhotoModelViewController
        typedQuestionDict = ["mediaType":MediaType.Audio.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
        photoVC.currenyCode = self.currenyCode
        photoVC.currencySymbol = self.currencySymbol
        photoVC.monetizeSpark = self.isMonetize
        photoVC.nftParam = self.nftSpark
        photoVC.typedQuestionDict = typedQuestionDict
        photoVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
        photoVC.multiplePost = self.multiplePost
        photoVC.repostId = self.repostId
        photoVC.isFromPhotoSelection = false
        photoVC.backMultiPostdelegate = self
        photoVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        photoVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        self.navigationController?.present(photoVC, animated: true, completion: nil)
        //openAudioViewer()
    }
    
    ///On pressing of attachment button it will open the document viewer to select the documents
    @IBAction func attachmentButtonTapped(sender:UIButton) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
 
        if questionCell?.threadLimitTxtFld?.text == "0" {
            //self.showErrorAlert(error: "Kindly choose at least one closed connection")
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        guard let threadMemberLimtValue = questionCell?.threadLimitTxtFld?.text, Int(threadMemberLimtValue) ?? 0 > 0 else {
            self.showErrorAlert(error: "Kindly input loop members limit")
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        openDocumentViewer()
    }
    
    
    /// Video button is tapped to select the videos from gallery
    @IBAction func videoButtonTapped(sender:UIButton) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        

        
        if questionCell?.threadLimitTxtFld?.text == "0" {
           // self.showErrorAlert(error: "Kindly choose at least one closed connection")
            let cloasedConectionVC = self.storyboard?.instantiateViewController(identifier: "ClosedConnectionsViewController") as! ClosedConnectionsViewController
            cloasedConectionVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cloasedConectionVC.view.backgroundColor = .black.withAlphaComponent(0.5)
            cloasedConectionVC.delegate = self
            self.navigationController?.present(cloasedConectionVC, animated: true, completion: nil)
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        guard let threadMemberLimtValue = questionCell?.threadLimitTxtFld?.text, Int(threadMemberLimtValue) ?? 0 > 0 else {
            self.showErrorAlert(error: "Kindly input loop members limit")
            questionCell?.threadLimitTxtFld.becomeFirstResponder()
            self.tabBarController?.selectedIndex = 2
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// Tells the delegate that the user picked a still image or movie.
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - info: A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in UIImagePickerController.InfoKey.
    ///   - Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
    ///   - When editing is enabled, the image picker view presents the user with a preview of the currently selected image or movie along with controls for modifying it. (This behavior is managed by the picker view prior to calling this method.) If the - - - user modifies the image or movie, the editing information is available in the info parameter. The original image is also returned in the info parameter.
    ///   - If you set the image picker’s showsCameraControls property to false and provide your own custom controls, you can take multiple pictures before dismissing the image picker interface. However, if you set that property to true, your - delegate must dismiss the image picker interface after the user takes one picture or cancels the operation.
    ///   - Implementation of this method is optional, but expected.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) {
            
            let indexPath = IndexPath(row: 0, section: 0)
            let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
            
            dismiss(animated: true, completion: nil)
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
            editImageVC.nftParam = self.nftSpark
            typedQuestionDict = ["mediaType":MediaType.Image.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
            editImageVC.currenyCode = self.currenyCode
            editImageVC.currencySymbol = self.currencySymbol
            editImageVC.typedQuestionDict = typedQuestionDict
            editImageVC.monetizeSpark = self.isMonetize
            editImageVC.selectedImage = image
            editImageVC.FromLoopMonetize = FromLoopMonetize
            editImageVC.multiplePost = multiplePost
            editImageVC.repostId = repostId
            editImageVC.backtoMultipostDelegate = self
            self.present(editImageVC, animated: true, completion: nil)
            
        }
        
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            let indexPath = IndexPath(row: 0, section: 0)
            let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
            
            // Do something with the URL
            dismiss(animated: true, completion: nil)
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
            typedQuestionDict = ["mediaType":MediaType.Video.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
            editImageVC.currenyCode = self.currenyCode
            editImageVC.currencySymbol = self.currencySymbol
            editImageVC.nftParam = self.nftSpark
            editImageVC.monetizeSpark = self.isMonetize
            editImageVC.typedQuestionDict = typedQuestionDict
            editImageVC.selectedVideoPath = url.absoluteString
            editImageVC.selectedVideoUrl = url
            editImageVC.FromLoopMonetize = FromLoopMonetize
            editImageVC.multiplePost = multiplePost
            editImageVC.repostId = repostId
            editImageVC.backtoMultipostDelegate = self
            self.present(editImageVC, animated: true, completion: nil)
        }
    }
    
    /// Back button is tapped to dismiss the page.
    ///  - Pop up alert will show
    ///   - Discard or cancel if discarded it will be dismissed.
    @IBAction func backButtonTapped(sender:UIButton) {
        
        if isFromLoopRepost{
            self.navigationController?.popViewController(animated: true)
        }
        else if FromLoopMonetize == 2{
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.tabBarController?.tabBar.isHidden = false

            let alert = UIAlertController(title: "Discard Spark media ?", message: "", preferredStyle: .actionSheet)
            
            //to change font of title and message.
            let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.veryLarge)]
            let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
            
            let titleAttrString = NSMutableAttributedString(string: "Discard Spark media ?", attributes: titleFont)
            let messageAttrString = NSMutableAttributedString(string: "\nIf you go back now, you will lose any changes that you've made.", attributes: messageFont)
            
            alert.setValue(titleAttrString, forKey: "attributedTitle")
            alert.setValue(messageAttrString, forKey: "attributedMessage")
            
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
                

    //            UserDefaults.standard.set(false, forKey: "isChangeTabBarItemIcon") //Bool
                NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
               // NotificationCenter.default.post(name: Notification.Name("changeHomeIcon"), object: ["index":0])
                
            }))
            
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
                self.tabBarController?.tabBar.isHidden = true
            })
            //cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: {
                
            })
        }
        
       
    }
    
    ///Anonymous switch is tapped to turn the user post is anonymous.
    @objc func anonymousUserButtonTapped(sender:UISwitch) {
        debugPrint(sender.isOn)
        if sender.isOn{
            isAnonymousUserOn = true
        }else{
            isAnonymousUserOn = false
        }
    }
    
//    @objc func NftUserButtonTapped(sender:UISwitch) {
//        debugPrint(sender.isOn)
//        if sender.isOn{
//            nftSpark = 1
//        }else{
//            nftSpark = 0
//        }
//    }
    
    
    /// This is the switch with label inside the switch
    /// - Parameter sender: It is to set the switch state and which switch to be enable.
    func switchChangToState(sender: LabelSwitch) {
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        if sender == questionCell?.nftSwitch{
            switch sender.curState {
            case .L:
                print("left")
                nftSpark = 0
            case .R:
                print("right")
                nftSpark = 1
            }
        }
        else if sender == questionCell?.monetizeSwitch{
            switch sender.curState {
            case .L:
                print("left")
                isMonetize = 0
                questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = true
            case .R:
                print("right")
                
                //self.isAgree = 0
                if isAgree == 2{
                    isMonetize = 1
                    
                    questionCell?.anonymousUserSwitch?.setOn(false, animated: true)
                    isAnonymousUserOn = false
                    questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = false
                    
                    
                }
                else{
                    
                    
                    if isAgree == 0{
                        let alert = UIAlertController(title: "", message: "Before you proceed, please add your payout details", preferredStyle: .alert)
                        
                        
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                            let editProfileVC = storyBoard.instantiateViewController(identifier: EDIT_BIO_STORYBOARD) as! EditProfileTableViewController
                            editProfileVC.isFromProfile = false
                            editProfileVC.isFromCreatePost = true
                            self.navigationController?.pushViewController(editProfileVC, animated: true)
                            
                        })
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                            questionCell?.monetizeSwitch.curState = .L
                            self.isMonetize = 0
                        })
                        self.present(alert, animated: true)
                    }
                    else{
                        let alert = UIAlertController(title: "", message: "Your account is not yet verified, kindly contact the admin \(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")", preferredStyle: .alert)
                        
                        
                        alert.addAction(UIAlertAction(title: "Contact admin", style: .default) { action in
                            if MFMailComposeViewController.canSendMail() {
                                let mail = MFMailComposeViewController()
                                mail.mailComposeDelegate = self
                                mail.setToRecipients(["\(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")"])
                                mail.setMessageBody("", isHTML: false)
                                self.present(mail, animated: true)
                            } else {
                                // email is not added in app
                            }
                            
                        })
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                            questionCell?.monetizeSwitch.curState = .L
                            self.isMonetize = 0
                        })
                        self.present(alert, animated: true)
                    }
                }
                
                
                
//                if SessionManager.sharedInstance.isKYC == false{
//
//                }
//                else{
//                    questionCell?.anonymousUserSwitch?.setOn(false, animated: true)
//                    isAnonymousUserOn = false
//                    questionCell?.anonymousUserSwitch?.isUserInteractionEnabled = false
//                    isMonetize = 1
//                }
               
            }
        }
        
    }
    
    /// Dimiss the mail composer
    /// - Parameters:
    ///   - controller: Current vc
    ///   - result: dismiss the controller
    ///   - error: If any error throws it will shown in error
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        self.isMonetize = 0
        questionCell?.monetizeSwitch.curState = .L
        
        controller.dismiss(animated: true)
    }
  
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isFromAttachmentToEdit = false
        SessionManager.sharedInstance.isRepost = false
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.selectedButton?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
            self.selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            self.selectedButton?.layer.borderWidth = 0.5
            self.selectedButton?.layer.cornerRadius = 6
            self.selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)

            questionCell?.globalBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            questionCell?.localBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            questionCell?.socialBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            questionCell?.cloasedBtn?.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        }
        
        SessionManager.sharedInstance.isRepost = false
        //self.dismiss(animated: false)

       // NotificationCenter.default.removeObserver(self)
        
    }
    
    
    ///Keyboard will show and it will rise up
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                debugPrint(keyboardSize.height)
                self.view.frame.origin.y -= keyboardSize.height - 250
            }
        }
    }

    /// Keyboard will hide
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}

//#MARK : UITextView Delegate
extension  CreatePostViewController {
    
    /// Set the text Limit count
    /// - Parameters:
    ///   - existingText: Already existing text
    ///   - newText: The new text added
    ///   - limit: Limit count to be set
    /// - Returns: Whether it returns true or false
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        
        //questionCell?.LblCountTextView.text = "\(text.count+newText.count)/\(limit)"
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
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
//        let currentText = textView.text ?? ""
//
//        // attempt to read the range they are trying to change, or exit if we can't
//        guard let stringRange = Range(range, in: currentText) else { return false }
//
//        // add their new text to the existing text
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//
//        let newText = textView.text.replacingCharacters(in: range, with: text)
//        let maxNumberOfLines = 4
//        let maxCharactersCount = 180
//        let underLineLimit = self.textView(textView, newText: newText, underLineLimit: maxNumberOfLines)
//        let underCharacterLimit = newText.count <= maxCharactersCount
//
//
//        if updatedText.count >= maxCharactersCount{
//            questionCell?.LblCountTextView.text = "\(questionCell?.txtView?.text.count ?? 0)/180"
//            self.showErrorAlert(error: "Maximum character limit reached")
//        }
//        else{
//            questionCell?.LblCountTextView.text = "\(updatedText.count)/180"
//        }
//        // make sure the result is under 16 characters
//        return updatedText.count <= maxCharactersCount && underLineLimit && underCharacterLimit
        
        
        
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
            questionCell?.LblCountTextView.text  = "\(180)/180"
            self.showErrorAlert(error: "Maximum character limit reached")
        }
        else{
            questionCell?.LblCountTextView.text  = "\(updatedText.count)/180"
        }
        // make sure the result is under 16 characters
        return updatedText.count <= maxCharactersCount && underLineLimit && underCharacterLimit
        
        
        
        
        
        
        
        //let whitespaceSet = CharacterSet.whitespaces
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
//        questionCell?.LblCountTextView.text  = "\(updatedText.count)/180"
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
        
//        let textCount = textView.text?.count ?? 0 + text.count - range.length + 1
//        print(textCount)
//        //let whitespaceSet = CharacterSet.whitespaces
//
//        let newText = textView.text.replacingCharacters(in: range, with: text)
//        let maxNumberOfLines = 4
//        let maxCharactersCount = 180
//        let underLineLimit = self.textView(textView, newText: newText, underLineLimit: maxNumberOfLines)
//        let underCharacterLimit = newText.count <= maxCharactersCount
//
//        if textView.text.count == 0{
//            questionCell?.LblCountTextView.text  = "\(0)/180"
//        }
//
//        if range.length >= 180 && text.isEmpty {
//                return false
//            }
//
//            let newString = (textView.text as NSString).replacingCharacters(in: range, with: text)
//            if newString.count > 180 {
//                textView.text = String(newString.prefix(180))
//            }
//        return underLineLimit && underCharacterLimit && newString.count <= 180 //self.textLimit(existingText: textView.text, newText: text, limit: 180)
    }
    //    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //        guard let text = textView.text else { return false }
    //        let newString = (text as NSString).replacingCharacters(in: range, with: text)
    //
    //        return newString.count < 300
    //
    //    }
    //
    
    
    
    /// Tells the delegate when the user changes the text or attributes in the specified text view.
    /// - Parameter textView:The text view containing the changes.
    /// - The text view calls this method in response to user-initiated changes to the text. This method is not called in response to programmatically initiated changes.
    func textViewDidChange(_ textView: UITextView){
        if textView.text.count >= 180{
            let trimString = String(textView.text.prefix(180)) // <- try this
           textView.text = trimString
        }
    }
    
    
    
    
    
    
    /// Tells the delegate when editing of the specified text view begins
    /// - Parameter textView: The text view in which editing began.
    /// Implementation of this method is optional. A text view sends this message to its delegate immediately after the user initiates editing in a text view and before any changes are actually made. You can use this method to set up any editing-related data structures and generally prepare your delegate to receive future editing messages.
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if  textView.text == "Tell your thought that create Spark" {
            
            textView.text = ""
                        
            //self.adjustContentSize(tv: textView)
            
            let indexPath = IndexPath(row: 0, section: 0)
            let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
            
            //questionCell?.txtViewImgView.isHidden = true
        }
    }
    
    
    
    
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
    
    
    
    
    /// Tells the delegate when editing of the specified text view ends.
    /// - Parameter textView: The text view in which editing ended.
    /// - Implementation of this method is optional. A text view sends this message to its delegate after it closes out any pending edits and resigns its first responder status. You can use this method to tear down any data structures or change any state information that you set when editing began.
    func textViewDidEndEditing(_ textView: UITextView) {
        if  (textView.text.isEmpty) {
            textView.text = "Tell your thought that create Spark"
        }else {
        }
    }
    
}

//#MARK : UITextView Delegate
extension  CreatePostViewController : UITextFieldDelegate {
    
    /// Asks the delegate whether to change the specified text.
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range. During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text. When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: true if the specified text range should be replaced; otherwise, false to keep the old text.
    /// - The text field calls this method whenever user actions cause its text to change. Use this method to validate text as it is typed by the user. For example, you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)

        if newString.hasPrefix("0") {
            return false
        }
        
        return (Int(newString) ?? 0 <= SessionManager.sharedInstance.settingData?.data?.threadLimit ?? 0 && Int(newString.count) <= SessionManager.sharedInstance.settingData?.data?.threadLimit?.nonzeroBitCount ?? 0)
    }
}


@IBDesignable class BigSwitch: UISwitch {
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
}

//#MARK: UICollectionView Delegate and Datasource
extension CreatePostViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return SessionManager.sharedInstance.settingData?.data?.appColor?.count ?? 0
    }
    
    
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorPickerCollectionCell", for: indexPath as IndexPath) as? colorPickerCollectionCell
        
        cell?.colorView.backgroundColor = UIColor.init(hexString: SessionManager.sharedInstance.settingData?.data?.appColor?[indexPath.row].bgColour ?? "")
        cell?.colorView.layer.cornerRadius = 5.0
        cell?.colorView.clipsToBounds = true
        
        
        return cell ?? UICollectionViewCell()
        
    }
    
    
    /// Tells the delegate that the item at the specified index path was selected
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = SessionManager.sharedInstance.settingData?.data?.appColor?[indexPath.row].bgColour ?? ""
        selectedTxtColor = SessionManager.sharedInstance.settingData?.data?.appColor?[indexPath.row].textColour ?? ""
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        questionCell?.txtView?.backgroundColor = UIColor.init(hexString: selectedColor)
        questionCell?.txtView?.textColor = UIColor.init(hexString: selectedTxtColor)
        questionCell?.LblCountTextView.textColor = UIColor.init(hexString: selectedTxtColor)
    }
    
}

//#MARK: Collectionview Cell Class - Tag Cell
/**
 This class is used to show the color picker to set in the textview backlground
 */
class colorPickerCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    
}


extension CreatePostViewController : UIDocumentPickerDelegate {
    /// Audioviewer is used select the audio as mp3 type, mp4 type and wav form
    func openAudioViewer() {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeMP3),String(kUTTypeMPEG4Audio),String(kUTTypeWaveformAudio)], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        audioDocumentStr = "audio"
        
        
    }
    func openDocumentViewer() {
        ///Document viewer is used to select the text type , pf, word, doc and docx can be selected
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypePDF),String(kUTTypeSpreadsheet),String(kUTTypePresentation),"com.microsoft.word.doc","org.openxmlformats.wordprocessingml.document","com.adobe.pdf"], in: .import)
        //Call Delegate
        documentPicker.delegate = self
        audioDocumentStr = "docs"
        self.present(documentPicker, animated: true)
    }
    
    /// ells the delegate that the user has selected one or more documents.
    /// - Parameters:
    ///   - controller: The document picker that called this method.
    ///   - urls: The URLs of the selected documents.
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //print(urls)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let questionCell = tableView?.cellForRow(at: indexPath) as? inputCell
        
        if audioDocumentStr == "audio" {
            if controller.documentPickerMode == UIDocumentPickerMode.import {
                if(urls.count > 0) {
                    
                    let fileArray = "\(urls.first ?? URL(fileURLWithPath: ""))".components(separatedBy: "/")
                    let finalFileName = fileArray.last
                    let finalName = finalFileName?.components(separatedBy: ".")
                    debugPrint(finalFileName ?? "")
                    debugPrint(finalName ?? "")
                    
                    let fileURL = urls.first ?? URL(fileURLWithPath: "")
                    do {
                        let data = try Data(contentsOf: fileURL)
                        debugPrint(data)
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                        let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
                        typedQuestionDict = ["mediaType":MediaType.Audio.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
                        editImageVC.currenyCode = self.currenyCode
                        editImageVC.currencySymbol = self.currencySymbol
                        editImageVC.nftParam = self.nftSpark
                        editImageVC.monetizeSpark = self.isMonetize
                        editImageVC.typedQuestionDict = typedQuestionDict
                        editImageVC.selectedDocData = data
                        editImageVC.selectedDocTypeArray = finalName ?? []
                        editImageVC.FromLoopMonetize = FromLoopMonetize
                        editImageVC.multiplePost = multiplePost
                        editImageVC.repostId = repostId
                        editImageVC.backtoMultipostDelegate = self
                        editImageVC.asseturl = urls.first ?? URL(fileURLWithPath: "")
                        self.present(editImageVC, animated: true, completion: nil)
                    }catch {
                        debugPrint(error.localizedDescription)
                    }
                    
                }
            }
        } else {
            let fileArray = "\(urls.first ?? URL(fileURLWithPath: ""))".components(separatedBy: "/")
            let finalFileName = fileArray.last
            let finalName = finalFileName?.components(separatedBy: ".")
            debugPrint(finalFileName ?? "")
            debugPrint(finalName ?? "")
            
            let fileURL = urls.first ?? URL(fileURLWithPath: "")
            do{
                let data = try Data(contentsOf: fileURL)
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
                typedQuestionDict = ["mediaType":MediaType.Document.rawValue,"bgColor":"","textColor":"","textViewValue":"","threadLimit":questionCell?.threadLimitTxtFld.text ?? "","allowAnonymous":isAnonymousUserOn,"postType":postType,"closedConnectionList":closedConnectionArrayList,"lat":postType == 2 ? latLong["lat"] ?? "" : "","long":postType == 1 ? latLong["long"] ?? "" : "","coordinates":[postType == 2 ? latLong["long"] ?? 0.0 : 0.0,postType == 2 ? latLong["lat"] ?? 0.0 : 0.0]]
                editImageVC.currenyCode = self.currenyCode
                editImageVC.currencySymbol = self.currencySymbol
                editImageVC.nftParam = self.nftSpark
                editImageVC.monetizeSpark = self.isMonetize
                editImageVC.typedQuestionDict = typedQuestionDict
                editImageVC.selectedDocData = data
                editImageVC.selectedDocUrl = urls.first ?? URL(fileURLWithPath: "")
                editImageVC.selectedDocTypeArray = finalName ?? []
                editImageVC.FromLoopMonetize = FromLoopMonetize
                editImageVC.multiplePost = multiplePost
                editImageVC.backtoMultipostDelegate = self
                editImageVC.repostId = repostId
                self.present(editImageVC, animated: true, completion: nil)
            }catch {
                debugPrint(error.localizedDescription)
            }
        }
        
    }
}

/**
 The input cell is used to set the objects in create post page
 */
class inputCell: UITableViewCell,UITextViewDelegate {
    
    @IBOutlet weak var nameLbl:UILabel?
    @IBOutlet weak var profileImgView:customImageView?
    @IBOutlet weak var localBtn:UIButton?
    @IBOutlet weak var globalBtn:UIButton?
    @IBOutlet weak var socialBtn:UIButton?
    @IBOutlet weak var cloasedBtn:UIButton?
    @IBOutlet weak var anonymousUserLbl:UILabel?
    @IBOutlet weak var anonymousUserSwitch:UISwitch?
    @IBOutlet weak var txtView:UITextView?
    @IBOutlet weak var threadLimitTxtFld: UITextField!
    @IBOutlet weak var postTypeDescLabl:UILabel?
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var anonymousImage: UIImageView!
    //@IBOutlet weak var txtViewImgView: UIImageView!
    
    @IBOutlet weak var createSparkLblHeight: NSLayoutConstraint!
    @IBOutlet weak var CreateNftSparkviewHeight: NSLayoutConstraint!
    @IBOutlet weak var CreateNftLbl: UILabel!
    @IBOutlet weak var NftSwitchView: UIView!
    @IBOutlet weak var nftSwitch: LabelSwitch!
    @IBOutlet weak var textViewBgViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var LblCountTextView: UILabel!
    @IBOutlet weak var monetizeSwitch: LabelSwitch!
    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    
    
    
    
}



extension UIDevice {
    /**
     This extension class is ued to set the multiple device choice for constraints
     */
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_6Plus_6sPlus_7Plus_8Plus_Simulators = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus Simulators"
        case iPhones_X_XS_12MiniSimulator = "iPhone X or iPhone XS or iPhone 12 Mini Simulator"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case iPhone_12Mini = "iPhone 12 Mini"
        case iPhone_12_12Pro = "iPhone 12 or iPhone 12 Pro"
        case iPhone_12ProMax = "iPhone 12 Pro Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136: return .iPhones_5_5s_5c_SE
        case 1334: return .iPhones_6_6s_7_8
        case 1792: return .iPhone_XR_11
        case 1920: return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2208: return .iPhones_6Plus_6sPlus_7Plus_8Plus_Simulators
        case 2340: return .iPhone_12Mini
        case 2426: return .iPhone_11Pro
        case 2436: return .iPhones_X_XS_12MiniSimulator
        case 2532: return .iPhone_12_12Pro
        case 2688: return .iPhone_XSMax_ProMax
        case 2778: return .iPhone_12ProMax
        default: return .unknown
        }
    }
}


extension String {
    /// Returns a new string in which the characters in a specified range of the receiver are replaced by a given string.
    /// - Parameters:
    ///   - range: A range of characters in the receiver.
    ///   - string: The string with which to replace the characters in range.
    /// - Returns: A new string in which the characters in range of the receiver are replaced by replacement.
    func replacingCharacters(in range: NSRange, with string: String) -> String {
        let currentNSString = self as NSString
        return currentNSString.replacingCharacters(in: range, with: string)
    }

    func size(constrainedToWidth width: CGFloat, font: UIFont) -> CGSize {
        let nsString = self as NSString
        let boundingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        return nsString
            .boundingRect(with: boundingSize,
                          options: .usesLineFragmentOrigin,
                          attributes: [.font: font],
                          context: nil)
            .size
    }
}
