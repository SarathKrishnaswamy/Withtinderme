//
//  BlockUserViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit
import UIView_Shimmer

class BlockedUserListViewController: UIViewController {
    
    
    /**
     This class is used to show the list user that has been blocked by the current user.
     */

    @IBOutlet var tableView:UITableView?
    
    @IBOutlet weak var threadPopUpBgView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpMaybeLaterBtn: UIButton!
    @IBOutlet weak var threadPopUpStartThreadBtn: UIButton!
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var loadingData = false
    
    var viewModel = BlockedUserListViewModel()

    var selectedUserTag = 0
    var isLoading = false
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.register(UINib(nibName: "BlockedUserListTableViewCell", bundle: nil), forCellReuseIdentifier: BlockedUserListTableViewCell.identifier)
        self.tableView?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        searchBar?.backgroundImage = UIImage() //To clear border line from search bar
        searchBar?.searchTextField.font = UIFont.MontserratRegular(.normal)
        searchBar?.placeholder = "Search here"
        doneButtonKeyboard()
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
    
    
    
    /// This is used to call the api in the view model
    /// - Parameters:
    ///   - nextPage: Send the next page key
    ///   - text: send the searched string
    ///   - isSearch: send is searched or not using boolean
    fileprivate func blockedUserList(nextPage:Int,text:String,isSearch:Bool) {
        let param = [
            "text" : text,
            "paginator":["nextPage": nextPage,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.blockedUserListAPICallNoLoading(postDict: param, isSearch: isSearch)
    }
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isLoading = true
        searchBar?.text = ""
        searchBar?.placeholder = "Search here"
        
        setUpBlockedUserListObserver()
        setUpUnBlockSelectedUserObserver()
        
        viewModel.userList = []
        
        blockedUserList(nextPage: 1, text: "", isSearch: false)
        
        self.tableView?.tableFooterView = UIView()
        
    }
    
    
    
    
    ///Setuped the blocked list user to observe the values and set in the liset using tableview
    /// - Set the paginator loadinging value here
    func setUpBlockedUserListObserver() {
        viewModel.blockedUserList.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.blockedUserList.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    self.loadingData = false
                }else{
                    self.loadingData = true
                }
                
               
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoading = false
                    self.tableView?.reloadData()
                }
                
            }
            
        }
        
    }
    
    
    ///Back button tapped to dismiss the current page
    @IBAction func backButtonTapped(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Add the user button tapped to navigate the list of friends can be blocked.
    @IBAction func addUserButtonTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let blockUserVC = storyBoard.instantiateViewController(identifier: "BlockUserViewController") as! BlockUserViewController
        self.navigationController?.pushViewController(blockUserVC, animated: true)
        
    }
    
    
}

extension BlockedUserListViewController : UITableViewDelegate,UITableViewDataSource {
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if viewModel.userList.count == 0{
            if isLoading{
                return 10
            }
            else {
                return 1
            }
        }
        else{
            return viewModel.userList.count
        }
        
        
        //viewModel.userList.count == 0 ? 1 : viewModel.userList.count
    }
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if viewModel.userList.count == 0 {
            self.searchBar.isHidden = true
            if isLoading{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.identifier, for: indexPath) as? BlockedUserListTableViewCell
                else {
                    preconditionFailure("Failed to load collection view cell")
                }
                cell.showDummy()
                return cell
            }
            else{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NoDataTableViewCell
                else { preconditionFailure("Failed to load collection view cell") }
                
                cell.imgView.image = #imageLiteral(resourceName: "blockedUserList")
                cell.noDataLbl.text = "No blocked members!"
                
                return cell
            }
            
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.identifier, for: indexPath) as? BlockedUserListTableViewCell
        else {
            preconditionFailure("Failed to load collection view cell")
        }
        self.searchBar.isHidden = false
        cell.hideDummy()
        cell.blockBtn.setTitle("Unblock", for: .normal)
        cell.blockBtn.tag = indexPath.row
        cell.blockDelegate = self
        cell.viewModelCell = viewModel.BlockedUserList(indexpath: indexPath)
        
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
        if viewModel.userList.count == 0 {
            if isLoading{
                return 80
            }
            else{
               return tableView.frame.height
            }
        }
        else{
            return 80
        }
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
    
}

extension BlockedUserListViewController : blockUserDelegate{
    
    
    /// Block user method to call the api in the view model
    /// - Parameter sender: <#sender description#>
    ///  - It Communicates a connection between BlockedUserListTableViewCell and BlockedUserListViewController class
    func blockUser(sender: UIButton) {
        
        selectedUserTag = sender.tag
        blockSelectedUserAPICall(userId: viewModel.userList[sender.tag].userId ?? "")
        

    }
    
    ///It will observe the value and set the value in the list and and reload the data
    func setUpUnBlockSelectedUserObserver() {
        viewModel.blockedUserList.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.blockSelectedUser.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                self.viewModel.userList.remove(at: self.selectedUserTag)
                DispatchQueue.main.async {
                    //self.searchBar.text = ""
                    self.tableView?.reloadData()
                }
            }
        }
    }
    
    ///It will call to block or unblock the user for selected user in the list
    func blockSelectedUserAPICall(userId:String) {
        let param = [
            "userId" : userId,
            "status":false
        ] as [String : Any]
        
        viewModel.blockSelectedUserAPICall(postDict: param)
    }
}

extension BlockedUserListViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.userList = []
        self.nextPageKey = 1
        if searchText.count > 2 {
            searchBar.placeholder = ""
            blockedUserList(nextPage: 1, text: searchText, isSearch: true)
        }else if searchText.count == 0{
            searchBar.placeholder = "Search here"
            blockedUserList(nextPage: 1, text: searchText, isSearch: true)
        }
    }
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
        
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

extension BlockedUserListViewController {
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                loadMoreData()
            }
        }
    }
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData  {
            self.loadingData = true
            self.nextPageKey =  self.viewModel.blockedUserList.value?.data?.paginator?.nextPage ?? 1
            blockedUserList(nextPage: nextPageKey, text: "", isSearch: false)
        }
    }
    
    
}
