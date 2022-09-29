//
//  NotificationViewController.swift
//  Spark me
//
//  Created by adhash on 14/08/21.
//

import UIKit
import UserNotifications
import UIView_Shimmer


protocol backfromFeedDelegate{
    /// Communicates between feeddetail page to notification page to pass the datas inside.
    func back(postId:String, threadId:String, userId:String, memberList:[MembersList],messageListApproved:Bool,isFromLoopConversation:Bool,isFromNotify:Bool, isFromHome:Bool, isFromBubble:Bool, isThread:Int ,linkPostId:String)
}

/**
 This class is used to retrive all the notification for claps, Eyeshots and Loops with all the notifications can be arrived here.
 */

class NotificationViewController: UIViewController,backToHomeFromDetailPage,backfromFeedDelegate {
    
    /// Get all the datas here from the feed detatils page.
    ///  - Params are not used here
    func back(postId: String, threadId: String, userId: String, memberList:[MembersList],messageListApproved:Bool, isFromLoopConversation:Bool, isFromNotify:Bool, isFromHome:Bool, isFromBubble:Bool, isThread:Int,linkPostId:String) {
        self.isNewLoading = true
    }
    
    
    /// Get back from the feed detail page for select the tab bar
    ///  - Params are not used here
    func backToHomeFromDetail(indexPath: Int, selectedHomePageLimit: Int, postType: Int, isFromLink:Bool) {
        
        self.tabBarController?.selectedIndex = 3
    }
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let viewModel = NotificationViewModel()
    
    @IBOutlet weak var noImageView: UIImageView!
    
    @IBOutlet weak var noDataLbl: UILabel!
    
    var acceptCloseBtnSelectdIndexPath = 0
    
    var notifytype = 0
    
    var selectedButton: UIButton? = nil
    
    var acceptOrReject = 0
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var loadingData = false
    var isLoading = false
    var isNewLoading = false
    
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var allBtn: UIButton?
    @IBOutlet weak var clapBtn: UIButton?
    @IBOutlet weak var threadBtn: UIButton?
    @IBOutlet weak var viewBtn: UIButton?
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataAvailLbl: UILabel!
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        doneButtonKeyboard()
        //UIApplication.shared.cancelAllLocalNotifications()
        
        self.notificationTableView?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        
        
        
    }
    
    
    /**
     Done button has been added in the keyboard to dismiss the keyboard.
     */
    fileprivate func doneButtonKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        searchBar.inputAccessoryView = doneToolbar
    }
    
    
    
    /**
     It is used to dimiss the current page
     */
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //isNewLoading = true
        print(isNewLoading)
        if !isNewLoading{
            self.notificationTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.notificationTableView.reloadData()
            self.isLoading = true
            
            selectedButton?.setGradientBackgroundColors([UIColor.white], direction: .toRight, for: .normal)
            selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
            selectedButton?.layer.borderWidth = 0.5
            selectedButton?.layer.cornerRadius = 6
            selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
            
            allBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            clapBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            threadBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            viewBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            allBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
            clapBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
            threadBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
            viewBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
            
            allBtn?.setTitleColor(UIColor.white, for: .normal)
            clapBtn?.setTitleColor(UIColor.lightGray, for: .normal)
            threadBtn?.setTitleColor(UIColor.lightGray, for: .normal)
            viewBtn?.setTitleColor(UIColor.lightGray, for: .normal)
            
            viewModel.notificstionListData = []
            
            updateButtonSelection(allBtn ?? UIButton())
            noDataImage.isHidden = true
            noDataAvailLbl.isHidden = true
            searchBar.text = ""
            disableBtn()
            notificationApiCall(notifytype: 0, searchTxt: "", nextPage: 1, isSearch: false)
            
            tableInitialSetUp()
            setUpNotificationViewModel()
            setUpNotificationreadViewModel()
        }else{
            self.isNewLoading = false
            
        }
    }
    
    
    
    
    /// Call the api using view model to set the datas using observer
    /// - Parameters:
    ///   - notifytype: Send the type of notification like 0,1, 2
    ///   - searchTxt: Search the notification using searchbar
    ///   - nextPage: set the next page key for pagination
    ///   - isSearch: Search can be update for using booleam to reload the datas
    func notificationApiCall(notifytype:Int,searchTxt:String,nextPage:Int,isSearch:Bool) {
        
        let notifyDict = [
            "text" : searchTxt,
            "typeOfNotify" : notifytype,
            "paginator":["nextPage": nextPage,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.notificationListApiCall(postDict: notifyDict, isSearch: isSearch)
        
    }
    
    /// Setup the tableview with delegates and datasource
    func tableInitialSetUp() {
        
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.tableFooterView = UIView()
        
        self.searchBar.searchTextField.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.font = UIFont.MontserratRegular(.normal)
        
    }
    
    ///Observe the api call to set the datas in the  tableview
    func setUpNotificationViewModel() {
        viewModel.notificationModel.observeError = { [weak self] error in
            guard let self = self else { return }
            self.enableBtn()
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.notificationModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false && self.viewModel.notificstionListData.count > 0 {
                self.noDataImage.isHidden = true
                self.noDataAvailLbl.isHidden = true
                self.notificationTableView.isHidden = false
                
                
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    self.loadingData = false
                }else{
                    self.loadingData = true
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() ) {
                    self.enableBtn()
                    self.isLoading = false
                    self.notificationTableView.reloadData()
                    
                }
                
                
            } else {
                self.enableBtn()
                self.noDataImage.isHidden = false
                self.noDataAvailLbl.isHidden = false
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.notificationTableView.isHidden = true
                    if self.selectedButton?.tag == 0 {
                        self.noDataImage.image = #imageLiteral(resourceName: "no_all_image")
                        self.noDataAvailLbl.text = "No notifications available."
                    }
                    else if self.selectedButton?.tag == 1 {
                        self.noDataImage.image = #imageLiteral(resourceName: "no_clap_notification")
                        self.noDataAvailLbl.text = "No Claps notification available."
                    }
                    else if self.selectedButton?.tag == 2 {
                        self.noDataImage.image = #imageLiteral(resourceName: "no_thread_notification")
                        self.noDataAvailLbl.text = "No Loops notification available."
                    }
                    else if self.selectedButton?.tag == 3 {
                        self.noDataImage.image = #imageLiteral(resourceName: "no_view_notification")
                        self.noDataAvailLbl.text = "No Eyeshots notification available."
                    }
                    self.notificationTableView.reloadData()
                }
                
            }
            
        }
        
    }
    
    /// After accepting or decline call the observer for notification read model
    func setUpNotificationreadViewModel() {
        viewModel.notificationReadModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.notificationReadModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                self.viewModel.notificstionListData[self.acceptCloseBtnSelectdIndexPath].isShowButton = false
                
                //                DispatchQueue.main.async {
                //                    self.notificationTableView.reloadData()
                //                }
                
                self.viewModel.notificstionListData = []
                
                self.notificationApiCall(notifytype: 0, searchTxt: "", nextPage: 1, isSearch: false)
                
            }
            
        }
        
    }
    
}

extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewModel.notificstionListData.count == 0{
            if isLoading{
                return 10
            }
            else{
                return 10
            }
        }
        else{
            return viewModel.notificstionListData.count
        }
        
        
        //return viewModel.notificstionListData.count == 0 ? 1 : viewModel.notificstionListData.count
    }
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewModel.notificstionListData.count == 0  {
            if isLoading{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell
                else { preconditionFailure("Failed to load collection view cell") }
                
                cell.showDummy()
                return cell
            }
            else{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell
                else { preconditionFailure("Failed to load collection view cell") }
                
                cell.showDummy()
                return cell
            }
            
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell
            else { preconditionFailure("Failed to load collection view cell") }
            
            if isLoading{
                cell.showDummy()
            }
            else{
                cell.hideDummy()
                cell.acceptDeclineDelegate = self
                cell.acceptBtn.tag = indexPath.row
                cell.declineBtn.tag = indexPath.row
                cell.viewModelCell = viewModel.notificationData(indexpath: indexPath)
            }
            return cell
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
        
        if viewModel.notificstionListData.count == 0{
            if isLoading{
                return UITableView.automaticDimension
            }
            else{
                return tableView.frame.height
            }
            
        }
        else{
            return UITableView.automaticDimension
        }
        
        //return viewModel.notificstionListData.count == 0 ?  : UITableView.automaticDimension
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
        if viewModel.notificstionListData.count > 0  {
            //print(viewModel.notificstionListData[indexPath.row].typeOfNotify)
            print(viewModel.notificstionListData[indexPath.row].typeOfNotify)
            switch viewModel.notificstionListData[indexPath.row].typeOfNotify {
                
            case 1,2:
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                let detailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                detailVC.postId = viewModel.notificstionListData[indexPath.row].postId ?? ""
                detailVC.threadId = viewModel.notificstionListData[indexPath.row].threadId ?? ""
                detailVC.userId = viewModel.notificstionListData[indexPath.row].userId ?? ""
                SessionManager.sharedInstance.userIdFromSelectedBubbleList = viewModel.notificstionListData[indexPath.item].userId ?? ""
                SessionManager.sharedInstance.threadId = viewModel.notificstionListData[indexPath.row].threadId ?? ""
                detailVC.isFromBubble = false
                detailVC.isFromHomePage = false
                detailVC.postType = 0
                detailVC.delegate = self
                detailVC.backDelegate = self
                detailVC.isFromNotificationPage = true
                
                
                detailVC.myPostId = viewModel.notificstionListData[indexPath.row].postId ?? ""
                detailVC.myThreadId = viewModel.notificstionListData[indexPath.row].threadId ?? ""
                detailVC.myUserId = viewModel.notificstionListData[indexPath.row].userId ?? ""
                
                SessionManager.sharedInstance.selectedIndexTabbar = 3
                self.navigationController?.pushViewController(detailVC, animated: true)
            case 3,7:
                let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                let feedDetailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                feedDetailVC.postId = viewModel.notificstionListData[indexPath.item].postId ?? ""
                //feedDetailVC.selectedMemberPostId = viewModel.notificstionListData[indexPath.item].postId ?? ""
                feedDetailVC.selectedMemberAnonymous = viewModel.notificstionListData[indexPath.item].allowAnonymous ?? false
                feedDetailVC.threadId = viewModel.notificstionListData[indexPath.item].threadId ?? ""
                feedDetailVC.isFromBubble = false
                feedDetailVC.isCallBubbleAPI = false
                feedDetailVC.backDelegate = self
                feedDetailVC.isFromNotificationPage = true
                feedDetailVC.senderUserName = viewModel.notificstionListData[indexPath.item].displayName ?? ""
                
                feedDetailVC.myPostId = viewModel.notificstionListData[indexPath.row].postId ?? ""
                feedDetailVC.myThreadId = viewModel.notificstionListData[indexPath.row].threadId ?? ""
                feedDetailVC.myUserId = viewModel.notificstionListData[indexPath.row].userId ?? ""
                
                
                SessionManager.sharedInstance.userIdFromSelectedBubbleList = viewModel.notificstionListData[indexPath.item].userId ?? ""
                SessionManager.sharedInstance.threadId = viewModel.notificstionListData[indexPath.item].threadId ?? ""
                SessionManager.sharedInstance.selectedIndexTabbar = 3
                self.navigationController?.pushViewController(feedDetailVC, animated: true)
                
            case 8:
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                let feedDetailVC = storyBoard.instantiateViewController(identifier: FEED_DETAIL_STORYBOARD) as! FeedDetailsViewController
                feedDetailVC.postId = viewModel.notificstionListData[indexPath.item].postId ?? ""
                //feedDetailVC.selectedMemberPostId = viewModel.notificstionListData[indexPath.item].postId ?? ""
                feedDetailVC.selectedMemberAnonymous = viewModel.notificstionListData[indexPath.item].allowAnonymous ?? false
                feedDetailVC.threadId = viewModel.notificstionListData[indexPath.item].threadId ?? ""
                feedDetailVC.isFromBubble = false
                feedDetailVC.isCallBubbleAPI = false
                feedDetailVC.backDelegate = self
                feedDetailVC.isFromNotificationPage = true
                feedDetailVC.senderUserName = viewModel.notificstionListData[indexPath.item].displayName ?? ""
                
                feedDetailVC.myPostId = viewModel.notificstionListData[indexPath.row].postId ?? ""
                feedDetailVC.myThreadId = viewModel.notificstionListData[indexPath.row].threadId ?? ""
                feedDetailVC.myUserId = viewModel.notificstionListData[indexPath.row].userId ?? ""
                
                
                SessionManager.sharedInstance.userIdFromSelectedBubbleList = viewModel.notificstionListData[indexPath.item].userId ?? ""
                SessionManager.sharedInstance.threadId = viewModel.notificstionListData[indexPath.item].threadId ?? ""
                SessionManager.sharedInstance.selectedIndexTabbar = 3
                self.navigationController?.pushViewController(feedDetailVC, animated: true)
                
            default:
                break
            }
        }
    }
}


extension NotificationViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        viewModel.notificstionListData = []
        self.isLoading = true
        self.notificationTableView.reloadData()
        if searchText.count > 2 {
            notificationApiCall(notifytype: notifytype, searchTxt: searchText, nextPage: 1, isSearch: true)
        }else if searchText.count == 0{
            
            
            notificationApiCall(notifytype: notifytype, searchTxt: searchText, nextPage: 1, isSearch: true)
        }
        
        
    }
    
    
    
    
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`~!@#$%^&*_+={}:;'<>.,?/0123456789"
        
        let newString = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)
        
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = newString.components(separatedBy: cs).joined(separator: "")
        
        if filtered.count >= 30 {
            showErrorAlert(error: "Please enter less than 30 characters.")
            return false
        }
        return (newString == filtered)
        
    }
}

extension NotificationViewController : acceptDeclineDelegate {
    /// When pressing accept or decline this method will called and api will be call.
    func acceptDeclineTapped(sender: UIButton, acceptOrReject: Int) {
        
        acceptCloseBtnSelectdIndexPath = sender.tag
        
        self.acceptOrReject = acceptOrReject
        
        let readParam = [
            "notifyId" : viewModel.notificstionListData[sender.tag].notifyId ?? "",
            "typeOfNotify" : viewModel.notificstionListData[sender.tag].typeOfNotify ?? "",
            "isShowButton": false,
            "isAccept": acceptOrReject] as [String : Any]
        
        viewModel.notificationReadApiCall(postDict: readParam)
    }
}

extension NotificationViewController {
    
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == notificationTableView {
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                loadMoreData()
            }
        }
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        //
        if !self.loadingData  {
            self.disableBtn()
            self.loadingData = true
            
            self.nextPageKey = self.viewModel.notificationModel.value?.data?.paginator?.nextPage ?? 0
            
            notificationApiCall(notifytype: notifytype, searchTxt: searchBar.text ?? "", nextPage: nextPageKey, isSearch: false)
        }
        else{
            self.enableBtn()
        }
    }
    
    
}

extension NotificationViewController {
    
    
    /// Segment button is used to select the buttons in the notification and it will highlight and call the api using buttons.
    ///  - It will filter according to All, Claps, Loops & Eyshots
    @IBAction func segmentButtonTapped(sender:UIButton) {
        
        searchBar.text = ""
        nextPageKey = 1
        viewModel.notificstionListData = []
        if(selectedButton == nil) { // No previous button was selected
            
            updateButtonSelection(sender)
            
        } else{ // User have already selected a button
            
            if(selectedButton != sender){ // Not the same button
                
                selectedButton?.setGradientBackgroundColors([UIColor.white], direction: .toRight, for: .normal)
                selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
                selectedButton?.layer.borderWidth = 0.5
                selectedButton?.layer.cornerRadius = 6
                selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
                selectedButton?.layer.masksToBounds = true
                updateButtonSelection(sender)
            }
            
        }
        
        if sender.tag == 0 {
            
            allBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            clapBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            threadBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            viewBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.noDataImage.isHidden = true
            self.noDataAvailLbl.isHidden = true
            self.notificationTableView.isHidden = false
            self.notificationTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.notificationTableView.reloadData()
            self.isLoading = true
            self.disableBtn()
            notifytype = 0
            notificationApiCall(notifytype: 0, searchTxt: "", nextPage: nextPageKey, isSearch: false)
            
        } else if sender.tag == 1 {
            
            allBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            clapBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            threadBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            viewBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.noDataImage.isHidden = true
            self.noDataAvailLbl.isHidden = true
            self.notificationTableView.isHidden = false
            self.notificationTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.notificationTableView.reloadData()
            self.isLoading = true
            self.disableBtn()
            notifytype = 1
            notificationApiCall(notifytype: 1, searchTxt: "", nextPage: nextPageKey, isSearch: false)
            
        } else if sender.tag == 2 {
            
            allBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            clapBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            threadBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            viewBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.noDataImage.isHidden = true
            self.noDataAvailLbl.isHidden = true
            self.notificationTableView.isHidden = false
            self.notificationTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.notificationTableView.reloadData()
            self.isLoading = true
            self.disableBtn()
            notifytype = 3
            notificationApiCall(notifytype: 3, searchTxt: "", nextPage: nextPageKey, isSearch: false)
            
        } else if sender.tag == 3 {
            
            allBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            clapBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            threadBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            viewBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            self.noDataImage.isHidden = true
            self.noDataAvailLbl.isHidden = true
            self.notificationTableView.isHidden = false
            self.notificationTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.notificationTableView.reloadData()
            self.isLoading = true
            self.disableBtn()
            notifytype = 2
            notificationApiCall(notifytype: 2, searchTxt: "", nextPage: nextPageKey, isSearch: false)
        }
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
    
    /// Enable the button after all the api calls
    func enableBtn(){
        self.allBtn?.isEnabled = true
        self.clapBtn?.isEnabled = true
        self.threadBtn?.isEnabled = true
        self.viewBtn?.isEnabled = true
    }
    
    
    /// Disable the button when api call is on progress
    func disableBtn(){
        self.allBtn?.isEnabled = false
        self.clapBtn?.isEnabled = false
        self.threadBtn?.isEnabled = false
        self.viewBtn?.isEnabled = false
    }
    
    
    
}
