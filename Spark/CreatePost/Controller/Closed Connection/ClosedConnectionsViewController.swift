//
//  ClosedConnectionsViewController.swift
//  Spark
//
//  Created by Gowthaman P on 17/07/21.
//

import UIKit
import SDWebImage
import UIView_Shimmer

protocol getSelectedClosedConnectionList: AnyObject {
    /// Set the array of string to the friend list
    func closedConnectionList(friendsList:[String])
}


/**
 This class is used to set the collectionview of closed friends list it is used to select the friends and update the post for closed friends
 */
class ClosedConnectionsViewController: UIViewController {
    
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var doneBtn:UIButton?
    
    @IBOutlet weak var dimmedView:UIView!
    @IBOutlet weak var containerView:UIView!
    
    var delegate : getSelectedClosedConnectionList? = nil
    
    let maxDimmedAlpha: CGFloat = 0.6
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    // Constants
    let defaultHeight: CGFloat = 0
    let dismissibleHeight: CGFloat = 0
    let maximumContainerHeight: CGFloat = 0//UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 0
    
    let viewModel = ClosedConnectionsViewModel()
    
    @IBOutlet weak var closedConnectionSearchBar: UISearchBar!
    
    @IBOutlet weak var closedConnectionDescLabl: UILabel!
    
    var selectedFriendsList = [String]()
    
    var selectedFriendsListForLoaded : [ClosedConnectionFriends] = [ClosedConnectionFriends]()
    
   // var friendsListFromAPI = [ClosedConnectionFriends]()
    var searchtext = ""
    var loadingData = false
    var nextPageKey = 1
    var isLoading = false
    
    
    @IBOutlet weak var noDataView: UIView!
    
    
    
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
        closedConnectionSearchBar.inputAccessoryView = doneToolbar
    }
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLoading = true
        doneBtn?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toRight, for: .normal)
        doneBtn?.layer.cornerRadius = 8.0
        doneBtn?.clipsToBounds = true
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        collectionView?.allowsSelection = true
        collectionView?.allowsMultipleSelection = true
        
        self.closedConnectionSearchBar.showsCancelButton = false
        
        closedConnectionSearchBar.backgroundImage = UIImage()
        
        closedConnectionSearchBar.enablesReturnKeyAutomatically = true
        
        setupPanGesture()
        
        viewModel.closedConnectionFriendsData = []
        setUpClosedConnectionListViewModel()
        apiCallForClosedConnectionList(text: "", nextPageKey: 1, limit: 40)
        
        doneButtonKeyboard()
        
        let alignedFlowLayout = TagsLayout()
        collectionView?.collectionViewLayout = alignedFlowLayout
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        print("***************************************************")
        print(self.containerView.frame.origin.y)
        
    }
    
    
    
    /**
     It is used to dimiss the current page
     */
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    
    
    
    ///Keyboard will show and it will rise up with the view
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.containerView.frame.origin.y == self.containerView.frame.origin.y {
                self.containerView.frame.origin.y -= keyboardSize.height
            }
        }
    }

    /// Keyboard will hide and reset the view to old place
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.containerView.frame.origin.y != self.containerView.frame.origin.y {
            self.containerView.frame.origin.y = self.containerView.frame.origin.y
        }
    }
    
    
    /// It is used to observe all the friendslist count from the api and reload the collectionview to update the view.
    func setUpClosedConnectionListViewModel() {
        
        viewModel.closedViewModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.closedViewModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if let values = value.isOk, values {
                
                if value.data?.friends?.count ?? 0 > 0{
                    //self.friendsListFromAPI = []
                    //self.friendsListFromAPI.append(contentsOf: value.data?.friends ?? [ClosedConnectionFriends]())
                    self.noDataView.isHidden = true
                    self.collectionView?.isHidden = false
                    self.doneBtn?.isHidden = false
                    
                    self.isLoading = false
                    
                    print("*************************************")
                    print(self.viewModel.closedViewModel.value?.data?.paginator?.nextPage)
                    if value.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.closedConnectionFriendsData.count > 1{
                        self.loadingData = false
                    }
                    else{
                        self.loadingData = true
                    }
                    
                    
                    if self.viewModel.closedConnectionFriendsData.count > 0 {
                        self.isLoading = false
                        for selectedList in self.selectedFriendsListForLoaded {
                            if self.viewModel.closedConnectionFriendsData.count > 0 {
                                
                              
                                
                                self.doneBtn?.isHidden = false
                                for friendsListAPI in self.viewModel.closedConnectionFriendsData {
                                    
                                    if (selectedList.userId?.contains(friendsListAPI.userId ?? "")) ?? false {
                                        if self.viewModel.closedConnectionFriendsData.count > 0 {
                                            debugPrint(self.findToRemoveObjectWhileSearch(objecToFinds: friendsListAPI.userId) ?? 0)
                                            self.viewModel.closedConnectionFriendsData.remove(at: self.findToRemoveObjectWhileSearch(objecToFinds: friendsListAPI.userId) ?? 0)
                                        }
                                    }
                                    
                                }
                            } else {
                                self.noDataView.isHidden = false
                                self.collectionView?.isHidden = true
                                //self.loadingData = false
                            }
                            
                        }
                    }else{
                        self.noDataView.isHidden = false
                        self.collectionView?.isHidden = true
                        self.doneBtn?.isHidden = true
                        //self.loadingData = true
                        
                    }
                }
                else{
                    self.noDataView.isHidden = false
                    self.collectionView?.isHidden = true
                    self.doneBtn?.isHidden = true
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    //self.viewModel.closedConnectionFriendsData = []
                    self.collectionView?.reloadData()
                }
               
            }
        }
    }
    
    /// After selecting the friends list tap the done button to post the selected friends list
    @IBAction func doneButtonTapped(sender:UIButton) {
        
        if selectedFriendsList.count > 0{
            delegate?.closedConnectionList(friendsList: selectedFriendsList)
            self.dismiss(animated: true, completion: nil)
        }
        else{
            self.showErrorAlert(error: "Kindly choose at least one closed connection")
        }
        
        
       
    }
    
    
    /// Api call for closed connection list
    /// - Parameters:
    ///   - text: Searched text can be passed into this argument
    ///   - nextPageKey: Next page key need to pass
    ///   - limit: set the limit  to retrive the friends list fro paging
    func apiCallForClosedConnectionList(text:String,nextPageKey:Int, limit:Int ) {
        
        let closedConnectionDict = [
            "text" : text,
            "paginator":["nextPage": nextPageKey,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.closedConnectionListNoLoading(postDict:closedConnectionDict)
        
    }
    
    /// Api call for search and set the closed connection friends list
    func apiCallForSearchClosedConnectionList(text:String,nextPageKey:Int, limit:Int ) {
        
        let closedConnectionDict = [
            "text" : text,
            "paginator":["nextPage": nextPageKey,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.closedConnectionListSearchNoLoading(postDict: closedConnectionDict)
        
    }
    
    
    ///After pressing close action it will dismiss the page.
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    
    
    /// Setup the pan gesture to initialise
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    
    
    /// Handle the pan gesture to dismiss the page
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = 0
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    
    
    /// Show the container height with the animation
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    
    
    /// Show the bottom constraint contant to 0
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    /// The bg view will be dimmed with animation alpha will be shown.
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    
    
    
    /// The animate dimmedview alpha will be less and dismissed
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        
        if !self.loadingData {
            self.loadingData = true
            self.nextPageKey = viewModel.closedViewModel.value?.data?.paginator?.nextPage ?? 0
            self.apiCallForClosedConnectionList(text: searchtext, nextPageKey: nextPageKey, limit: 20)
        }
    }
}

extension ClosedConnectionsViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    /// Asks your data source object for the number of sections in the collection view.
    /// - Parameter collectionView: The collection view requesting this information.
    /// - Returns: The number of sections in collectionView.
    ///  - If you don’t implement this method, the collection view uses a default value of 1.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return selectedFriendsListForLoaded.count
        }
        else{
            if isLoading{
                return 10
            }
            else{
                return viewModel.closedConnectionFriendsData.count
            }
        }
        //return section == 0 ? selectedFriendsListForLoaded.count : friendsListFromAPI.count
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? closedConnectionCell
        
        if indexPath.section == 1 {
            
            if isLoading{
                cell?.showDummy()
            }
            else{
                cell?.hideDummy()
                cell?.imageView.layer.cornerRadius = 10.0
                cell?.clipsToBounds = true
                cell?.connectionSelectImg.isHidden = true
                
                let profilePic = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(viewModel.closedConnectionFriendsData[indexPath.item].profilePic ?? "")"
                
                cell?.imageView.setImage(
                    url: URL.init(string: profilePic) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModel.closedConnectionFriendsData[indexPath.item].gender == 1 ?  "no_profile_image_male" : viewModel.closedConnectionFriendsData[indexPath.item].gender == 2 ? "no_profile_image_female" : "others"))
                
                cell?.nameLbl.text = viewModel.closedConnectionFriendsData[indexPath.item].displayName ?? ""
            }
            
           
            
            return cell ?? UICollectionViewCell()
        } else {
            cell?.imageView.layer.cornerRadius = 10.0
            cell?.clipsToBounds = true
            cell?.connectionSelectImg.image = #imageLiteral(resourceName: "post_save")
            cell?.connectionSelectImg.isHidden = false
            //cell?.isSelected = true
            
            let profilePic = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(selectedFriendsListForLoaded[indexPath.item].profilePic ?? "")"
            
            cell?.imageView.setImage(
                url: URL.init(string: profilePic) ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: selectedFriendsListForLoaded[indexPath.item].gender == 1 ?  "no_profile_image_male" : selectedFriendsListForLoaded[indexPath.item].gender == 2 ? "no_profile_image_female" : "others"))
            cell?.nameLbl.text = selectedFriendsListForLoaded[indexPath.item].displayName ?? ""
            
            return cell ?? UICollectionViewCell()
        }
    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 4 - 10 , height: 100)
    }
    
    
    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose line spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive lines in a section.
    ///  - If you do not implement this method, the flow layout uses the value in its minimumLineSpacing property to set the space between lines instead. Your implementation of this method can return a fixed value or return different spacing values for each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        
        return UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
    }
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        if indexPath.section == 1{
            if indexPath.item == self.viewModel.closedConnectionFriendsData.count  - 1 && !loadingData {
                 self.loadMoreData()
            }
        }
        
    }
    
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            debugPrint(viewModel.closedConnectionFriendsData[indexPath.item])
                        
            //Adding Bool
            let data = viewModel.closedConnectionFriendsData[indexPath.item]
            self.selectedFriendsListForLoaded.append(data)
            
            selectedFriendsList.append(viewModel.closedConnectionFriendsData[indexPath.item].userId ?? "")

            //Remove from second index
            viewModel.closedConnectionFriendsData.remove(at: indexPath.item)
           
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
            
            debugPrint(selectedFriendsList)
            
        }else {
            
            //Adding unchecked item in friends API list
            viewModel.closedConnectionFriendsData.append(selectedFriendsListForLoaded[indexPath.item])
            
            //Removed selected checked item from section 0
            selectedFriendsListForLoaded.remove(at: indexPath.item)
            
            selectedFriendsList.remove(at: indexPath.item)
            
            debugPrint(selectedFriendsList)
            
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//
//        if indexPath.section == 1 {
//            debugPrint(friendsListFromAPI[indexPath.item].userId ?? "")
//
//            selectedFriendsList.remove(at: find(objecToFind: selectedFriendsListForLoaded[indexPath.item].userId ?? "") ?? 0)
//
//            debugPrint(selectedFriendsList)
//        }else{
//            selectedFriendsList.remove(at: find(objecToFind: selectedFriendsListForLoaded[indexPath.item].userId ?? "") ?? 0)
//        }
//    }
    //
    /// Find a friends in the
    /// - Parameter objecToFind: Find a name in the close friends list and select it
    /// - Returns: Return the count as integer vakue.
    func find(objecToFind: String?) -> Int? {
        for i in 0...selectedFriendsList.count {
            if selectedFriendsList[i] == objecToFind {
                return i
            }
        }
        return nil
    }
    
    /// Remove while searching the closed connection friends list
    func findToRemoveObjectWhileSearch(objecToFinds: String?) -> Int? {
        for i in 0...viewModel.closedConnectionFriendsData.count {
            if viewModel.closedConnectionFriendsData[i].userId == objecToFinds ?? "" {
                return i
            }
        }
        return nil
    }
    
}

/**
 This class is used to set the name, image and loader has been shown
 */
//#MARK: Collectionview Cell Class - Tag Cell
class closedConnectionCell: UICollectionViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageView: customImageView!
    @IBOutlet weak var connectionSelectImg: UIImageView!
    @IBOutlet weak var dummyView: UIView!
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView

        ]
    }
    
    
    func showDummy(){
        self.dummyView.isHidden = false
        self.imageView.isHidden = true
    }
    
    func hideDummy(){
        self.dummyView.isHidden = true
        self.imageView.isHidden = false
    }
}

extension ClosedConnectionsViewController : UISearchBarDelegate {
    
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 3 {
            self.viewModel.closedConnectionFriendsData = []
            self.collectionView?.reloadData()
            searchBar.placeholder = ""
            searchtext = searchText
//            self.viewModel.closedConnectionFriendsData = []
//            self.collectionView?.reloadData()
            setUpClosedConnectionListViewModel()

            apiCallForSearchClosedConnectionList(text: searchText, nextPageKey: 1, limit: 40)
        }else if searchText.count == 0{
            searchBar.placeholder = "Search here"
            searchtext = ""
            self.viewModel.closedConnectionFriendsData = []
            self.collectionView?.reloadData()
//            setUpClosedConnectionListViewModel()
//            self.viewModel.closedConnectionFriendsData = []

            apiCallForClosedConnectionList(text: searchText, nextPageKey: 1, limit: 40)
        }
        
    }
    
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)
        let new_String = (searchBar.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        print(newString)
        

        if newString.count >= 30 {
            showErrorAlert(error: "Please enter less than 30 characters.")
            return false
        }
        return true && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}

