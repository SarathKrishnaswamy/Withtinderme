//
//  ProfileViewController.swift
//  Spark
//
//  Created by Gowthaman P on 05/07/21.
//

import UIKit
import CropViewController
import EasyTipView
import RSLoadingView
import FirebaseDynamicLinks
import UIView_Shimmer
import AVFoundation

//extension UIView: ShimmeringViewProtocol { }



/**
 This class performs particular user view his own Information like what they post in sparklines section, his posted spark tags, eyeshots, nft, claps and his connection with other user
 */


class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, ProfileTimeLineDelegate,backFromProfileDelegate {
   
    /// Back and reload this page from feedDetailsViewController
    func backandReload() {
        print("reloading")
       // let indexPath = IndexPath(row: 0, section: 3)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? TimelineImageTableViewCell {
            cell.setupTimelineViewModel()
            cell.global()
            cell.collectionView.reloadData()
            //updateUserInterface()
            //MaininternetRetry()
        }
//        let timelineCell = tableView.cellForRow(at: indexPath) as? TimelineImageTableViewCell//tableView.dequeueReusableCell(withIdentifier: "TimelineImageTableViewCell", for: indexPath) as? TimelineImageTableViewCell let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
//        timelineCell?.setupTimelineViewModel()
//        timelineCell?.global()
        //timelineCell?.getMyTimelineListValues(PageNumber: 1, PageSize: 10, postType: 1)
        //self.tableView.reloadData()
    }
    
    
    /// When we select any of the sparklines it will navigate to FeedDetailsViewController
    /// - Parameters:
    ///   - postId: Sparklines needed a postid to open the particularcpost
    ///   - isFromBubble: if user redirected from bubble page it will show IsFromBubble boolean as true
    func getSelectedTimelineData(postId: String, threadId: String, isFromBubble: Bool) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
        detailVC.backfromprofileDelegate = self
        detailVC.postId = postId
        detailVC.threadId = threadId
        
        detailVC.myPostId = postId
        detailVC.myThreadId = threadId
        
        SessionManager.sharedInstance.userIdFromSelectedBubbleList = SessionManager.sharedInstance.getUserId
        SessionManager.sharedInstance.threadId = threadId
        detailVC.isFromBubble = false
        detailVC.isFromProfile = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var imageView: UIView!
    var isSeeMoreTapped = false
    
    ///Initialise the ProfileViewModel
    var viewModel = ProfileViewModel()
    
    
    ///Initialise the getProfileData
    var profileDetails:GetProfileData?
    
    
    ///Initialise the PostedTag Array
    var postedTagArray:[PostedTag]?
    
    var selectedImageUrl = ""
    var isSaved : Bool? = false
    
    //Cropper
    private var croppingStyle = CropViewCroppingStyle.default
    private var imageFrame = TOCropViewControllerAspectRatioPreset.presetSquare
    
    //paginator
    var loadingData = false
    var isAPICalled = false
    var isLoading = false
    var isFromDelete = false
    // let historyBtn = UIButton(type: .custom)
    
    @IBOutlet weak var noDataLbl: UILabel!
    
    
    ///Initialise the PopTip here
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
    
    var alertController = UIAlertController()
    
    var countryCode = ""
    var isSkip = false
    var isAgree = 0
    var isKyc = false
    var accountDetails = ""
    
    
    
    
    /// Called after the controller's view is loaded into memory.
    /// - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetUp()
//
        backButtonSetUp()
        
        updateUserInterface()
        MaininternetRetry()
        
        easyTipViewSetUp()
        NotificationCenter.default.addObserver(self,selector: #selector(statusManager),name: .flagsChanged,object: nil)
       //
        
        //self.tableView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //self.imageView.setTemplateWithSubviews(false)
        }
        
        
    }
    
    
    
    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.view.setTemplateWithSubviews(true, viewBackgroundColor: .systemBackground)
    }
    
    
    
    
    
    ///Update the User Interface when there is internet  ot no internet or changed from wifi, mobile data
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            //MaininternetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            //self.alertController.dismiss(animated: true)
            MaininternetRetry()
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            //self.alertController.dismiss(animated: true)
             MaininternetRetry()
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
    
   ///Internet can be check whether the internet is connected or not
    func MaininternetRetry(){
        if Connection.isConnectedToNetwork(){
            print("Connected")
            setupViewModel()
            setUpSaveObserver()
            viewModel.getProfileAPICall()
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? TimelineImageTableViewCell {
                cell.setupTimelineViewModel()
                cell.global()
                cell.collectionView.reloadData()
            }
            self.alertController.dismiss(animated: true)
           
        }
        else{
            alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
            
            
            
            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                // ... Do something
                //self.navigationController?.popViewController(animated: true)
                self.MaininternetRetry()
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ... Do something
            }
            
        }
    }
    
    
    
    
    
    
    ///Create a short url using firebase to share a post
    /// - UIActivityViewController to share the link has been set here
    func createShortUrl(urlString:String){
        guard let link = URL(string: urlString) else { return }
        let components = DynamicLinkComponents(link: link, domainURIPrefix: "https://sparkme.synctag.com/Post")
        components?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.adhash.spark")
        components?.iOSParameters?.appStoreID = "1578660405"
        components?.iOSParameters?.minimumAppVersion = "1.1.4"
        components?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.adhash.sparkme")
        components?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        components?.socialMetaTagParameters?.title = "Sparkme"
        //components?.socialMetaTagParameters?.descriptionText = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postContent
        
        
        

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
            activityVC.setValue("Reg: Sparkme Profile", forKey: "Subject")
            activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
            self.present(activityVC, animated: true, completion: nil)
        
        })
        //  print(self.self.share_url)

    }
    
    
    
    
    
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2352941176, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        var frame = tableView.bounds
        
        frame.origin.y = -frame.size.height
        
        let backgroundView = UIView(frame: frame)
        
        backgroundView.autoresizingMask = .flexibleWidth
        
        backgroundView.backgroundColor = #colorLiteral(red: 0.2349898517, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        
        // Adding the view below the refresh control
        tableView.insertSubview(backgroundView, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isProfileDetailUpdated(notification:)), name: Notification.Name("isProfileDetailUpdated"), object: nil)
        //self.tableView.reloadData()
        self.isLoading = true
    
    }
    
    
    
    
    ///It notifies to update the profile detail page using the api View Model
    /// - Set the profile model the view model
    
    @objc func isProfileDetailUpdated(notification:NSNotification) {
        
        setupViewModel()
        viewModel.getProfileAPICall()
    }
    
    
    
    
    
    ///Back button setup eith back button image setup
    func backButtonSetUp() {
        
        // create the button
        let suggestImage  = #imageLiteral(resourceName: "profileBack").withRenderingMode(.alwaysOriginal)
        let suggestButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        suggestButton.setBackgroundImage(suggestImage, for: .normal)
        
        // here where the magic happens, you can shift it where you like
        suggestButton.transform = CGAffineTransform(translationX: -25, y: -2)
        suggestButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: suggestButton.frame)
        suggestButtonContainer.addSubview(suggestButton)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
        
    }
    
    
    /// When back button pressed it will navigate to back page
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
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
    
    
    
    /// After clicking the see more button we will get the poptip
    func easyTipViewSetUpForSeeMore() {
        
        preferences.drawing.font = UIFont.MontserratMedium(.normal)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.textAlignment = NSTextAlignment.center
        preferences.drawing.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashStartColor],
            locations: [0,1],
            size: CGSize(width: self.view.frame.width - 60, height:80)
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
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        easyTipView?.dismiss()
    }
    
    
    
    
    
    /// View model setup to observe the profile model of currentname and profile pic and save all other datas
    //View Model Setup
    func setupViewModel() {
        
        viewModel.profileModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            print("My error is \(statusHttpCode.statusCode)")
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.profileModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            SessionManager.sharedInstance.saveUserDetails["currentUsername"] = "\(value.data?.fname ?? "") \(value.data?.lname ?? "")"
            SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = value.data?.profilepic
            
            SessionManager.sharedInstance.saveGender = value.data?.gender ?? 0
            
            self.profileDetails = value.data
            self.isAPICalled = true
            self.postedTagArray = value.data?.postedTag
            self.selectedImageUrl = value.data?.profilepic ?? ""
            self.isKyc = value.data?.isKYC ?? false
            self.isAgree = value.data?.isAgree ?? 0
            self.accountDetails = value.data?.accountDetails ?? ""
            self.isSkip = value.data?.isSkip ?? false
            
            
            self.countryCode = value.data?.countryCode ?? ""
            
            debugPrint(value.isOk ?? "")
            
            self.title = "\(value.data?.fname ?? "") \(value.data?.lname ?? "")"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    ///Once user update the image after submit it will be updated.
    //Setup save Model
    func setUpSaveObserver() {
        
        viewModel.saveModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.saveModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ProfileTopTableViewCell
                cell?.submitBtn.isHidden = false
                self.showErrorAlert(error: "Profile Picture Updated Successfully")
                
            }
            
        }
        
    }
    
    
    
    ///Top navigation bar setup
    // navigation bar setup
    func navigationSetUp() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
    }
    
    
    
    
    @IBAction func viewProfileButtonTapped(sender:UIButton) {
        
        let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] ?? "")"
        if !(SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] as? String ?? "").isEmpty {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
            vc.url = fullMediaUrl
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    
    /// On pressing the save button it will save all the basic details & payout details
    @objc func saveButtonTapped(sender:UIButton) {
        if isSaved == false{
            let editParamDict = ["fname":viewModel.profileModel.value?.data?.fname ?? "",
                                 "lname":viewModel.profileModel.value?.data?.lname ?? "",
                                 "dob":viewModel.profileModel.value?.data?.dob ?? "",
                                 "gender":viewModel.profileModel.value?.data?.gender ?? 0,
                                 "location":viewModel.profileModel.value?.data?.location ?? "",
                                 "mobilenumber":viewModel.profileModel.value?.data?.mobilenumber ?? "",
                                 "email":viewModel.profileModel.value?.data?.email ?? "",
                                 "aboutme":viewModel.profileModel.value?.data?.aboutme ?? "",
                                 "userId":viewModel.profileModel.value?.data?.userId ?? "",
                                 "profilepic":self.selectedImageUrl,
                                 "countryCode":self.countryCode,
                                 "isSkip": isSkip,
                                 "isKYC":isKyc,
                                 "isAgree":isAgree,
                                 "accountDetails":accountDetails
                                    
                                    
            ] as [String : Any]

            debugPrint("Edit profile params--->",editParamDict)

            viewModel.saveProfileApiCall(params: editParamDict)
            self.isSaved = true
            let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ProfileTopTableViewCell
            cell?.submitBtn.setImage(UIImage(systemName:"square.and.arrow.up"), for: .normal)
        }
        else{
            let userId = SessionManager.sharedInstance.getUserId
           // let post_id = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?._id ?? ""
            //let t_id = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.threadId ?? ""
            let url = "https://www.sparkme.synctag.com/Post/ViewProfile/" + userId
            self.createShortUrl(urlString: url)
        }
       
//
    }
    

    
    
    /// On pressing the edit button it will rediect to edit profile view controller
    @objc func editButtonTapped(sender:UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let editProfileVC = storyBoard.instantiateViewController(identifier: "EditProfileTableViewController") as! EditProfileTableViewController
        editProfileVC.isFromProfile = true
        editProfileVC.profileDetails = profileDetails
        editProfileVC.backFromProfileDelegate = self
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    
    
    /// On Pressing of see more button it will open the multiple tag view controller
    @IBAction func seeMoreButtonTapped(sender:UIButton) {
        easyTipView?.dismiss()
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let postedTagVC = storyBoard.instantiateViewController(identifier: "PostedTagViewController") as! PostedTagViewController
        postedTagVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        postedTagVC.postedTagArray = postedTagArray
        self.present(postedTagVC, animated: true, completion: nil)
    }
    
    
    
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if isLoading{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTopTableViewCell", for: indexPath) as! ProfileTopTableViewCell
                cell.showDummy()
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTopTableViewCell", for: indexPath) as! ProfileTopTableViewCell
                cell.hideDummy()
                cell.connectionDelegate = self
                cell.nameLbl?.font = UIFont.MontserratMedium(.large)
                cell.nameLbl?.textColor = UIColor.white
                cell.emailLbl?.text = viewModel.profileModel.value?.data?.email
                cell.aboutMeLbl?.text = viewModel.profileModel.value?.data?.aboutme
                cell.nameLbl?.text = "\(viewModel.profileModel.value?.data?.fname ?? "") \(viewModel.profileModel.value?.data?.lname ?? "")"
                cell.viewLblCount?.text = "\(viewModel.profileModel.value?.data?.viewCount?.withCommas() ?? "")"
                
                cell.scoreBtn.setTitle("", for: .normal)
                cell.scoreBtn.addTarget(self, action: #selector(insightsButtonTapped(sender:)), for: .touchUpInside)
                
                if viewModel.profileModel.value?.data?.score ?? 0 == 0 {
                    cell.scroreLblCount?.text = "NA"
                }else{
                    cell.scroreLblCount?.text = "\(viewModel.profileModel.value?.data?.score?.withCommas() ?? "")"
                }
                
                cell.aboutSeeMoreBtn?.isUserInteractionEnabled = false
                print("number of lines *****************************")
                print(cell.aboutMeLbl?.numberOfLines)
                if cell.aboutMeLbl?.text?.count ?? 0 > 100 || (cell.aboutMeLbl?.text?.contains("\n") ?? false && cell.aboutMeLbl?.text?.count ?? 0 > 70)   {
                    
                    if viewModel.profileModel.value?.data?.aboutme ?? "" != ""{
                        if cell.aboutMeLbl?.text?.count ?? 0 > 2{
                            cell.aboutSeeMoreBtn?.isUserInteractionEnabled = true
                            let readmoreFontColor = UIColor.lightGray
                            DispatchQueue.main.async {
                                cell.aboutMeLbl?.addTrailing(with: "... ", moreText: "see more", moreTextFont: cell.aboutMeLbl?.font ?? UIFont(), moreTextColor: readmoreFontColor)
                            }
                        }
                    }
//                    cell.aboutSeeMoreBtn?.isUserInteractionEnabled = true
//                    let readmoreFontColor = UIColor.lightGray
//                    DispatchQueue.main.async {
//                        cell.aboutMeLbl?.addTrailing(with: "... ", moreText: "see more", moreTextFont: cell.aboutMeLbl?.font ?? UIFont(), moreTextColor: readmoreFontColor)
//                    }
                    
                }
                
                if viewModel.profileModel.value?.data?.nft == 1{
                    cell.nftImage.isHidden = false
                }
                else{
                    cell.nftImage.isHidden = true
                }
                
                cell.claoLblCount?.text = "\(viewModel.profileModel.value?.data?.clapCount?.withCommas() ?? "")"
                cell.connectionLblCount?.text = "\(viewModel.profileModel.value?.data?.connectionCount?.withCommas() ?? "")"
                
                cell.editBtn?.addTarget(self, action: #selector(editButtonTapped(sender:)), for: .touchUpInside)
                
                let url = URL(string: viewModel.profileModel.value?.data?.profilepic ?? "") ?? NSURL.init() as URL
                
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(url)"
                
                cell.profileImageView?.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModel.profileModel.value?.data?.gender == 1 ?  "no_profile_image_male" : viewModel.profileModel.value?.data?.gender == 2 ? "no_profile_image_female" : "others"))
                
                //                let gradient = CAGradientLayer()
                //                gradient.frame = cell.contentView.bounds
                //                gradient.colors = [UIColor.splashStartColor.cgColor, UIColor.splashEndColor.cgColor]
                //                cell.contentView.layer.insertSublayer(gradient, at: 0)
                
                cell.contentView.backgroundColor = linearGradientColor(
                    from: [.splashStartColor, .splashEndColor],
                    locations: [0,1],
                    size: CGSize(width: 400, height:350))
                
                cell.submitBtn.addTarget(self, action: #selector(saveButtonTapped(sender: )), for: .touchUpInside)
                cell.backBtn.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
                cell.submitBtn.isHidden = false
                self.isSaved = true
                
                return cell
            }
            
            
            //if isAPICalled {
               
        } else if indexPath.section == 1 {
           
            let cellTag = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath) as! TagTableViewCell
            if isLoading{
                cellTag.showDummy()
            }
            else{
                cellTag.hideDummy()
                if let tagCount = viewModel.profileModel.value?.data?.postedTag?.count, tagCount == 0 {
                    cellTag.bgStackview.isHidden = true
                    cellTag.notagLbl.isHidden = false
                } else {
                    
                    //                cellTag.tagBtnOne?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toBottom, for: .normal)
                    //                cellTag.tagBtnTwo?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toBottom, for: .normal)
                    //                cellTag.tagThree?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toBottom, for: .normal)
                    cellTag.notagLbl.isHidden = true
                    cellTag.bgViewOne?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 50, height:80))
                    cellTag.bgViewTwo?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 50, height:80))
                    cellTag.bgViewThree?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 50, height:80))
                    
                    cellTag.tagBtnOne?.setTitleColor(UIColor.white, for: .normal)
                    cellTag.tagBtnTwo?.setTitleColor(UIColor.white, for: .normal)
                    cellTag.tagThree?.setTitleColor(UIColor.white, for: .normal)
                    
                    cellTag.tagBtnOne?.setImage(UIImage.init(named: "spark_logo"), for: .normal)
                    cellTag.tagBtnTwo?.setImage(UIImage.init(named: "spark_logo"), for: .normal)
                    cellTag.tagThree?.setImage(UIImage.init(named: "spark_logo"), for: .normal)
                    
                    cellTag.tagBtnOne?.tag = 0
                    cellTag.tagBtnTwo?.tag = 1
                    cellTag.tagThree?.tag = 2
                    
                    cellTag.tagBtnOne?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    cellTag.tagBtnTwo?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    cellTag.tagThree?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    
                    cellTag.tagOnebgView?.isHidden = false
                    
                    if viewModel.profileModel.value?.data?.postedTag?.count ?? 0 == 1 {
                        cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                        cellTag.seeMoreBtn?.isHidden = false
                        cellTag.tagOnebgView?.isHidden = false
                        cellTag.tagTwobgView?.isHidden = true
                        cellTag.tagThreebgView?.isHidden = true
                    }else if viewModel.profileModel.value?.data?.postedTag?.count ?? 0 == 2 {
                        cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                        cellTag.tagBtnTwo?.setTitle(viewModel.profileModel.value?.data?.postedTag?[1].name, for: .normal)
                        cellTag.tagOnebgView?.isHidden = false
                        cellTag.tagTwobgView?.isHidden = false
                        cellTag.tagThreebgView?.isHidden = true
                        cellTag.seeMoreBtn?.isHidden = false
                    }else if viewModel.profileModel.value?.data?.postedTag?.count ?? 0 >= 3 {
                        cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                        cellTag.tagBtnTwo?.setTitle(viewModel.profileModel.value?.data?.postedTag?[1].name, for: .normal)
                        cellTag.tagThree?.setTitle(viewModel.profileModel.value?.data?.postedTag?[2].name, for: .normal)
                        cellTag.tagOnebgView?.isHidden = false
                        cellTag.tagTwobgView?.isHidden = false
                        cellTag.tagThreebgView?.isHidden = true
                        cellTag.seeMoreBtn?.isHidden = false
                    }
                    else{
                        cellTag.seeMoreBtn?.isHidden = true
                        if ((viewModel.profileModel.value?.data?.postedTag?.count ?? 0) == 1) {
                            cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                            cellTag.tagOnebgView?.isHidden = false
                            cellTag.tagTwobgView?.isHidden = true
                            cellTag.tagThreebgView?.isHidden = true
                        }else if ((viewModel.profileModel.value?.data?.postedTag?.count ?? 0) == 2) {
                            cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                            cellTag.tagBtnTwo?.setTitle(viewModel.profileModel.value?.data?.postedTag?[1].name, for: .normal)
                            cellTag.tagOnebgView?.isHidden = false
                            cellTag.tagTwobgView?.isHidden = false
                            cellTag.tagThreebgView?.isHidden = true
                        }else if ((viewModel.profileModel.value?.data?.postedTag?.count ?? 0) == 3) {
                            cellTag.tagBtnOne?.setTitle(viewModel.profileModel.value?.data?.postedTag?[0].name, for: .normal)
                            cellTag.tagBtnTwo?.setTitle(viewModel.profileModel.value?.data?.postedTag?[1].name, for: .normal)
                            cellTag.tagThree?.setTitle(viewModel.profileModel.value?.data?.postedTag?[2].name, for: .normal)
                            cellTag.tagOnebgView?.isHidden = false
                            cellTag.tagTwobgView?.isHidden = false
                            cellTag.tagThreebgView?.isHidden = true
                        }
                        
                    }
                    
                    cellTag.seeMoreBtn?.setTitle("View Details", for: .normal)
                }
            }
            
            return cellTag
            
        }
        
        else {
            let timelineCell = tableView.dequeueReusableCell(withIdentifier: "TimelineImageTableViewCell", for: indexPath) as? TimelineImageTableViewCell
            if isLoading{
                timelineCell?.showDummy()
                timelineCell?.viewModel.feedListData = []
            }
            else{
                timelineCell?.hideDummy()
                timelineCell?.delegate = self
                //timelineCell?.setupTimelineViewModel()
                timelineCell?.reloadDelegate = self
                timelineCell?.tableView = self.tableView
               // timelineCell?.getMyTimelineListValues(PageNumber: 1, PageSize: timelineCell?.limit ?? 0, postType: 1)
               // timelineCell?.isLoading = self.isLoading
            }
            
          
            
            return timelineCell ?? UITableViewCell.init()
        }
        return UITableViewCell()
    }
    
    
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    /// Asks the delegate for the height to use for a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
    ///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1{
            
            return 110//UITableView.automaticDimension
        }
        else if indexPath.section == 2{
            return 600
        }
        else{
            return UITableView.automaticDimension
        }
        
       // return indexPath.section == 2 ? 600 : indexPath.section == 1 ? viewModel.profileModel.value?.data?.postedTag?.count == 0 ? 0 : UITableView.automaticDimension :  UITableView.automaticDimension
        
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
    
    
    

    /// Asks the delegate for the estimated height of a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be. Return automaticDimension if you have no estimate.
    ///  - Providing an estimate the height of rows can improve the user experience when loading the table view. If the table contains variable height rows, it might be expensive to calculate all their heights and so lead to a longer load time. Using estimation allows you to defer some of the cost of geometry calculation from load time to scrolling time.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            
            return 110//UITableView.automaticDimension
        }
        else if indexPath.section == 2{
            return 600
        }
        else{
            return UITableView.automaticDimension
        }
        
        //return indexPath.section == 2 ? 600 : indexPath.section == 1 ? viewModel.profileModel.value?.data?.postedTag?.count == 0 ? 0 : UITableView.automaticDimension :  UITableView.automaticDimension
    }
    
    
    
    ///On tapping the insights button it will redirect to WalletViewController
    @objc func insightsButtonTapped(sender:UIButton) {
        
        let nftData = viewModel.profileModel.value?.data?.nft ?? 0
        if nftData == 1{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
            vc.userId = SessionManager.sharedInstance.getUserId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            self.showErrorAlert(error: "You are currently not eligible for NFT, to enable your NFT feature to create 500 connections or connect with us by going to the settings and choosing the support inbox")
        }
    }
    
    
    
    ///On pressing the tag button it will shows the poptip of the complete tag
    @objc func tagButtonTapped(sender:UIButton) {
        easyTipViewSetUp()
        easyTipView?.dismiss()
        
        if sender.tag == 0{
            
            easyTipView = EasyTipView(text: viewModel.profileModel.value?.data?.postedTag?[sender.tag].name ?? "", preferences: preferences)
            easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
        }else if sender.tag == 1{
            
            easyTipView = EasyTipView(text: viewModel.profileModel.value?.data?.postedTag?[sender.tag].name ?? "", preferences: preferences)
            easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
        }else if sender.tag == 2{
            
            easyTipView = EasyTipView(text: viewModel.profileModel.value?.data?.postedTag?[sender.tag].name ?? "", preferences: preferences)
            easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
        }
        
    }
    
    
}


protocol connectionListDelegate : AnyObject {
    ///Connection button pressed to show connectionList has been displayed
    func connectionListTappedFunction()
    
    
    ///Read more button tapped to read all the tags
    func readMoreButtonTappedFunction(sender: UIButton)
}


class timelineTableViewCell:UITableViewCell {
    
    @IBOutlet var titleLbl:UILabel?
    @IBOutlet var dateLbl:UILabel?
    @IBOutlet var postImageView:UIImageView?
    @IBOutlet var bgView:UIView?
    @IBOutlet weak var viewCountBtn: UIButton!
    @IBOutlet weak var connectionCountBtn: UIButton!
    @IBOutlet weak var clapsCountBtn: UIButton!
    
    
}

protocol sparklinesReloadDelegate{
    func reloadTableViewIndex()
}

////#MARK: Collectionview Cell Class - Tag Cell
//class tagTableViewCell: UITableViewCell {
//
//
//}

extension ProfileViewController : sparklinesReloadDelegate{
    
    ///Reload the tableview index of spark lines
    func reloadTableViewIndex() {
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .bottom)
    }
    
    
}

extension NSDate {
    var ageCalculation: Int {
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        let now = calendar.startOfDay(for: NSDate() as Date)
        let birthdate = calendar.startOfDay(for: self as Date)
        let components = calendar.components(.year, from: birthdate, to: now, options: [])
        return components.year ?? 0
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate {
    ///This method is used access the gallary images from iphone
    @IBAction func cameraButtonTapped(sender:UIButton) {
        
        let alertController = UIAlertController(title: "Profile Image", message: "Please select your profile image", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.croppingStyle = .default
            self.imageFrame = .presetSquare
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let profileAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.cameraSelected()
        }
        
        let cencelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(defaultAction)
        alertController.addAction(profileAction)
        alertController.addAction(cencelAction)
        
        // let presentationController = alertController.popoverPresentationController
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    ///When camera selected it asks for permission
    /// - It can be set to allow or deny
    ///  - If its a simulator it will show the alert
    func cameraSelected() {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        if UIImagePickerController.isSourceTypeAvailable(.camera) != nil {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
                case .authorized:
                    showCameraPicker()
                case .denied:
                    alertPromptToAllowCameraAccessViaSettings()
                case .notDetermined:
                    permissionPrimeCameraAccess()
                default:
                    permissionPrimeCameraAccess()
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                //Analytics.track(event: .permissionsPrimeCameraNoCamera)
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }


    /// Alert will popup for camera settings permission
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "\"Spark Me\" Would Like To Access the Camera", message: "Please grant permission to use the Camera so that you can upload images.", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
            //Analytics.track(event: .permissionsPrimeCameraOpenSettings)
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(appSettingsURL as URL)
            }
        })
        present(alert, animated: true, completion: nil)
    }


    /// Alert  will show camera permission access
    func permissionPrimeCameraAccess() {
        let alert = UIAlertController( title: "\"Spark Me\" Would Like To Access the Camera", message: "Please allow to access your Camera so that you can upload images.", preferredStyle: .alert )
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            //Analytics.track(event: .permissionsPrimeCameraAccepted)
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                    DispatchQueue.main.async {
                        self?.cameraSelected() // try again
                    }
                })
            }
        })
        alert.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
           // Analytics.track(event: .permissionsPrimeCameraCancelled)
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }

    
    
    
    /// Alert will show camera picker to select the image in album
    func showCameraPicker() {
        self.croppingStyle = .default
        self.imageFrame = .presetSquare
        
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .popover
        imagePicker.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}




extension ProfileViewController : CropViewControllerDelegate {
    
    
    /// Tells the delegate that the user picked a still image or movie.
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - info: A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in UIImagePickerController.InfoKey.
    ///   - Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
    ///   - When editing is enabled, the image picker view presents the user with a preview of the currently selected image or movie along with controls for modifying it. (This behavior is managed by the picker view prior to calling this method.) If the - - - user modifies the image or movie, the editing information is available in the info parameter. The original image is also returned in the info parameter.
    ///   - If you set the image picker’s showsCameraControls property to false and provide your own custom controls, you can take multiple pictures before dismissing the image picker interface. However, if you set that property to true, your - delegate must dismiss the image picker interface after the user takes one picture or cancels the operation.
    ///   - Implementation of this method is optional, but expected.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        //cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self
        
        picker.dismiss(animated: true, completion: {
            self.present(cropController, animated: true, completion: nil)
        })
    }
    
    
    
    
    /// Called when the user has committed the crop action, and provides both the original image with crop co-ordinates.
    
    /// - Parameters:
    /// - image: The newly cropped image.
    /// - cropRect: A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
    /// - angle The angle of the image when it was cropped
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    
    
    
    
    /// If the cropping style is set to circular, implementing this delegate will return a circle-cropped version of the selected image, as well as it's cropping co-ordinates
    
    /// - Parameters:
   ///    - image: The newly cropped image, clipped to a circle shape
   ///    - cropRect:  A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
   ///    - angle: The angle of the image when it was cropped
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    
    
    
    /// Update imageview with uploading image to aws
    /// - Parameters:
    ///   - image: Set the uiimage
    ///   - cropViewController: After cropping trhe image we can set here
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        
        DispatchQueue.main.async {
            RSLoadingView().showOnKeyWindow()
            let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ProfileTopTableViewCell
            cell?.profileImageView?.image = image
        }
        
        if selectedImageUrl.isEmpty {
            AzureManager.shared.uploadDataFromAws(folderName: "profilepic", image: image) { isSuccess, error, url in
                if isSuccess {
                    self.selectedImageUrl = url
                    SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = url
                    debugPrint("Profile picture updated successfully")
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ProfileTopTableViewCell
                        cell?.submitBtn.setImage(UIImage(named: "profileTick"), for: .normal)
                        self.isSaved = false
                        
                    }
                }
            }
            return
        }
        
        AzureManager.shared.deleteDataFromAws(key: selectedImageUrl) { success, error, url in
            debugPrint(success)
            if success {
                AzureManager.shared.uploadDataFromAws(folderName: "profilepic", image: image) { isSuccess, error, url in
                    if isSuccess {
                        
                        DispatchQueue.main.async {
                            let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? ProfileTopTableViewCell
                            cell?.submitBtn.isHidden = false
                            RSLoadingView.hideFromKeyWindow()
                            
                            self.selectedImageUrl = url
                            SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = url
                            cell?.submitBtn.setImage(UIImage(named: "profileTick"), for: .normal)
                            self.isSaved = false
                            
                            //self.saveButtonTapped(sender: UIButton())
                        }
                        
                        debugPrint("Profile picture uploaded successfully")
                    }
                }
            }
        }
        
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
}

extension ProfileViewController : connectionListDelegate {
    
    /// Readmore button tapped for see the pop tip
    func readMoreButtonTappedFunction(sender: UIButton) {
        
        easyTipViewSetUpForSeeMore()
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: viewModel.profileModel.value?.data?.aboutme ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
    }
    
    
    /// ConnectionList tap method is used to redirect to ConnectionListViewController
    func connectionListTappedFunction() {
        
        // connection List page redirection
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: CONNECTION_LIST_STORYBOARD) as! ConnectionListViewController
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
}

extension UILabel{
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            print("this number \(safeTrimmedString.count) should never be less\n")
            print("then this number \(readMoreLength)")
            
            // "safeTrimmedString.count - readMoreLength" should never be less then the readMoreLength because it'll be a negative value and will crash
            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
