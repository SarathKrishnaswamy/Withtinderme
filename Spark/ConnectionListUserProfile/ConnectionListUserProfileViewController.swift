//
//  ConnectionListUserProfileViewController.swift
//  Spark me
//
//  Created by adhash on 31/08/21.
//

import UIKit
import EasyTipView
import FirebaseDynamicLinks
import UIView_Shimmer

/**
 This class is used to set show the connection of other user profile page.
 */

class ConnectionListUserProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,backFromProfileDelegate {
    
    func backandReload() {
        print("reloading")
        // let indexPath = IndexPath(row: 0, section: 3)
        //        if let cell = connectionListUserProfileTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ConnectionListUserTimelineImageTableViewCell {
        //            cell.setupTimelineViewModel()
        //            cell.global()
        //            cell.collectionView.reloadData()
        //        }
        
    }
    var tagArray = ["Art","Tech","Nature"]
    @IBOutlet var connectionListUserProfileTableView:UITableView!
    var isSeeMoreTapped = false
    var viewModel = ConnectionListUserProfileViewModel()
    
    var profileDetails:GetProfileData?
    
    
    
    var postedTagArray:[PostedTag]?
    
    @IBOutlet weak var userImageView: customImageView!
    var selectedImageUrl = ""
    
    //paginator
    var loadingData = false
    var isAPICalled = false
    
    var basepostId = ""
    var baseuserId = ""
    var basethreadId = ""
    
    let historyBtn = UIButton(type: .custom)
    
    var userId = ""
    
    var preferences = EasyTipView.Preferences()
    var membersList : [MembersList]?
    
    var easyTipView : EasyTipView?
    var alertController = UIAlertController()
    
    
    
    var clapOnTap : Bool = false
    var isLoopConversation = false
    var indexPath : Int?
    
    var type = 0
    var isLoading = false
    var backDelegate : backfromFeedDelegate?
    var isMessageList = false
    var isFromNotification = false
    var isFromHomePage = false
    var isFromBubble = false
    var isThread = 0
    var linkPostId = ""
   
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationSetUp()
        //  backButtonSetUp()
        SessionManager.sharedInstance.otherUserId = userId
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(statusManager),name: .flagsChanged,object: nil)
        updateUserInterface()
        MaininternetRetry()
        
        
        
        
        easyTipViewSetUp()
    }
    
    
    /// Update the user interface with internet is wifi, mobile or not connected
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            MaininternetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            //self.alertController.dismiss(animated: true)
            
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            //self.alertController.dismiss(animated: true)
            
            //view.backgroundColor = .green
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    /// Send the statusmanager to update the user interface
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    /// Internet retry will happen when it is internet connected with api calling
    func MaininternetRetry(){
        if Connection.isConnectedToNetwork(){
            print("Connected")
            setupViewModel()
            setUpSaveObserver()
            let closedConnectionDict = [
                "userId":userId,
                "paginator":[
                    "nextPage": 1,
                    "pageNumber": 0,
                    "pageSize": 10,
                    "previousPage": 0,
                    "totalPages": 2
                ]
            ] as [String : Any]
            
            viewModel.getProfileAPICallNoLoading(postDict: closedConnectionDict)
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
    
    
    /// Show the poptip for vieing the tag page.
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
    
    ///Show the poptip for view more about their bio
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
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        easyTipView?.dismiss()
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
        self.isLoading = true
        //self.TimeLineApiCalled = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2349898517, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        var frame = connectionListUserProfileTableView.bounds
        
        frame.origin.y = -frame.size.height
        
        let backgroundView = UIView(frame: frame)
        
        backgroundView.autoresizingMask = .flexibleWidth
        
        backgroundView.backgroundColor = #colorLiteral(red: 0.2349898517, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        
        // Adding the view below the refresh control
        connectionListUserProfileTableView.insertSubview(backgroundView, at: 0)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("listenProfiletLink"), object: nil)
    }
    
    //    func backButtonSetUp() {
    //
    //        // create the button
    //        let suggestImage  = #imageLiteral(resourceName: "profileBack").withRenderingMode(.alwaysOriginal)
    //        let suggestButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    //        suggestButton.setBackgroundImage(suggestImage, for: .normal)
    //
    //        // here where the magic happens, you can shift it where you like
    //        suggestButton.transform = CGAffineTransform(translationX: -25, y: -2)
    //        suggestButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    //
    //        // add the button to a container, otherwise the transform will be ignored
    //        let suggestButtonContainer = UIView(frame: suggestButton.frame)
    //        suggestButtonContainer.addSubview(suggestButton)
    //        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
    //
    //        self.navigationItem.leftBarButtonItem = suggestButtonItem
    //
    //    }
    
    
    /// Dsimiss the current page
    @objc func backButtonPressed() {
        
        
        navigationController?.popViewController(animated: true)
        self.backDelegate?.back(postId: basepostId, threadId: basethreadId, userId: baseuserId, memberList:self.membersList ?? [MembersList](), messageListApproved: isMessageList, isFromLoopConversation: isLoopConversation, isFromNotify:isFromNotification, isFromHome: isFromHomePage, isFromBubble: isFromBubble, isThread: self.isThread, linkPostId: self.linkPostId)
        
        
    }
    
    ///View Model Setup is used to observe the all the values from post api calls with reload the table datas
    func setupViewModel() {
        
        viewModel.profileModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
           
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        viewModel.profileModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            
            self.profileDetails = value.data
            self.isAPICalled = true
            self.postedTagArray = value.data?.postedTag
            self.selectedImageUrl = value.data?.profilepic ?? ""
            
            debugPrint(value.isOk ?? "")
            self.title = "\(value.data?.fname ?? "") \(value.data?.lname ?? "")"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.isLoading = false
                self.connectionListUserProfileTableView.reloadData()
            }
            
        }
        
    }
    
    ///Setup save Model if the profile updated it will show the profile updated successfully
    func setUpSaveObserver() {
        
        viewModel.saveModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.saveModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                self.historyBtn.isHidden = true
                self.showErrorAlert(error: "Profile Picture Updated Successfully")
                
            }
            
        }
        
    }
    
    
    /// navigation bar setup
    func navigationSetUp() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3107562661, green: 0.3148337007, blue: 0.5032022595, alpha: 1)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
    }
    
    /// See more button tapped to open 
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
        //        if viewModel.profileModel.value?.data?.postedTag?.count == 0 && section == 1 {
        //
        return 1
        //        }
        //        if isAPICalled{
        //            if isLoading{
        //                return 1
        //            }
        //            else{
        //                return 1
        //            }
        //        }
        //        else{
        //            return 0
        //        }
        
        //return  isAPICalled ? 1 : 0
        
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
            // if isAPICalled {
            if isLoading{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionListProfileTableViewCell", for: indexPath) as! ConnectionListProfileTableViewCell
                cell.showDummy()
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionListProfileTableViewCell", for: indexPath) as! ConnectionListProfileTableViewCell
                cell.hideDummy()
                cell.connectionDelegate = self
                cell.nameLbl?.font = UIFont.MontserratMedium(.large)
                cell.nameLbl?.textColor = UIColor.white
                cell.nameLbl?.text = "\(viewModel.profileModel.value?.data?.fname ?? "") \(viewModel.profileModel.value?.data?.lname ?? "")"
                cell.aboutMeLbl?.text = viewModel.profileModel.value?.data?.aboutme
                cell.emailLbl?.text = viewModel.profileModel.value?.data?.email
                
                cell.viewLblCount?.text = "\(viewModel.profileModel.value?.data?.viewCount?.withCommas() ?? "")"
                
                cell.scoreBtn.setTitle("", for: .normal)
                cell.scoreBtn.addTarget(self, action: #selector(insightsButtonTapped(sender:)), for: .touchUpInside)
                
                if viewModel.profileModel.value?.data?.score ?? 0 == 0 {
                    cell.scroreLblCount?.text = "NA"
                }else{
                    cell.scroreLblCount?.text = "\(viewModel.profileModel.value?.data?.score?.withCommas() ?? "")"
                }
                
                cell.claoLblCount?.text = "\(viewModel.profileModel.value?.data?.clapCount?.withCommas() ?? "")"
                cell.connectionLblCount?.text = "\(viewModel.profileModel.value?.data?.connectionCount?.withCommas() ?? "")"
                //                cell.mobileNumberLbl?.text = viewModel.profileModel.value?.data?.mobilenumber
                cell.aboutSeeMoreBtn?.isUserInteractionEnabled = false
                print("number of lines ************************************")
                print(cell.aboutMeLbl?.numberOfLines ?? 0)
                
                if cell.aboutMeLbl?.text?.count ?? 0 > 100 || (cell.aboutMeLbl?.text?.contains("\n") ?? false && cell.aboutMeLbl?.text?.count ?? 0 > 70) {
                
                    if viewModel.profileModel.value?.data?.aboutme ?? "" != ""{
                        if cell.aboutMeLbl?.text?.count ?? 0 > 2{
                            cell.aboutSeeMoreBtn?.isUserInteractionEnabled = true
                            let readmoreFontColor = UIColor.lightGray
                            DispatchQueue.main.async {
                                cell.aboutMeLbl?.addTrailing(with: "... ", moreText: "see more", moreTextFont: cell.aboutMeLbl?.font ?? UIFont(), moreTextColor: readmoreFontColor)
                            }
                        }
                    }
                   
                    
                }
                
                if viewModel.profileModel.value?.data?.nft == 1{
                    cell.nftImage.isHidden = false
                }
                else{
                    cell.nftImage.isHidden = true
                }
                
                let url = URL(string: viewModel.profileModel.value?.data?.profilepic ?? "") ?? NSURL.init() as URL
                
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(url)"
                cell.profileImageView?.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModel.profileModel.value?.data?.gender == 1 ?  "no_profile_image_male" : viewModel.profileModel.value?.data?.gender == 2 ? "no_profile_image_female" : "others"))
                
                cell.contentView.backgroundColor = linearGradientColor(
                    from: [.splashStartColor, .splashEndColor],
                    locations: [0,1],
                    size: CGSize(width: 400, height:300))
                
                cell.backBtn.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
                
                return cell
            }
            
            // }
        } else if indexPath.section == 1 {
            
            
            let cellTag = tableView.dequeueReusableCell(withIdentifier: "ConnectionListProfileTagTableViewCell", for: indexPath) as! ConnectionListProfileTagTableViewCell
            
            if isLoading{
                cellTag.showDummy()
            }
            else{
                cellTag.hideDummy()
                if let tagCount = viewModel.profileModel.value?.data?.postedTag?.count, tagCount == 0 {
                    cellTag.bgStackview.isHidden = true
                    cellTag.noTagsLbl.isHidden = false
                } else {
                    
                    cellTag.bgViewOne?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 80, height:80))
                    cellTag.bgViewTwo?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 80, height:80))
                    cellTag.bgViewThree?.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0,1],
                        size: CGSize(width: 80, height:80))
                    
                    cellTag.tagBtnOne?.tag = 0
                    cellTag.tagBtnTwo?.tag = 1
                    cellTag.tagThree?.tag = 2
                    
                    cellTag.tagBtnOne?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    cellTag.tagBtnTwo?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    cellTag.tagThree?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
                    
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
            let timelineCell = tableView.dequeueReusableCell(withIdentifier: "ConnectionListUserTimelineImageTableViewCell", for: indexPath) as? ConnectionListUserTimelineImageTableViewCell
            timelineCell?.userId = userId
            if isLoading{
                timelineCell?.showDummy()
                timelineCell?.setupCollectionView()
                timelineCell?.parentVC = self
                
                
                
                //
                
            }
            else{
                timelineCell?.hideDummy()
                
                timelineCell?.delegate = self
                
                
                timelineCell?.sparklinereloadDelegate = self
                
                
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
        
        //return indexPath.section == 2 ? 600 : indexPath.section == 1 ? viewModel.profileModel.value?.data?.postedTag?.count == 0 ? 0 : UITableView.automaticDimension :  UITableView.automaticDimension
        
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
    
    
    
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    /// - Parameters:
    ///   - tableView: The table view informing the delegate of this impending event.
    ///   - cell: A cell that tableView is going to use when drawing the row.
    ///   - indexPath: An index path locating the row in tableView.
    ///   - A table view sends this message to its delegate just before it uses cell to draw a row, thereby permitting the delegate to customize the cell object before it is displayed. This method gives the delegate a chance to override state-based properties set earlier by the table view, such as selection and background color. After the delegate returns, the table view sets only the alpha and frame properties, and then only when animating rows as they slide in or out.

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        
    }
    
    
    /// Insight button tapped to open the wallet view page
    @objc func insightsButtonTapped(sender:UIButton) {
        
        let nftData = viewModel.profileModel.value?.data?.nft ?? 0
        
        if nftData == 1 {
            if viewModel.profileModel.value?.data?.score ?? 0 == 0 {
                self.showErrorAlert(error: "No NFT's yet")
            }else{
                //                let nftData = viewModel.profileModel.value?.data?.nft ?? 0
                //                if nftData == 1{
                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                vc.userId = viewModel.profileModel.value?.data?.userId ?? ""
                
                self.navigationController?.pushViewController(vc, animated: true)
                //                }
                //                else{
                //                    self.showErrorAlert(error: "You are currently not eligible for NFT, to enable your NFT feature to create 500 connections or connect with us by going to the settings and choosing the support inbox")
                //                }
            }
        }
    }
    
    /// Tag button is used to show the poptip of each tag
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

protocol connectionListUserprofileDelegate : AnyObject {
    
    func readMoreButtonTappedFunction(sender: UIButton)
}

protocol connectionTimelineDelegate{
    func stopLoader()
}


extension ConnectionListUserProfileViewController : sparklinesReloadDelegate{
    /// Reload the tableview index
    func reloadTableViewIndex() {
        self.connectionListUserProfileTableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .bottom)
    }
    
    
}

//#MARK: Collectionview Cell Class - TimeLine Cell




//#MARK: Collectionview Cell Class - Tag Cell

extension ConnectionListUserProfileViewController : ConnectionUserListTimeLineDelegate {
    /// Open the selected timeline data to open the feed detail page
    func getSelectedTimelineData(postId: String, threadId: String, isFromBubble: Bool) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
        detailVC.postId = postId
        detailVC.threadId = threadId
        
        detailVC.myPostId = postId
        detailVC.myThreadId = threadId
        
        
        SessionManager.sharedInstance.userIdFromSelectedBubbleList = userId
        detailVC.backFromOtherProfileDelegate = self
        detailVC.isFromConnectionList = true
        
        // detailVC.baseUserLinkUserId =
        SessionManager.sharedInstance.threadId = threadId
        detailVC.isFromBubble = false
        //detailVC.isFromConnectionList = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ConnectionListUserProfileViewController : connectionListUserprofileDelegate {
    /// Read more in bio will open the poptip of bio
    func readMoreButtonTappedFunction(sender: UIButton) {
        
        easyTipViewSetUpForSeeMore()
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: viewModel.profileModel.value?.data?.aboutme ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
