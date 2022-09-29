//
//  ClappedTagRelatedSparkViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 14/08/21.
//

import UIKit
import EasyTipView
import RAMAnimatedTabBarController

/// Thread request delegte protocol is used to call the method of post details page
protocol threadRequestDelegate : AnyObject {
    
    func threadRequestDetails(selectedMemberPostId:String,selectedMemberUserId:String,postId:String)
   
}

/// This screen helps to list out all existing spark of particular post of user any user have an option to choose any one post from list to repost corresponding user
class ClappedTagRelatedSparkViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    var clapDataModel:[ClapData]?
    
    var viewModel = ClappedTagSparkViewModel()
    
    var isFreshLoad = true
    
    var playedVideoIndexPath = 0
    
    var postType = 0
    
    var baseAnonymousPost = Bool()
    
    var backDelegate : backfromFeedDelegate?
    
    // Thread popup objects
    @IBOutlet weak var threadPopUpBgView: UIView!
    
    var selectedIndexpath = Int()
    
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpContinueBtn: UIButton!
    @IBOutlet weak var threadPopUpStayHereBtn: UIButton!

    var bubbleUserPostId = ""
    var threadpostId = ""
    var threaduserId = ""
    var linkpostId = ""
    var linkuserId = ""
    var linkTagId = ""
    
    var selectedMemberPostId = ""
    var selectedMemberUserId = ""
    
    weak var delegate:threadRequestDelegate?
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
                
        threadPopUpBgView.isHidden = true
        threadPopUpBgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
        viewModel.clapDataModel = clapDataModel ?? [ClapData]()
        
        if clapDataModel?.count ?? 0 > 1 {
            self.titleLbl.text = "My \(viewModel.clapDataModel[0].tagName ?? "") Sparks"
        }
        else{
            self.titleLbl.text = "My \(viewModel.clapDataModel[0].tagName ?? "") Spark"
            
        }
        
        self.tableView.register(UINib(nibName: "ClappedTagSparkTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        setupViewModelObserver()
    }
    
    func threadCreationRequestAPI() {
        
        let params = [
            "threadpostId": threadpostId,
            "threaduserId": threaduserId,
            "linkpostId": linkpostId,
            "linkuserId": linkuserId,
            "tagId": linkTagId
        ] as [String : Any]
        
        viewModel.sendThreadRequest(postDict: params)
        
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? ClappedTagSparkTableViewCell
        
        cell?.playerController?.player?.pause()
        //cell?.playToggle = 1
    }
    
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    /// Declare the tableview scroll to pause the player when it is playing
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method as the user’s finger touches up as it’s moving during a scrolling operation; the scroll view continues to move a short distance afterwards. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        
       let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? ClappedTagSparkTableViewCell
        //cell?.audioAnimationBg.stopAnimatingGif()
        
        cell?.playerController?.player?.pause()
        
        print("scrolling")
        
    }
    
    
    
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
       let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? ClappedTagSparkTableViewCell
        //cell?.audioAnimationBg.stopAnimatingGif()
        
      
        cell?.playerController?.player?.pause()
        
    }
    
    
    ///View Model Setup is used to observe and set the value of data from the thread api
    func setupViewModelObserver() {
        
        viewModel.threadRequestModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            if statusHttpCode.statusCode == 404{
                self.showErrorAlert(error: error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: RAMAnimatedTabBarController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
            else{
                self.showErrorAlert(error: error.localizedDescription)
            }
            
            
        }
        viewModel.threadRequestModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.status == 1 { //Success
                    SessionManager.sharedInstance.threadId = value.data?.threadId ?? ""
                    
                    self.delegate?.threadRequestDetails(selectedMemberPostId: self.selectedMemberPostId, selectedMemberUserId: self.selectedMemberUserId, postId: self.bubbleUserPostId)
                    
                 //   NotificationCenter.default.post(name: Notification.Name("getThreadByPostIdAPICall"), object: ["selectedMemberPostId":self.selectedMemberPostId,"selectedMemberUserId":self.selectedMemberUserId,"postId":self.bubbleUserPostId])
                    self.navigationController?.popViewController(animated: true)
                }
                else if value.data?.status == 2 { //Thread limit exceeds
                  //  NotificationCenter.default.post(name: Notification.Name("getThreadByPostIdAPICall"), object: ["selectedMemberPostId":self.selectedMemberPostId,"selectedMemberUserId":self.selectedMemberUserId,"postId":self.bubbleUserPostId])
                    self.delegate?.threadRequestDetails(selectedMemberPostId: self.selectedMemberPostId, selectedMemberUserId: self.selectedMemberUserId, postId: self.bubbleUserPostId)
                    self.showErrorAlert(error: value.data?.message ?? "")
                    self.navigationController?.popViewController(animated: true)
                    
                }
                else { // 2 - Already thread rquested bu opposite user
                  //  NotificationCenter.default.post(name: Notification.Name("getThreadByPostIdAPICall"), object: ["selectedMemberPostId":self.selectedMemberPostId,"selectedMemberUserId":self.selectedMemberUserId,"postId":self.bubbleUserPostId])
                    self.delegate?.threadRequestDetails(selectedMemberPostId: self.selectedMemberPostId, selectedMemberUserId: self.selectedMemberUserId, postId: self.bubbleUserPostId)
                    self.showErrorAlert(error: value.data?.message ?? "")
                    
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: BubbleViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    ///  This is used to show the thread popup in this page
    @IBAction func backButtonTapped(_ sender: Any) {
        threadPopUpBgView.isHidden = false
    }
    
    /// Continue button is used to set  to dimiss the page and send the details to feed details page
    @IBAction func continueButtonTapped(sender:UIButton) {
        self.backDelegate?.back(postId: "", threadId: "", userId: "", memberList: [MembersList](), messageListApproved:false, isFromLoopConversation: false, isFromNotify: false, isFromHome: false, isFromBubble: false, isThread: 0, linkPostId: "")
        self.navigationController?.popViewController(animated: true)

    }
    
    /// This is used to hide the thread popup in this page
    @IBAction func stayHereButtonTapped(sender:UIButton) {
        threadPopUpBgView.isHidden = true
        
    }
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return viewModel.clapDataModel.count
    }
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ClappedTagSparkTableViewCell
        else { preconditionFailure("Failed to load collection view cell") }
        
        cell.viewModelCell = viewModel.setUpSparkFeedDetails(indexPath: indexPath)
        
        if selectedIndexpath == indexPath.row && !isFreshLoad {
            
            cell.cellBackgroundView.layer.borderWidth = 2.0
            cell.cellBackgroundView.layer.borderColor = #colorLiteral(red: 0.2196078431, green: 0.4470588235, blue: 0.4941176471, alpha: 1)
            //cell.cellBackgroundView.layer.cornerRadius = 11.0
            cell.cellBackgroundView.clipsToBounds = true
        } else {
            cell.cellBackgroundView.layer.borderWidth = 0.0
            cell.cellBackgroundView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        return cell
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
    
    
    
    /// Asks the delegate for the estimated height of a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be. Return automaticDimension if you have no estimate.
    ///  - Providing an estimate the height of rows can improve the user experience when loading the table view. If the table contains variable height rows, it might be expensive to calculate all their heights and so lead to a longer load time. Using estimation allows you to defer some of the cost of geometry calculation from load time to scrolling time.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isFreshLoad = false
        selectedIndexpath = indexPath.row
        
        linkpostId = viewModel.clapDataModel[indexPath.row].postId ?? ""
        linkuserId = viewModel.clapDataModel[indexPath.row].userId ?? ""
        linkTagId = viewModel.clapDataModel[indexPath.row].tagId ?? ""
        let selectedAnonymousPost = viewModel.clapDataModel[indexPath.row].allowAnonymous ?? false
        
        if baseAnonymousPost == true && selectedAnonymousPost == true && postType == 4{
            self.showErrorAlert(error: "Anonymous loop request not allowed.")
        }
        else{
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ClappedTagSparkTableViewCell
            
            cell?.cellBackgroundView.layer.borderWidth = 2.0
            cell?.cellBackgroundView.layer.borderColor = #colorLiteral(red: 0.2196078431, green: 0.4470588235, blue: 0.4941176471, alpha: 1)
            cell?.cellBackgroundView.layer.cornerRadius = 11.0
            cell?.cellBackgroundView.clipsToBounds = true
       
            threadCreationRequestAPI()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
       
        
    }
    
   
    
   
}

extension ClappedTagRelatedSparkViewController : getPlayerVideoAudioIndexForMyPostDelegate {
    /// Get the played video indexpath and set in the variable.
    func getPlayVideoIndex(index: Int) {
        debugPrint(index)
        playedVideoIndexPath = index
    }
    
}
