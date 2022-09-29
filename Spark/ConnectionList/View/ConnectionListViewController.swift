//
//  ConnectionListViewController.swift
//  Spark me
//
//  Created by adhash on 24/08/21.
//

import UIKit
import Lottie
import UIView_Shimmer

/**
 This class is used  to show all the friends in the closed connection List page.
 */
class ConnectionListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var myConectionBtn: UIButton?
    @IBOutlet weak var globalBtn: UIButton?
    var selectedButton: UIButton? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLbl: UILabel!
   
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var isGlobalList = false
    var selectedUserTag = 0
    var isLoading = false

    //paginator
    var loadingData = false
    
    var viewModel = BlockedUserListViewModel()
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "BlockedUserListTableViewCell", bundle: nil), forCellReuseIdentifier: BlockedUserListTableViewCell.identifier)
        
        self.tableView?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.noDataImage.isHidden = true
        self.noDataLbl.isHidden = true
        self.noDataLbl.text = "There are no connections found! \nPlease clap appropriate spark and start the loop"
        doneButtonKeyboard()
        searchBar.text = ""
        searchBar?.placeholder = "Search here"
        
        myConectionBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        globalBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        
        myConectionBtn?.setTitleColor(UIColor.white, for: .normal)
        globalBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        self.noDataImage.isHidden = true
        self.noDataLbl.isHidden = true
        self.noDataImage.image = UIImage(named: "no_connection_list")
        updateButtonSelection(myConectionBtn ?? UIButton())
        viewModel.userList = []
        isGlobalList = false
        self.isLoading = true
        setUpBlockedUserListObserver()
        blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        selectedButton?.setGradientBackgroundColors([UIColor.white], direction: .toRight, for: .normal)
//        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
//        selectedButton?.layer.borderWidth = 0.5
//        selectedButton?.layer.cornerRadius = 6
//        selectedButton?.setTitleColor(UIColor.lightGray, for: .normal)
//
//        myConectionBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
//        globalBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       
        
    }
    
    /**
     It is used to list the friends in the view controller with the api call to update
     - Parameters:
     - isGlobal: isGlobal is used as bool value
     - nextPage:  set the next page key
     - text: check the text for search in search bar
     - isSearch: set it is from issearch bool value
     */
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
        
        
        searchBar?.backgroundImage = UIImage() //To clear border line from search bar
        searchBar?.searchTextField.font = UIFont.MontserratRegular(.normal)
        self.tableView?.tableFooterView = UIView()
        
    }
    
    
    
    
    /// Observe all the datas to set in the list for set in the each cell
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
                    self.tableView.isHidden = false
                    self.noDataImage.isHidden = true
                    
                    self.noDataLbl.isHidden = true
                }
                else{
                    self.tableView.isHidden = true
                    self.noDataImage.isHidden = false
                    self.noDataLbl.isHidden = false
                }
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    
                    self.loadingData = false
                    
                }else{
                   
                    self.loadingData = true
                    
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    self.tableView?.reloadData()
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.globalBtn?.isEnabled = true
                    self.myConectionBtn?.isEnabled = true
                }
                    
                //}
            }
        }
    }
    
    /// Back button pressed to dismiss the cureent page.
    @IBAction func BackButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
   
    /// Segment button is tapped select the button as my connections or global list according to the tag
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
            self.tableView.isHidden = false
            
            self.noDataImage.isHidden = true
            self.noDataLbl.isHidden = true
            
            
            
            
            self.isLoading = true
            self.tableView?.reloadData()
            
            self.globalBtn?.isEnabled = false
            self.myConectionBtn?.isEnabled = false
            viewModel.userList = []
            isGlobalList = false
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
           
            
        } else if sender.tag == 1 {
            
            myConectionBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            globalBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            self.tableView.isHidden = false
            
            self.noDataImage.isHidden = true
            self.noDataLbl.isHidden = true
            
            //self.tableView.isHidden = false
            self.isLoading = true
            self.tableView?.reloadData()
            
            
            self.globalBtn?.isEnabled = false
            self.myConectionBtn?.isEnabled = false
            viewModel.userList = []
            isGlobalList = true
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: "", isSearch: false)
           
        }
    }
    
    /// Update the selected button as gradient color with the corner radius
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

extension ConnectionListViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
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
        
        if isLoading{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.identifier, for: indexPath) as? BlockedUserListTableViewCell
            else {
                preconditionFailure("Failed to load collection view cell")
            }
            cell.showDummy()
            
            return cell
        }
        else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.identifier, for: indexPath) as? BlockedUserListTableViewCell
            else {
                preconditionFailure("Failed to load collection view cell")
            }
            cell.hideDummy()
            cell.blockBtn.tag = indexPath.row
            cell.blockDelegate = self
            cell.blockBtn.setTitle("View Profile", for: .normal)
            cell.viewModelCell = viewModel.BlockedUserList(indexpath: indexPath)
            
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
        if isLoading{
            return 80
        }
        else{
            
            return 80
        }
        // viewModel.userList.count == 0 ? tableView.frame.height : 80
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

extension ConnectionListViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText.count > 2 {
            searchBar.placeholder = ""
            //viewModel.userList = []
            self.nextPageKey = 1
            blockUserAPICall(isGlobal: isGlobalList, nextPage: 1, text: searchText, isSearch: true)
        }else if searchText.count == 0 {
            searchBar.placeholder = "Search here"
            //viewModel.userList = []
            self.nextPageKey = 1
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



extension ConnectionListViewController {
    
    
    
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
    
    /// Load more data usnig pagination
    func loadMoreData() {
        if !self.loadingData  {
            self.loadingData = true
            self.nextPageKey =  self.viewModel.blockedUserList.value?.data?.paginator?.nextPage ?? 1
            blockUserAPICall(isGlobal: isGlobalList, nextPage: nextPageKey, text: searchBar.text ?? "", isSearch: false)
        }
    }
    
}

extension ConnectionListViewController : blockUserDelegate{
    /// View the profile page while clicking on view profile button.
    func blockUser(sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let connectionListVC = storyBoard.instantiateViewController(identifier: "ConnectionListUserProfileViewController") as! ConnectionListUserProfileViewController
        connectionListVC.userId = viewModel.userList[sender.tag].userId ?? ""
        self.navigationController?.pushViewController(connectionListVC, animated: true)
    }
}


