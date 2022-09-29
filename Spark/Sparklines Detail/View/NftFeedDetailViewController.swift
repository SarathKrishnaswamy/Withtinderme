//
//  NftFeedDetailViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/02/22.
//

import UIKit
import EasyTipView
import Toaster
import AVKit
import FirebaseDynamicLinks


/**
 This class is used to set the complete details of NFT post, properties and we can transfer the ownership to other persons
 */
class NftFeedDetailViewController: UIViewController, feedTableDelegate, feedNftTableDelegate, getPlayerVideoDelegate, backFromOverlay {
   
    
    /// Profile button is tapped to open the other user profile page
    func profileButtonTapped(sender: UITapGestureRecognizer) {
        if viewModel.nftDetailModel.value?.allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = viewModel.nftDetailModel.value?.userId ?? ""
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    
    
    /// Profile button is tapped to open the other user profile page
    func profileButtonTapped(sender: UIButton) {
        if viewModel.nftDetailModel.value?.allowAnonymous ?? false == false {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
            connectionListVC.userId = viewModel.nftDetailModel.value?.userId ?? ""
            self.navigationController?.pushViewController(connectionListVC, animated: true)
        }
    }
    
    
    /// Dsimiss overlay with the userId and indexPath have been used to open the ConnectionList other user profile page
    func dismissOverlay(userId: String,IndexPath:Int) {
        print("Back from view")
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        connectionListVC.indexPath = IndexPath
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var transferBtn: UIButton!
    @IBOutlet weak var walletInputTextFld: UITextField!
    @IBOutlet weak var shareBtn: UIImageView!
    
    var backDelegate : backfromFeedDelegate?
    var isPlayerFullScreenDismissed = false
    
    var postId = ""
    var viewModel = NftSparkViewModel()
    var userId = ""
    var propertyTraitType = [String]()
    var propertyValue = [String]()
    var boostTraitType = [String]()
    var boostValue = [String]()
   
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.TableView?.register(UINib(nibName: "FeedNftTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedNftTableViewCell")
        setUpNFTDetailObserver()
        setUpTransferNFTDetailsObserver()
        detailWallet()
        
        //        TableView.tableFooterView = footerView
        
        transferBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        transferBtn.layer.cornerRadius = 0
        transferBtn.clipsToBounds = true
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector:#selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareLink(_:)))
        shareBtn.addGestureRecognizer(shareTap)
        shareBtn.isUserInteractionEnabled = true
        
        if userId == SessionManager.sharedInstance.getUserId{
            self.transferBtn.isHidden = false
        }
        else{
            self.transferBtn.isHidden = true
        }
        
    }
    
    
    /// App moved to background
    @objc func appMovedToBackground() {
        print("App moved to background!")
        
    }
                                    
    
    
    /// App moved to foreground
    @objc func appMovedToForeground() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = TableView?.cellForRow(at: indexPath) as? FeedNftTableViewCell
        cell?.playerController?.player?.pause()
    }
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation
    override func viewWillDisappear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = TableView?.cellForRow(at: indexPath) as? FeedNftTableViewCell
        cell?.playerController?.player?.pause()
    }
    
    
    /// Dismiss the Full screen video when we have the video to play
    func fullVideoScreenDismiss(currentSeconds: Double) {
        isPlayerFullScreenDismissed = true
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = TableView?.cellForRow(at: indexPath) as? FeedNftTableViewCell
        let newTime = CMTime(seconds: Double(currentSeconds), preferredTimescale: 600)
        cell?.player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        cell?.player?.pause()
        cell?.playToggle = 1
    }
    
    
    /// Setup the NFT observer and set all the values in the table and reload the data
    func setUpNFTDetailObserver() {
        
        viewModel.nftDetailModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.nftDetailModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            self.TableView.reloadData()
            
        }
        
    }
    
    
    /// Setup the transfer details observer  with error alert
    func setUpTransferNFTDetailsObserver() {
        
        viewModel.transferNftDetailModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.transferNftDetailModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            self.showErrorAlert(error: value.data?.message ?? "")
        }
        
    }
    
    /// Call the api of detail wallet to get all the datas
    func detailWallet(){
        let param = ["post":postId] as [String : Any]
        viewModel.getNFTDetailApiCall(params: param)
    }
    
    
    /// back button tapped to dimiss the controller
    @IBAction func BackBtnOnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension NftFeedDetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NftDescriptionTableViewCell", for: indexPath) as! NftDescriptionTableViewCell
            //cell.descriptiontextView.text = viewModel.nftDetailModel.value?.postContent ?? ""
            cell.descriptiontextView.text = viewModel.nftDetailModel.value?.postContent ?? ""
            cell.ContractAddressLbl.setTitle(viewModel.nftDetailModel.value?.nftAddress ?? "", for: .normal)
            cell.ContractAddressLbl.addTarget(self, action: #selector(callAddress), for: .touchUpInside)
            //cell.ContractAddressLbl.text = viewModel.nftDetailModel.value?.nftAddress ?? ""
            cell.TokenIdLbl.text = viewModel.nftDetailModel.value?.nfttokenId
            let nftArray = viewModel.nftDetailModel.value?.nftAttributes
            //print(nftArray?.count)
            
            if nftArray?.count == 0 || nftArray?.count == nil{
                cell.propertiesView.isHidden = true
                cell.propertiesBaseView.isHidden = true
                cell.boostBaseView.isHidden = true
                cell.bosstView.isHidden = true
                cell.calendarBaseView.isHidden = true
                cell.calendarBgView.isHidden = true
                
            }
            else{
                
//                cell.propertiesView.isHidden = false
//                cell.propertiesBaseView.isHidden = false
//                cell.boostBaseView.isHidden = false
//                cell.bosstView.isHidden = false
//                cell.calendarBaseView.isHidden = false
//                cell.calendarBgView.isHidden = false
                nftArray?.forEach({ data in
                    if data.display_type == nil{
                        self.propertyTraitType.append(data.trait_type ?? "")
                        self.propertyValue.append(data.value ?? "")
                        if self.propertyTraitType.count == self.propertyValue.count{
                            cell.propertiesView.isHidden = false
                            cell.propertiesBaseView.isHidden = false
                            switch self.propertyTraitType.count {
                            case 1:
                                cell.propertyView1.isHidden = false
                                cell.propertyView2.isHidden = true
                                cell.propertyView3.isHidden = true
                                cell.property1Lbl.text = self.propertyTraitType[0]
                                cell.traitType1Lbl.text = self.propertyValue[0]
                            case 2:
                                cell.propertyView1.isHidden = false
                                cell.propertyView2.isHidden = false
                                cell.propertyView3.isHidden = true
                                cell.property1Lbl.text = self.propertyTraitType[0]
                                cell.traitType1Lbl.text = self.propertyValue[0]
                                cell.property2Lbl.text = self.propertyTraitType[1]
                                cell.traitType2Lbl.text = self.propertyValue[1]
                            case 3:
                                cell.propertyView1.isHidden = false
                                cell.propertyView2.isHidden = false
                                cell.propertyView3.isHidden = false
                                cell.property1Lbl.text = self.propertyTraitType[0]
                                cell.traitType1Lbl.text = self.propertyValue[0]
                                cell.property2Lbl.text = self.propertyTraitType[1]
                                cell.traitType2Lbl.text = self.propertyValue[1]
                                cell.property3Lbl.text = self.propertyTraitType[2]
                                cell.traitType3Lbl.text = self.propertyValue[2]
                            default:
                                cell.propertyView1.isHidden = true
                                cell.propertyView2.isHidden = true
                                cell.propertyView3.isHidden = true
                            }
                        }
                        else if propertyTraitType.count == 0 || propertyValue.count == 0{
                            cell.propertiesView.isHidden = true
                            cell.propertiesBaseView.isHidden = true
                        }
                        print(self.propertyTraitType)
                        print(self.propertyValue)
                    }
                    else if data.display_type?.contains("boost") == true{
                        print(data.trait_type ?? "")
                        print(data.value ?? "")
                        self.boostTraitType.append(data.trait_type ?? "")
                        self.boostValue.append(data.value ?? "")
                        if self.boostTraitType.count == self.boostValue.count{
                            cell.boostBaseView.isHidden = false
                            cell.bosstView.isHidden = false
                            switch self.boostTraitType.count {
                            case 1:
                                cell.boost1StackView.isHidden = false
                                cell.boost2StackView.isHidden = true
                                cell.boost3StackView.isHidden = true
                                cell.boost1Lbl.text = self.boostTraitType[0]
                                let value = self.boostValue[0]
                                cell.bosstCircle1.value = CGFloat(truncating: NumberFormatter().number(from: value)!)
                                
                            case 2:
                                cell.boost1StackView.isHidden = false
                                cell.boost2StackView.isHidden = false
                                cell.boost3StackView.isHidden = true
                                cell.boost1Lbl.text = self.boostTraitType[0]
                                let value = self.boostValue[0]
                                cell.bosstCircle1.value = CGFloat(truncating: NumberFormatter().number(from: value)!)
                                
                                cell.boost2Lbl.text = self.boostTraitType[1]
                                let value1 = self.boostValue[1]
                                cell.bosstCircle2.value = CGFloat(truncating: NumberFormatter().number(from: value1)!)
                            case 3:
                                cell.boost1StackView.isHidden = false
                                cell.boost2StackView.isHidden = false
                                cell.boost3StackView.isHidden = false
                                cell.boost1Lbl.text = self.boostTraitType[0]
                                let value = self.boostValue[0]
                                cell.bosstCircle1.value = CGFloat(truncating: NumberFormatter().number(from: value)!)
                                cell.bosstCircle1.startProgress(to: CGFloat(truncating: NumberFormatter().number(from: value)!), duration: 0.4, completion: nil)
                                
                                cell.boost2Lbl.text = self.boostTraitType[1]
                                let value1 = self.boostValue[1]
                                cell.bosstCircle2.value = CGFloat(truncating: NumberFormatter().number(from: value1)!)
                                cell.bosstCircle2.startProgress(to: CGFloat(truncating: NumberFormatter().number(from: value1)!), duration: 1, completion: nil)
                                
                                cell.boost3Lbl.text = self.boostTraitType[2]
                                let value2 = self.boostValue[2]
                                cell.bosstCircle3.value = CGFloat(truncating: NumberFormatter().number(from: value2)!)
                                cell.bosstCircle3.startProgress(to: CGFloat(truncating: NumberFormatter().number(from: value2)!), duration: 1.5, completion: nil)
                            default:
                                cell.propertyView1.isHidden = true
                                cell.propertyView2.isHidden = true
                                cell.propertyView3.isHidden = true
                                cell.boost1StackView.isHidden = true
                                cell.boost2StackView.isHidden = true
                                cell.boost2StackView.isHidden = true
                                cell.bosstView.isHidden = true
                            }
                        }
                        else if boostTraitType.count == 0 || boostValue.count == 0{
                            cell.boostBaseView.isHidden = true
                            cell.bosstView.isHidden = true
                        }
                    }
                    else if data.display_type == "date"{
                        print(data.trait_type ?? "")
                        print(data.value ?? "")
                        
                        if data.trait_type ?? "" == "" || data.value ?? "" == ""{
                            cell.calendarBgView.isHidden = true
                            cell.calendarBaseView.isHidden = true
                        }
                        else{
                            cell.calendarBgView.isHidden = false
                            cell.calendarBaseView.isHidden = false
                            cell.dateLbl1.text = data.trait_type ?? ""
                            let date = convertTimeStampToDOBMonth(timeStamp: data.value ?? "")
                            cell.dateValueLbl.text = date//data.value ?? ""
                        }
                        
                        
                        
                    }
                })
            }
            
            
            let descText = viewModel.nftDetailModel.value?.postContent ?? ""
            if descText == ""{
                // cell.DescBottomLine.isHidden = true
                cell.DescriptionView.isHidden = true
            }
            else{
                // cell.DescBottomLine.isHidden = false
                cell.DescriptionView.isHidden = false
            }
            
            cell.descbgView?.backgroundColor = linearGradientColor(
                from: [.splashStartColor, .splashEndColor],
                locations: [0,1],
                size: CGSize(width: 40, height:35)
            )
            
            cell.detailsBgView?.backgroundColor = linearGradientColor(
                from: [.splashStartColor, .splashEndColor],
                locations: [0,1],
                size: CGSize(width: 40, height:35)
            )
            cell.propertiesView?.backgroundColor = linearGradientColor(
                from: [.splashStartColor, .splashEndColor],
                locations: [0,1],
                size: CGSize(width: 40, height:35)
            )
            cell.bosstView?.backgroundColor = linearGradientColor(
                from: [.splashStartColor, .splashEndColor],
                locations: [0,1],
                size: CGSize(width: 40, height:35)
            )
            cell.calendarBgView?.backgroundColor = linearGradientColor(
                from: [.splashStartColor, .splashEndColor],
                locations: [0,1],
                size: CGSize(width: 40, height:35)
            )
            
            cell.copyBtn.addTarget(self, action: #selector(copyContractAddress(sender: )), for: .touchUpInside)
            
            return cell
        }
        else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedNftTableViewCell", for: indexPath) as? FeedNftTableViewCell
            else { preconditionFailure("Failed to load collection view cell") }
            //cell.videoFullScreenDelegate = self
            cell.viewModelCell = viewModel.setUpPostDetails(indexPath: indexPath)
            //let isNft = FeedDetailsViewModel.instance
            cell.clapBtn.tag = indexPath.row
            cell.connectionImgBtn.tag = indexPath.row
            cell.viewImgBtn.tag = indexPath.row
            cell.profileBtn.tag = indexPath.row
            cell.feedNftTableDelegate = self
            //cell.shareImage.tag = indexPath.item
            


            return cell
            
//
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
        if indexPath.section == 0{
            return 400
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
    /// Asks the delegate for a view to display in the footer of the specified section of the table view.
    /// - Parameters:
    ///   - tableView: The table view asking for the view.
    ///   - section: The index number of the section containing the footer view.
    /// - Returns: A UILabel, UIImageView, or custom view to display at the bottom of the specified section.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    /// Asks the delegate for the height to use for the footer of a particular section.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: An index number identifying a section of tableView .
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) of the footer for section.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            if userId == SessionManager.sharedInstance.getUserId{
                return 60
            }
            else{
                return 0
            }
        }
        return 0
    }
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if indexPath.section == 0 {
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.nftDetailModel.value?.mediaUrl ?? "")"
            
            switch viewModel.nftDetailModel.value?.mediaType ?? 0 {
                
            case 5:
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
                docVC.url = fullMediaUrl
                self.present(docVC, animated: true, completion: nil)
                
            case 2:
                
//                let imageInfo   = GSImageInfo(image: UIImage(), imageMode: .aspectFit, imageHD: URL(string: fullMediaUrl))
//                let imageViewer = GSImageViewerController(imageInfo: imageInfo)
//
//                imageViewer.backgroundColor = UIColor.black
//                // self.navigationController?.setNavigationBarHidden(false, animated: true)
//                imageViewer.navigationItem.title = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.allowAnonymous == true ? "Anonymous User's Spark Image" : "\(FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.profileName ?? "")'s Spark Image"
//                navigationController?.present(imageViewer, animated: true, completion: nil)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
                vc.url = fullMediaUrl
                vc.modalPresentationStyle = .fullScreen
                self.isPlayerFullScreenDismissed = false
                navigationController?.present(vc, animated: true, completion: nil)
                
            default:
                break
            }
        }
        else{
            UIView.animate(withDuration: 0.3) {
                //self.TableView.performBatchUpdates(nil)
            }
        }
    }
    
    
    ///Share the post link using short url
    @objc func shareLink(_ sender: UITapGestureRecognizer){
        print("Tap shared")
       // let indexPath = sender.view?.tag  https://www.spark.synctag.com/Post/622067804af026223442f19c/_id62062a9041a18f4601254816/t_id
        let userId = viewModel.nftDetailModel.value?.userId ?? ""
        let post_id = viewModel.nftDetailModel.value?._id ?? ""
        let t_id = viewModel.nftDetailModel.value?.threadId ?? ""
        let url = "https://www.sparkme.synctag.com/Post/NFTPost/\(post_id)/_id\(userId)/t_id\(t_id)"
        self.createShortUrl(urlString: url)
    }
    
    /// Short url has been crated and passed to open the post
    func createShortUrl(urlString:String){
        guard let link = URL(string: urlString) else { return }
        let components = DynamicLinkComponents(link: link, domainURIPrefix: "https://sparkme.synctag.com/Post")
        components?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.adhash.spark")
        components?.iOSParameters?.appStoreID = "1578660405"
        components?.iOSParameters?.minimumAppVersion = "1.1.4"
        components?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.adhash.sparkme")
        components?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        components?.socialMetaTagParameters?.title = "Sparkme"
        components?.socialMetaTagParameters?.descriptionText = viewModel.nftDetailModel.value?.postContent ?? ""
        
        let type = viewModel.nftDetailModel.value?.mediaType ?? 0//FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.mediaType ?? 0
        
        switch type{
        case 1:
           
            break
        case 2:
            print("image")
            var url = ""
            url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.nftDetailModel.value?.mediaUrl ?? "")"
            let image = url
            components?.socialMetaTagParameters?.imageURL = URL(string:image )
            
            break
        case 3:
            var url = ""
            url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.nftDetailModel.value?.thumbNail ?? "")"
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
    
    
    
//    @objc func callFullscreenplaybtn(sender:UIButton){
//
//
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        let cell = TableView?.cellForRow(at: indexPath) as? FeedNftTableViewCell
//        //if cell?.player?.timeControlStatus == .playing{
//            cell?.player?.pause()
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
//
    
    
    /// Show the list users when pressed on the view count
    func homeView(sender: UIButton) {
        
        if viewModel.nftDetailModel.value?.viewCount ?? 0 > 0 {
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            slideVC.userId = viewModel.nftDetailModel.value?._id ?? ""
            slideVC.type = 1
            slideVC.delegate = self
            debugPrint(slideVC.userId)
            self.present(slideVC, animated: true, completion: nil)
        }
    }
    
    /// Show the list users when pressed on the clap count
    func homeClap(sender: UIButton) {
        if viewModel.nftDetailModel.value?.clapCount ?? 0 > 0 {
            
            let slideVC = OverlayView()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            slideVC.userId = viewModel.nftDetailModel.value?._id ?? ""//feedListData[sender.tag].postId ?? ""
            slideVC.type = 2
            slideVC.delegate = self
            debugPrint(slideVC.userId)
            self.present(slideVC, animated: true, completion: nil)
        }
    }
    
    
    /// Validate the input wallet address for transfering the NFT
    fileprivate func walletAddressInputAlert() {
        
        let alert = UIAlertController(title: "Transfer NFT", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
            self.walletInputTextFld = textField
            self.walletInputTextFld.clearButtonMode = .always
            self.walletInputTextFld.placeholder = "Enter wallet address"
            self.walletInputTextFld.returnKeyType = .done
            self.walletInputTextFld.delegate = self
            
            self.addDoneButtonOnKeyboard()
            
        }
        
        alert.addAction(UIAlertAction(title: "Transfer", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            textField?.keyboardType = .asciiCapableNumberPad
            
            guard let textValue = textField?.text, !textValue.isEmpty else {
                // toast with a specific duration and position
               // self.view.makeToast("Please enter wallet address to continue.", duration: 3.0, position: .top)
                Toast(text: "Please enter wallet address to continue.").show()
               // Toast(text: "Hello, world!", duration: Delay.long)
                self.view.endEditing(true)
                self.walletAddressInputAlert()
                return
            }
            
            let dict = [
                "postId": self.viewModel.nftDetailModel.value?._id ?? "",
                "data" : [
                    "tokenId": self.viewModel.nftDetailModel.value?.nfttokenId ?? "",
                    "to": textField?.text ?? "",
                    "chain": "MATIC",
                    "contractAddress": self.viewModel.nftDetailModel.value?.nftAddress ?? "",
                    "feeCurrency": "MATIC",
                ]
                
            ] as [String:Any]
            self.viewModel.transferNFTDetailApiCall(params: dict)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  (_) in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// On pressing the transfer button it will call the transfer wallet address
    @IBAction func transferButtonTapped(sender:UIButton) {
        
        walletAddressInputAlert()
    }
    
    
    
    /// Adding a done button to dismiss the keyboard.
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        walletInputTextFld.inputAccessoryView = doneToolbar
    }
    
    
    
    
    /// Clicking done button to dismiss the keyboard.
    @objc func doneButtonAction(){
        walletInputTextFld.resignFirstResponder()
        
    }
    
    
    /// Tag Button tapped to show the pop tip of the tag
    @objc func tagButtonTapped(sender:UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = TableView?.cellForRow(at: indexPath) as? FeedDetailTableViewCell
        cell?.easyTipView?.dismiss()
        cell?.easyTipView = EasyTipView(text:viewModel.nftDetailModel.value?.tagName ?? "", preferences: cell!.preferences)
        cell?.easyTipView?.show(forView: sender, withinSuperview: cell?.contentView)
    }
    
    
    /// On pressing the address it will open webview controller about the address
    @objc func callAddress(){
        
        if viewModel.nftDetailModel.value?.nftAddress ?? "" == ""{
            self.showErrorAlert(error: "No URL Found")
        }
        else{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            let nftUrl = SessionManager.sharedInstance.settingData?.data?.nFTInfo?.webURL ?? ""
            let nftAddress = viewModel.nftDetailModel.value?.nftAddress ?? ""
            webViewVC.urlStr = nftUrl + nftAddress
            webViewVC.titleStr = "NFTs"
            self.navigationController?.pushViewController(webViewVC, animated: true)
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
    
    
    
    /// On Pressing the copy button it will copy the address number
    @objc func copyContractAddress(sender:UIButton) {
        
        // write to clipboard
        UIPasteboard.general.string = self.viewModel.nftDetailModel.value?.nftAddress ?? ""
        Toast(text: "Contract address copied!").show()
       // self.view.makeToast("Contract address copied!", duration: 3.0, position: .top)
    }
}

extension NftFeedDetailViewController: UITextFieldDelegate {
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
        
        return newString.count <= 60
        //"+X (XXX) XXX-XXXX"
    }
}

extension NftFeedDetailViewController: UIViewControllerTransitioningDelegate {
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
