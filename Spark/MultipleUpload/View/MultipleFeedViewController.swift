//
//  MultipleFeedViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 29/06/22.
//

import UIKit
import Kingfisher
import AVKit
import SDWebImage

/**
 This class is used to set all the media list from monetize media  will be shown in the tableview with vertical scrolling will be happen
 */

class MultipleFeedViewController: UIViewController {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var viewModel = MultipleViewModel()
    var postId = ""
    var limit = 10
    var userName = ""
    var postType = 0
    var tagName = ""
    var profilePic = ""
    var playedVideoIndexPath = 0
    var gender = 0
    var isPlayerFullScreenDismissed = false
    var postDate = 0
    var loadingData = false
    var userId = ""
    var nextPageKey = 1
    //var postType = 0
    
    private var lastContentOffset: CGFloat = 0
    //var isLoading = false
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewModel()
        self.callAPi(pageNumber: 1)
        self.userNameLbl.text = "\(userName)'s Spark list"
        print(self.postType)
        

        // Do any additional setup after loading the view.
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 1)
        let cell = tableView.cellForRow(at: indexPath) as? MultipleFeedDetailTableViewCell
        cell?.test.networkSpeedTestStop()
        print("Paused")
        cell?.playerController?.player?.pause()
        cell?.avplayer?.pause()
        cell?.activityLoader.isHidden = true
    }

    /// Setup the viewmodel to observe the api call values here
    func setUpViewModel() {
        
        viewModel.multipleModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        viewModel.multipleModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if self.viewModel.multipleFeedListData.count > 0 {
                
                if self.viewModel.multipleModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.multipleFeedListData.count > 0 { //Loading
                   
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                       
                        self.loadingData = false
                       
                    }
                }else { //No extra data available
                    
                    
                    DispatchQueue.main.async {
                        
                        self.loadingData = true
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else{
                self.tableView.reloadData()
                self.loadingData = true
            }
            
        
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
    
    
    /// Call the api from viewmodel to get the media api call
    func callAPi(pageNumber:Int){
        let param = [
            "postId": postId,
            "paginator":[
                "nextPage": pageNumber,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String:Any]
        viewModel.getMediaAPICall(params: param)
    }
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData {
            limit = 10
            self.loadingData = true
            self.nextPageKey = self.viewModel.multipleModel.value?.data?.paginator?.nextPage ?? 0
            self.callAPi(pageNumber: nextPageKey)
        }
        else {
            //self.noMoreView.isHidden = true
        }
    }
    
    /// Back button on pressed to dismiss the view controller 
    @IBAction func backBtnOnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension MultipleFeedViewController : UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate{
   
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
        if section == 0{
            return 1
        }
        else{
            return viewModel.multipleFeedListData.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleHeaderTableViewCell", for: indexPath) as! MultipleHeaderTableViewCell
            cell.profileName.text = userName
            cell.tagView.clipsToBounds = true
            cell.tagView.layer.cornerRadius = 6
            cell.tagLblBtn.setTitle(tagName, for: .normal)
            let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(profilePic)"
            cell.profileImageView.setImage(
               url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
               placeholder: #imageLiteral(resourceName: gender == 1 ?  "no_profile_image_male" : gender == 2 ? "no_profile_image_female" : "others"))
            
            cell.postTypeContentView.isHidden = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedMe))
            cell.profileImageView.addGestureRecognizer(tap)
            cell.profileImageView.isUserInteractionEnabled = true
            
            let nameTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedMe))
            cell.profileName.isUserInteractionEnabled = true
            cell.profileName.addGestureRecognizer(nameTap)
            
//            switch postType {
//            case 1:
//                cell.postTypeContentView.image = #imageLiteral(resourceName: "global")
//            case 2:
//                cell.postTypeContentView.image = #imageLiteral(resourceName: "local")
//            case 3:
//                cell.postTypeContentView.image = #imageLiteral(resourceName: "social")
//            case 4:
//                cell.postTypeContentView.image = #imageLiteral(resourceName: "closed")
//            default:
//                break
//            }
            
            let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(postDate)")
            cell.dateLbl.text = ""//Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
            
            //cell.profileImageView.image =
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleFeedDetailTableViewCell", for: indexPath) as! MultipleFeedDetailTableViewCell
            if viewModel.multipleFeedListData.count > 0{
                cell.cellDelegate = self
                let postContent = viewModel.multipleFeedListData[indexPath.item].postContent ?? ""
                if postContent == ""{
                    cell.CaptionText.isHidden = true
                }
                else{
                    cell.CaptionText.isHidden = false
                    cell.CaptionText.text = postContent
                }
               
                cell.mediaType = viewModel.multipleFeedListData[indexPath.item].mediaType ?? 0
                switch viewModel.multipleFeedListData[indexPath.item].mediaType {
                case 1:  //Text
                   
                    cell.bgTextView.isHidden = false
                    cell.textView.isHidden = false
                    cell.contentBgImage.isHidden = true
                    cell.contentImageView.isHidden = true
                    cell.videoBgView.isHidden = true
                    cell.textView.backgroundColor = .clear
                    cell.textView.textAlignment = .center
                    cell.textView.font = UIFont.MontserratMedium(.veryLarge)
                    cell.playBtn.isHidden = true
                    cell.activityLoader.isHidden = true
                    cell.CaptionText.text = ""
                    if self.viewModel.multipleFeedListData[indexPath.item].bgColor ?? "" != "" {
                        if self.viewModel.multipleFeedListData[indexPath.item].bgColor ?? "" == "#ffffff" {
                            Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.multipleFeedListData[indexPath.item].postContent ?? "", textColor: "#ffffff", bgColor: "368584", label: cell.textView, bgView: cell.bgTextView)
                        }else{
                            Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.multipleFeedListData[indexPath.item].postContent ?? "", textColor: self.viewModel.multipleFeedListData[indexPath.item].textColor ?? "", bgColor: self.viewModel.multipleFeedListData[indexPath.item].bgColor ?? "", label: cell.textView, bgView: cell.bgTextView)
                        }
                    }else{
                        Helper.sharedInstance.loadTextIntoCell(text: self.viewModel.multipleFeedListData[indexPath.item].postContent ?? "", textColor: "FFFFFF", bgColor: "358383", label: cell.textView, bgView: cell.bgTextView)
                    }
                    
                case 2: //Image
                    cell.bgTextView.isHidden = true
                    cell.textView.isHidden = true
                    cell.contentBgImage.isHidden = false
                    cell.contentImageView.isHidden = false
                    cell.videoBgView.isHidden = true
                    cell.playBtn.isHidden = true
                    cell.activityLoader.isHidden = true
                    let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                    cell.contentImageView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                    
                    cell.contentBgImage.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                    
                case 3: // Video
                    cell.delegate = self
                    cell.bgTextView.isHidden = true
                    cell.textView.isHidden = true
                    cell.contentBgImage.isHidden = false
                    cell.contentImageView.isHidden = true
                    cell.videoBgView.isHidden = false
                    cell.videoBgView.tag = indexPath.row
                    cell.playBtn.isHidden = true
                    cell.activityLoader.isHidden = true
                    let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.multipleFeedListData[indexPath.item].thumbNail ?? "")"
                    cell.mediaUrl = self.viewModel.multipleFeedListData[indexPath.item].mediaUrl ?? ""
                    cell.contentBgImage.setImage(
                        url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: UIImage(named: "NoImage"))
                    cell.playOrPauseVideo(url: self.viewModel.multipleFeedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
                case 4: //Audio
                    cell.delegate = self
                    cell.bgTextView.isHidden = true
                    cell.textView.isHidden = true
                    cell.contentBgImage.isHidden = false
                    cell.contentImageView.isHidden = true
                    cell.videoBgView.isHidden = false
                    cell.videoBgView.tag = indexPath.row
                    cell.playBtn.isHidden = true
                    cell.activityLoader.isHidden = true
                    
                    let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                    cell.mediaUrl = fullMediaUrl//self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                    cell.AudioplayOrPauseVideo(url: fullMediaUrl, parent: self, play: false)
                case 5: //Document
                    cell.bgTextView.isHidden = true
                    cell.textView.isHidden = true
                    cell.contentBgImage.isHidden = false
                    cell.contentImageView.isHidden = false
                    cell.videoBgView.isHidden = true
                    cell.contentImageView.image = UIImage(named: "document_image")
                    cell.contentBgImage.image = UIImage(named: "document_image")
                    cell.playBtn.isHidden = true
                    cell.activityLoader.isHidden = true
                    
                default:
                    break
                }
                
                switch postType {
                case 1:
                    cell.postTypeImage.image = #imageLiteral(resourceName: "globalGray")
                case 2:
                    cell.postTypeImage.image = #imageLiteral(resourceName: "localGray")
                case 3:
                    cell.postTypeImage.image = #imageLiteral(resourceName: "SocialGray")
                case 4:
                    cell.postTypeImage.image = #imageLiteral(resourceName: "closedGray")
                default:
                    break
                }
            }
            
            
            let createdDate = viewModel.multipleFeedListData[indexPath.item].createdDate ?? 0
            let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(createdDate)")
            cell.timeLbl.text = Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
        
            return cell
        }
        
        
        
       
    }
    
    /// This method is used to call the connection list user profile page
    @objc func tappedMe()
    {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = userId
        self.navigationController?.pushViewController(connectionListVC, animated: true)
        SessionManager.sharedInstance.linkProfileUserId = ""
        SessionManager.sharedInstance.isProfileFromBeforeLogin = false
    }
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let lastItem = viewModel.multipleFeedListData.count - 1
            if lastItem == indexPath.row{
                self.loadMoreData()
            }
        }
    }
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            print("section")
            for cell in tableView.visibleCells{
                let indexPath = tableView.indexPath(for: cell)
                let cell = tableView.cellForRow(at: IndexPath(row: indexPath?.row ?? 0, section: 1)) as? MultipleFeedDetailTableViewCell//cellForItem(at:
                cell?.activityLoader.isHidden = true
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                
            }
            
            //self.tableView.reloadData()
            let vc = storyboard?.instantiateViewController(withIdentifier: "MultipleHorizontalViewController") as! MultipleHorizontalViewController
            vc.multipleFeedListData = viewModel.multipleFeedListData
            vc.indexPathItem = indexPath.row
            vc.postId = postId
            vc.nextPageKey = self.viewModel.multipleModel.value?.data?.paginator?.nextPage ?? 0
            self.navigationController?.pushViewController(vc, animated: false)
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
            return 88
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
    
    
    /// Scroll view did scroll offset will change
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y + 0) {
            //print("scrolling up")
            for cell in tableView.visibleCells{
                let indexPath = tableView.indexPath(for: cell)
                let cell = tableView.cellForRow(at: IndexPath(row: indexPath?.row ?? 0, section: 1)) as? MultipleFeedDetailTableViewCell//cellForItem(at:
                cell?.activityLoader.isHidden = true
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                
            }
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
          //  print("scrolling down")
            for cell in tableView.visibleCells{
                let indexPath = tableView.indexPath(for: cell)
                let cell = tableView.cellForRow(at: IndexPath(row: indexPath?.row ?? 0, section: 1)) as? MultipleFeedDetailTableViewCell//cellForItem(at:
                cell?.activityLoader.isHidden = true
                cell?.playerController?.player?.pause()
                cell?.avplayer?.pause()
                
            }
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    
    
}


/// This extension class is used to get the delegates of video or audio player dismiss the fullscreen to get the indexpath of currently playing
extension MultipleFeedViewController : getPlayerVideoAudioIndexDelegate {
    func playViewed(sender: Int) {
        
    }
    
    func videoPlayerFullScreenDismiss() {
        isPlayerFullScreenDismissed = true
        print("Exit")
        
        
    }
    
    func getPlayVideoIndex(index: Int) {
        debugPrint(index)
        playedVideoIndexPath = index
    }
    
    func callAudioAnimation(isPlaying: Bool) {
        

    }
    
}


extension MultipleFeedViewController: GrowingCellProtocol {
    // Update height of UITextView based on string height
    func updateHeightOfRow(_ cell: MultipleFeedDetailTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            // Scoll up your textview if required
            if let thisIndexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}
