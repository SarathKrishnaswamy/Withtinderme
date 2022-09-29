//
//  PaymentBreakupViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import UIKit

class PaymentBreakupViewController: UIViewController, backFromOverlay {
    
    
    
    func dismissOverlay(userId: String,IndexPath:Int) {
        print("Back from view")
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        connectionListVC.indexPath = IndexPath
        
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
   /**
    This class shows particular users monetize breakup for each payment with list cost
    */
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLbl: UILabel!
    
   
    var monetizeAmount = 0
    var totalMonetizeAmount = 0
    var postId = ""
    let viewModel = PaymentHistoryViewModel()
    var type = 0
    var userId = ""
    var transactionId = ""
    var paymentMethod = ""
    var isFromSettings = false
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        continueBtn.layer.cornerRadius = 4
        continueBtn.clipsToBounds = true
        self.tableView.register(UINib(nibName: "FeedNftTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedNftTableViewCell")
        self.setUpPaymentViewModel()
        self.apiCall()
        
        if type == 1{
            self.headerLbl.text = "Loop Listing Summary"
        }
        else{
            self.headerLbl.text = "Payment Details"
        }
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    
    
    
    ///Call the api model to observe and set the payment breakup model
    func apiCall() {
        let bubbleDict = [
            "postId":postId
            
            
        ] as [String : Any]
        viewModel.paymentPaidDetailApiCall(postDict: bubbleDict)
    }
    
    ///Observe and setup the payment model and reload the data to set in the tablebview
    func setUpPaymentViewModel() {
        viewModel.paymentBreakUpModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.paymentBreakUpModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            print(value)
            
            if value.isOk ?? false{
                
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? FeedNftTableViewCell
        cell?.playerController?.player?.pause()
        cell?.avplayer?.pause()
    }
    
    ///Back button tapped dimiss the controller
    @IBAction func backbtnOnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    ///View post tapped to redirect for feeddetail page
    @IBAction func viewPostBtnOnPressed(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
        detailVC.postId = viewModel.paymentBreakUpModel.value?.data?._id ?? ""
        detailVC.threadId = viewModel.paymentBreakUpModel.value?.data?.threadId ?? ""
        SessionManager.sharedInstance.threadId = viewModel.paymentBreakUpModel.value?.data?.threadId ?? ""
        SessionManager.sharedInstance.userIdFromSelectedBubbleList = viewModel.paymentBreakUpModel.value?.data?.userId ?? ""
        detailVC.isFromBubble = false
        detailVC.isFromHomePage = true
        detailVC.postType = viewModel.paymentBreakUpModel.value?.data?.postType ?? 0
        detailVC.isFromSettings = isFromSettings
        
        detailVC.myPostId = viewModel.paymentBreakUpModel.value?.data?._id ?? ""
        detailVC.myThreadId = viewModel.paymentBreakUpModel.value?.data?.threadId ?? ""
        detailVC.myUserId = viewModel.paymentBreakUpModel.value?.data?.userId ?? ""
        // detailVC.selectedHomePageIndexPath = indexPath
        //detailVC.delegate = self
        //SessionManager.sharedInstance.selectedIndexTabbar = 0
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    /// It will show the count if its greater than '1000' and less than  '1000000' it will show K if its greater than 1000000 it will show M
    /// - Parameter num: Here we need to pass the double value of the count
    /// - Returns: It will return as string to append in the label
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))k")
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

extension PaymentBreakupViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    //Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
            
        }
        else{
            return 1
        }
        
    }
    
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
        
           let cell = tableView.dequeueReusableCell(withIdentifier: "FeedNftTableViewCell", for: indexPath) as! FeedNftTableViewCell
          //  cell.clapBtn.setImage(#imageLiteral(resourceName: "clap_gray"), for: .normal)
//
            cell.profileBtn.tag = indexPath.row
            cell.profileBtn.addTarget(self, action: #selector(tappedUserProfile), for: .touchUpInside)
            let Lbltap = UITapGestureRecognizer(target: self, action: #selector(tappedUserProfile))
            cell.titleLabel.addGestureRecognizer(Lbltap)
            cell.titleLabel.isUserInteractionEnabled = true
            if viewModel.paymentBreakUpModel.value?.data?.viewCount ?? 0 > 0 {
                cell.viewImgBtn.setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
            }else {
                cell.viewImgBtn.setImage(#imageLiteral(resourceName: "eye_gray"), for: .normal)
            }
//
//
            if viewModel.paymentBreakUpModel.value?.data?.threadCount ?? 0 > 0 {
                cell.connectionImgBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
            }else {
                cell.connectionImgBtn.setImage(#imageLiteral(resourceName: "connection_gray"), for: .normal)
            }
            
            let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.paymentBreakUpModel.value?.data?.createdDate ?? 0)")
            
            
//
            cell.dateLabel.text = Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
            cell.tagBtn.setTitle(viewModel.paymentBreakUpModel.value?.data?.tagName ?? "", for: .normal)
//            //viewcount
            if viewModel.paymentBreakUpModel.value?.data?.viewCount ?? 0 > 0{

                cell.viewCountBtn.setTitle("\(formatPoints(num: Double(viewModel.paymentBreakUpModel.value?.data?.viewCount ?? 0)))", for: .normal)
                cell.viewCountBtn.addTarget(self, action: #selector(viewCount), for: .touchUpInside)
            }
            else{
                cell.viewCountBtn.setTitle("0", for: .normal)
            }
//            //clap
            if viewModel.paymentBreakUpModel.value?.data?.clapCount ?? 0 > 0{
                cell.clapCountBtn.setTitle("\(formatPoints(num: Double(viewModel.paymentBreakUpModel.value?.data?.clapCount ?? 0)))", for: .normal)
                cell.clapCountBtn.addTarget(self, action: #selector(clapCount), for: .touchUpInside)
            }
            else{
                cell.clapCountBtn.setTitle("0", for: .normal)
            }
//            //connection
            if viewModel.paymentBreakUpModel.value?.data?.threadCount ?? 0 > 0{
                cell.connectionCountBtn.setTitle("\(formatPoints(num: Double(viewModel.paymentBreakUpModel.value?.data?.threadCount ?? 0)))", for: .normal)
            }
            else{
                cell.connectionCountBtn.setTitle("0", for: .normal)
            }
            
            if viewModel.paymentBreakUpModel.value?.data?.monetize ?? 0 == 1{
                cell.monetizeView.isHidden = false
                
            }
            else{
                cell.monetizeView.isHidden = true
            }
            
            cell.currencySymbol.text = viewModel.paymentBreakUpModel.value?.data?.currencySymbol ?? ""
//
//
//
//
            //cell.tagBtn.addTarget(self, action: #selector(tagButtonTapped(sender: )), for: .touchUpInside)
//
//            if viewModel.paymentBreakUpModel.value?.data?.allowAnonymous == true {
//                cell.iconImageView.image = #imageLiteral(resourceName: "ananomous_user")
//                cell.titleLabel.text = "Anonymous User"
//
//            }else {
            let profilePicurl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(viewModel.paymentBreakUpModel.value?.data?.profilePic ?? "")"
                cell.iconImageView.setImage(
                    url: URL.init(string:profilePicurl ) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModel.paymentBreakUpModel.value?.data?.gender == 1 ?  "no_profile_image_male" : viewModel.paymentBreakUpModel.value?.data?.gender  == 2 ? "no_profile_image_female" : "others"))
//
//
                cell.titleLabel.text = viewModel.paymentBreakUpModel.value?.data?.profileName ?? ""
//            }
//
//            // postContentLabel.text = viewModelCell?.getPostedText
            cell.postContentLabel.isHidden = false
//
            if viewModel.paymentBreakUpModel.value?.data?.postContent?.contains("http") ?? false || viewModel.paymentBreakUpModel.value?.data?.postContent?.contains("https") ?? false || viewModel.paymentBreakUpModel.value?.data?.postContent?.contains("www") ?? false {
                cell.postContentLabel.isUserInteractionEnabled = true
            } else {
                cell.postContentLabel.isUserInteractionEnabled = false
            }
//
            switch viewModel.paymentBreakUpModel.value?.data?.postType {
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
//
            if viewModel.paymentBreakUpModel.value?.data?.postContent?.isEmpty ?? false {
                cell.postContentLabel.isHidden = true
                cell.videoBgViewHeightConstraints.constant = 285//self.contentBgImgView.frame.height
                cell.contentImageViewHeightConstraints.constant = 285
                cell.contentImageBgViewHeightConstraints.constant = 285
            }else{
                cell.postContentLabel.isHidden = true
                cell.videoBgViewHeightConstraints.constant = 285 //self.contentBgImgView.frame.height
                cell.contentImageViewHeightConstraints.constant = 285
                cell.contentImageBgViewHeightConstraints.constant = 285
            }
//
            switch viewModel.paymentBreakUpModel.value?.data?.mediaType {

            case MediaType.Text.rawValue:

                //  adjustContentSize(tv: txtViewForPost)
                cell.contentBgImgView.isHidden = true
                cell.bgViewForText.isHidden = false
                cell.videoBgView.isHidden = true
                cell.contentsImageView.isHidden = true
                cell.pdfImgView.isHidden = true
                cell.postContentLabel.isHidden = true
                cell.textBgViewHeightConstraints.constant = 285
                cell.txtViewForPost.font = UIFont.MontserratMedium(.large)
                cell.nfTImage.isHidden = true


                if viewModel.paymentBreakUpModel.value?.data?.bgColor != ""{

                    Helper.sharedInstance.loadTextIntoCells(text:viewModel.paymentBreakUpModel.value?.data?.postContent ?? "", textColor: viewModel.paymentBreakUpModel.value?.data?.textColor ?? "", bgColor: viewModel.paymentBreakUpModel.value?.data?.bgColor ?? "" , label: cell.txtViewForPost, bgView: cell.bgViewForText)
                }else{
                    Helper.sharedInstance.loadTextIntoCells(text: viewModel.paymentBreakUpModel.value?.data?.postContent ?? "", textColor: "FFFFFF", bgColor: "358383", label: cell.txtViewForPost, bgView: cell.bgViewForText)
                }


            case MediaType.Video.rawValue:

                cell.contentBgImgView.isHidden = false
                cell.bgViewForText.isHidden = true
                cell.videoBgView.isHidden = false
                cell.contentsImageView.isHidden = true
                cell.pdfImgView.isHidden = true
                cell.AudioAnimation.isHidden = true

                cell.videoBgViewHeightConstraints.constant = cell.contentBgImgView.frame.height
                let isNft = viewModel.paymentBreakUpModel.value?.data?.nft ?? 0
                if isNft == 0{
                    cell.nfTImage.isHidden = true
                }
                else{
                    cell.nfTImage.isHidden = false
                }
                var url = ""
                url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.paymentBreakUpModel.value?.data?.thumbNail ?? "")"
                cell.contentBgImgView.setImage(
                    url: URL.init(string:url ) ?? URL(fileURLWithPath: ""),
                    placeholder: UIImage(named: "NoImage"))

                cell.playOrPauseVideo(url: viewModel.paymentBreakUpModel.value?.data?.mediaUrl ?? "")

            case MediaType.Image.rawValue:

                cell.contentBgImgView.isHidden = false
                cell.bgViewForText.isHidden = true
                cell.videoBgView.isHidden = true
                cell.contentsImageView.isHidden = false
                cell.pdfImgView.isHidden = true
                cell.AudioAnimation.isHidden = true


                let isNft = viewModel.paymentBreakUpModel.value?.data?.nft ?? 0
                if isNft == 0{
                    cell.nfTImage.isHidden = true
                }
                else{
                    cell.nfTImage.isHidden = false
                }
                
                var mediaurl = ""
                mediaurl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.paymentBreakUpModel.value?.data?.mediaUrl ?? "")"

                cell.contentsImageView.setImage(
                    url: URL.init(string: mediaurl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: "NoImage"))

                cell.contentBgImgView.setImage(
                    url: URL.init(string: mediaurl) ?? URL(fileURLWithPath: ""),
                    placeholder: UIImage(named: "NoImage"))
                //

            case MediaType.Audio.rawValue:

                cell.contentBgImgView.isHidden = false
                cell.bgViewForText.isHidden = true
                cell.videoBgView.isHidden = false
                cell.contentsImageView.isHidden = true
                cell.pdfImgView.isHidden = true

                cell.AudioAnimation.isHidden = false
                cell.contentBgImgView.isHidden = true

                let isNft = viewModel.paymentBreakUpModel.value?.data?.nft ?? 0
                if isNft == 0{
                    cell.nfTImage.isHidden = true
                }
                else{
                    cell.nfTImage.isHidden = false
                }
                var audioUrl = ""
                audioUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.paymentBreakUpModel.value?.data?.mediaUrl ?? "")"

                cell.playOrPauseVideo(url:audioUrl)

            case MediaType.Document.rawValue:

                cell.contentBgImgView.isHidden = true
                cell.bgViewForText.isHidden = true
                cell.videoBgView.isHidden = true
                cell.contentsImageView.isHidden = true
                cell.pdfImgView.isHidden = false

                cell.AudioAnimation.isHidden = true


                let imageName = viewModel.paymentBreakUpModel.value?.data?.mediaUrl?.components(separatedBy: ".")
                let isNft = viewModel.paymentBreakUpModel.value?.data?.nft ?? 0
                if isNft == 0{
                    cell.nfTImage.isHidden = true
                }
                else{
                    cell.nfTImage.isHidden = false
                }
                //                if imageName?.last == "pdf" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "pdf")
                //                }else if imageName?.last == "ppt" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "ppt")
                //                }else if imageName?.last == "docs" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "doc")
                //                }else if imageName?.last == "doc" || imageName?.last == "docx" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "doc")
                //                }else if imageName?.last == "xlsx" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "xls")
                //                }else if imageName?.last == "xls" {
                //                    pdfImgView.image = #imageLiteral(resourceName: "xls")
                //                }else  {
                //                    pdfImgView?.image = #imageLiteral(resourceName: "text")
                //                }

                cell.pdfImgView?.image = #imageLiteral(resourceName: "document_image")

            default:
                break
            }
            var mediaurl = ""
            mediaurl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.paymentBreakUpModel.value?.data?.mediaUrl ?? "")"
            cell.contentsImageView.setImage(
                url: URL.init(string: mediaurl) ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: "NoImage"))
//        }
        return cell
    }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MonetizeCardTableViewCell", for: indexPath) as! MonetizeCardTableViewCell
            
            if type == 1{
                cell.SparkPostCOntentLbl.text = "Your Spark value"
                cell.totalCostContentLbl.text = "Your Spark listing value"
                cell.paymentIdLbl.text = "Transaction Id"
                cell.paymentMethodLbl.text = "Transaction Method"
            }
            else{
                cell.SparkPostCOntentLbl.text = "Loop content fee"
                cell.totalCostContentLbl.text = "Loop listing cost"
                cell.paymentIdLbl.text = "Payment Id"
                cell.paymentMethodLbl.text = "Payment Method"
            }
            
            if self.viewModel.paymentBreakUpModel.value?.data?.monetizeActualAmount ?? 0 == 0{
                cell.stackView1.isHidden = true
                cell.line1.isHidden = true
            }
            else{
                cell.stackView1.isHidden = false
                cell.line1.isHidden = false
            }
            if self.viewModel.paymentBreakUpModel.value?.data?.monetizePlatformAmount ?? 0 == 0{
                cell.stackView2.isHidden = true
                cell.line2.isHidden = true
            }
            else{
                cell.stackView2.isHidden = false
                cell.line2.isHidden = false
            }
            
            if self.viewModel.paymentBreakUpModel.value?.data?.monetizeTax ?? 0 == 0{
                cell.stackView3.isHidden = true
                cell.line3.isHidden = true
            }
            else{
                cell.stackView3.isHidden = false
                cell.line3.isHidden = false
            }
            
            if transactionId != ""{
                cell.paymentIdStackView.isHidden = false
                cell.paymentLine.isHidden = false
                cell.paymentIdValue.text = transactionId
            }
            else{
                cell.paymentIdStackView.isHidden = true
                cell.paymentLine.isHidden = true
            }
            
            if self.paymentMethod != ""{
                cell.paymentMethodStackView.isHidden = false
                cell.paymentMethodLine.isHidden = false
                cell.paymentMethodValue.text = paymentMethod
            }
            else{
                cell.paymentMethodStackView.isHidden = true
                cell.paymentMethodLine.isHidden = true
            }
            
            
            
            cell.postPriceLbl.text = "\(self.viewModel.paymentBreakUpModel.value?.data?.currencySymbol ?? "")\(self.viewModel.paymentBreakUpModel.value?.data?.monetizeActualAmount ?? 0)"
            cell.platfdormfeePriceLbl.text = "\(self.viewModel.paymentBreakUpModel.value?.data?.currencySymbol ?? "")\(self.viewModel.paymentBreakUpModel.value?.data?.monetizePlatformAmount ?? 0)"
            cell.tacPriceLbl.text = "\(self.viewModel.paymentBreakUpModel.value?.data?.currencySymbol ?? "")\(self.viewModel.paymentBreakUpModel.value?.data?.monetizeTax ?? 0)"
            cell.postListingCostPriceLbl.text = "\(self.viewModel.paymentBreakUpModel.value?.data?.currencySymbol ?? "")\(self.viewModel.paymentBreakUpModel.value?.data?.monetizeAmount ?? 0)"
                
                return cell
        }
    }
    
    
    ///If user tapped the profile it will redirect to open the user profile page.
    @objc func tappedUserProfile()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = viewModel.paymentBreakUpModel.value?.data?.userId ?? ""
        self.navigationController?.pushViewController(connectionListVC, animated: true)
        SessionManager.sharedInstance.linkProfileUserId = ""
        SessionManager.sharedInstance.isProfileFromBeforeLogin = false
    }
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        if indexPath.section == 0 {
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(viewModel.paymentBreakUpModel.value?.data?.mediaUrl ?? "")"
            
            switch viewModel.paymentBreakUpModel.value?.data?.mediaType ?? 0 {
                
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
                navigationController?.present(vc, animated: false, completion: nil)
                
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
    
    
    @objc func viewCount(){
        let slideVC = OverlayView()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.userId = self.viewModel.paymentBreakUpModel.value?.data?._id ?? ""
        slideVC.type = 1
        slideVC.delegate = self
        debugPrint(slideVC.userId)
        self.present(slideVC, animated: true, completion: nil)
    }
    
    
    @objc func clapCount(){
        let slideVC = OverlayView()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.userId = self.viewModel.paymentBreakUpModel.value?.data?._id ?? ""
        slideVC.type = 2
        slideVC.delegate = self
        debugPrint(slideVC.userId)
        self.present(slideVC, animated: true, completion: nil)
    }
        
}

extension PaymentBreakupViewController: UIViewControllerTransitioningDelegate {
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
