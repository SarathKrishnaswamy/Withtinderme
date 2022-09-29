//
//  BlockUserViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 30/08/21.
//

import UIKit
import UIView_Shimmer

/**
 This class is used to show the list of users in my connections and global list to block
 */

class BlockUserViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var myConectionBtn: UIButton?
    @IBOutlet weak var globalBtn: UIButton?
    var selectedButton: UIButton? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLbl: UILabel!
   
   // @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var NoDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var isGlobalList = false
    var selectedUserTag = 0

    //paginator
    var loadingData = false
    
    //Shimmer Loading
    var isLoading = false
    
    var viewModel = BlockedUserListViewModel()
    
    @IBOutlet weak var threadPopUpBgView: UIView!
    
    @IBOutlet weak var threadPopUpImgView: UIImageView!
    @IBOutlet weak var threadPopUpDesclbl: UILabel!
    @IBOutlet weak var threadPopUpStackView: UIStackView!
    @IBOutlet weak var threadPopUpMaybeLaterBtn: UIButton!
    @IBOutlet weak var threadPopUpStartThreadBtn: UIButton!
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "BlockedUserListTableViewCell", bundle: nil), forCellReuseIdentifier: BlockedUserListTableViewCell.identifier)
        self.tableView?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        threadPopUpStartThreadBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        threadPopUpStartThreadBtn.layer.cornerRadius = 6.0
        threadPopUpStartThreadBtn.clipsToBounds = true
        threadPopUpBgView.isHidden = true
        threadPopUpBgView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
        doneButtonKeyboard()
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedButton?.setGradientBackgroundColors([UIColor.white], direction: .toRight, for: .normal)
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 6
        selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
        
        myConectionBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
        globalBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       
        
    }
    
    
    
    
    
    
    /// It is used to comminucates a class between view model to call the api to set the list of users
    /// - Parameters:
    ///   - isGlobal: Check whether its a global list or my connection list
    ///   - nextPage: Its used to set the next page key
    ///   - text: Text to search from search bar
    ///   - isSearch: Whether it is from search or without search
    fileprivate func blockUserAPICall(isGlobal:Bool,nextPage:Int,text:String,isSearch:Bool) {
        let param = [
            "text" : text,
            "isGlobal":isGlobal,
            "paginator":["nextPage": nextPage,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.blockUserAPICallNoLoading(postDict: param, isSearch: isSearch)
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
        super.viewWillAppear(animated)
        
        self.isLoading = true
        self.tableView.isHidden = false
        self.noDataLbl.isHidden = true
        self.NoDataImg.isHidden = true
        searchBar?.backgroundImage = UIImage() //To clear border line from search bar
        searchBar?.searchTextField.font = UIFont.MontserratRegular(.normal)
        searchBar?.placeholder = "Search here"
        
        myConectionBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        globalBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        
        myConectionBtn?.setTitleColor(UIColor.white, for: .normal)
        globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
       
        updateButtonSelection(myConectionBtn ?? UIButton())
        
        setUpBlockedUserListObserver()
        setUpBlockSelectedUserObserver()
        
        self.tableView?.tableFooterView = UIView()
        
        blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
        
    }
    
    
    ///Setup the observer to thrw the error and success to save api details  in list
    func setUpBlockedUserListObserver() {
        viewModel.blockedUserList.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.blockedUserList.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data?.users?.count ?? 0 > 0{
                    if value.data?.paginator?.nextPage ?? 0 > 0 {
                        self.loadingData = false
                      
                    }else{
                        
                        
                        self.loadingData = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        self.isLoading = false
                        self.tableView.isHidden = false
                        self.noDataLbl.isHidden = true
                        self.NoDataImg.isHidden = true
                        self.tableView?.reloadData()
                    }
                }
                else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isLoading = false
                        self.tableView?.reloadData()
                        self.tableView.isHidden = true
                        self.noDataLbl.isHidden = false
                        self.noDataLbl.text = "There are no Connections found! \nPlease Clap appropriate Spark and start the Loop"
                        self.NoDataImg.isHidden = false
                        self.NoDataImg.image = #imageLiteral(resourceName: "no_connection_list")
                        
                        
                        /* guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NoDataTableViewCell
                         else { preconditionFailure("Failed to load collection view cell") }

                         cell.imgView.image = #imageLiteral(resourceName: "no_connection_list")
                         cell.noDataLbl.text = "There are no Connections found! \nPlease Clap appropriate Spark and start the Loop"

                         return cell*/
                    }
                }
                
            }
        }
    }
    
    /// Back button is used dismiss the page.
    @IBAction func BackButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
   
    ///Segmet is used to select the button global list or my connections using tag to select the button selection
    @IBAction func segmentButtonTapped(sender:UIButton) {
                
        searchBar.text = ""
        viewModel.userList = []
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
            
            myConectionBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            globalBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.noDataLbl.isHidden = true
            self.NoDataImg.isHidden = true
            self.isLoading = true
            self.tableView.reloadData()
            self.tableView.isHidden = false
            
            viewModel.userList = []
            isGlobalList = false
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
           
            
        } else if sender.tag == 1 {
            
            myConectionBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            globalBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            self.noDataLbl.isHidden = true
            self.NoDataImg.isHidden = true
            self.isLoading = true
            self.tableView.reloadData()
            self.tableView.isHidden = false
            viewModel.userList = []
            isGlobalList = true
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
           
        }
    }
    
    
    /// Update the button selection to select the gradient of start color and end colour.
    func updateButtonSelection(_ sender: UIButton){
        
        selectedButton = sender
        selectedButton?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 6
        selectedButton?.layer.masksToBounds = true
        selectedButton?.setTitleColor(UIColor.white, for: .normal)
        
    }
    
}

extension BlockUserViewController : UITableViewDelegate,UITableViewDataSource {
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading{
            return 10
        }
        else{
            return viewModel.userList.count
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.identifier, for: indexPath) as? BlockedUserListTableViewCell
        else {
            preconditionFailure("Failed to load collection view cell")
        }
        
        if isLoading{
            cell.showDummy()
        }
        else{
            cell.hideDummy()
            
            if viewModel.userList[indexPath.row].isBlocked ?? false {
                cell.blockBtn.setTitle("Blocked", for: .normal)
                cell.blockBtn.setTitleColor(UIColor.black, for: .normal)
                cell.blockBtn.tag = indexPath.row
                cell.blockDelegate = self
                cell.viewModelCell = viewModel.BlockedUserList(indexpath: indexPath)
                cell.bgView.backgroundColor = UIColor.CellPlaceholderColor
            } else {
                cell.blockBtn.setTitle("Block", for: .normal)
                cell.blockBtn.setTitleColor(UIColor.init(hexString: "#358383"), for: .normal)
                cell.blockBtn.tag = indexPath.row
                cell.blockDelegate = self
                cell.viewModelCell = viewModel.BlockedUserList(indexpath: indexPath)
                cell.bgView.backgroundColor = UIColor.white
            }
            
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
        
        
        if isLoading{
            return 80
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

extension BlockUserViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //viewModel.userList = []
        self.nextPageKey = 1
        if searchText.count > 2 {
            searchBar.placeholder = ""
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: searchText, isSearch: true)
        }else if searchText.count == 0 {
            searchBar.placeholder = "Search here"
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: searchText, isSearch: true)
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


extension BlockUserViewController : blockUserDelegate{
    
    ///Cancel button tapped to hide the popview
    @IBAction func cancelButtonTapped(sender:UIButton) {
        threadPopUpBgView.isHidden = true
    }
    
    ///Clicking of yes button to block the user.
    @IBAction func yesButtonTapped(sender:UIButton) {
        
        threadPopUpBgView.isHidden = true
        blockSelectedUserAPICall(userId: viewModel.userList[selectedUserTag].userId ?? "")
        self.searchBar.text = ""

    }
    
    /// Block user method is used to call the popup to be hide
    func blockUser(sender: UIButton) {
        if sender.titleLabel?.text != "Blocked" {
            self.threadPopUpBgView.isHidden = false
            threadPopUpDesclbl.text = "Are you sure you want to block \(viewModel.userList[sender.tag].displayName ?? "")?"
            selectedUserTag = sender.tag
        }
    }
    
    
    /// Setup the observer to block the user to show the error or success
    func setUpBlockSelectedUserObserver() {
        viewModel.blockedUserList.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.blockSelectedUser.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                self.viewModel.userList = []
                self.blockUserAPICall(isGlobal: self.isGlobalList, nextPage: 1, text: "", isSearch: false)
               // self.viewModel.userList.remove(at: self.selectedUserTag)
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
        }
    }
    
    /// block the selected user list to call the api of "users/blockedUserSave"
    func blockSelectedUserAPICall(userId:String) {
        let param = [
            "userId" : userId,
            "status":true
        ] as [String : Any]
        
        viewModel.blockSelectedUserAPICall(postDict: param)
    }
}

extension BlockUserViewController {
    
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            
            if scrollView.contentOffset.y > (scrollView.contentSize.height - (scrollView.frame.size.height)) && scrollView.contentSize.height > 0
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
            blockUserAPICall(isGlobal: isGlobalList, nextPage: nextPageKey, text: searchBar.text ?? "", isSearch: false)
        }
    }
    
}
