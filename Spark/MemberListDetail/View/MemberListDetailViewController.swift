//
//  MemberListDetailViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 22/08/21.
//


import UIKit
import SDWebImage
import AudioToolbox
import UIView_Shimmer
import Toaster

protocol getSelectedMemberList: AnyObject {
    func selectedMember(postId:String,threadId:String,linkUserId:String)
    func dismissAfterMemberRemove(postId:String,threadId:String,linkUserId:String)
}

/// This class is used to show the list of members to remove from the loop
class MemberListDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var doneBtn:UIButton?
    
    @IBOutlet weak var dimmedView:UIView!
    @IBOutlet weak var titleLbl:UILabel!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var noDatView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var delegate : getSelectedMemberList? = nil
    
    let maxDimmedAlpha: CGFloat = 0.6
    
    var threadId = ""
    
    var isFromRemoveMember = false
    var userId = ""
    
    var selectedPostId = ""
    var selectedThreadId = ""
    //paginator
    var loadingData = false
    var nextPageKey = 1
    var previousPageKey = 1
    var isLoading = false
    var textSearch = ""
    var isReportEnabled = false
    var displayName = ""
    var postId = ""
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    // Constants
    let defaultHeight: CGFloat = 0
    let dismissibleHeight: CGFloat = 0
    let maximumContainerHeight: CGFloat = 0//UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 0
    var limit = 40
    
    let viewModel = MemberListDetailViewModel()
    
    @IBOutlet weak var closedConnectionSearchBar: UISearchBar!
    
    @IBOutlet weak var closedConnectionDescLabl: UILabel!
    
    var selectedFriendsList = [String]()
    
    
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
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        
        if isFromRemoveMember {
            titleLbl.text = "Remove user from the loop"
        }
        else if isReportEnabled{
            titleLbl.text = "Report user from the loop"
        }
        
        else{
            titleLbl.text = "Loop members list"
        }
        
    }
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
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
        
        //setupPanGesture()
        
        setUpClosedConnectionListViewModel()
        self.noDatView.isHidden = true
        viewModel.memberListdata = []
        self.isLoading = true
        self.getListValues(text: "", PageNumber: nextPageKey, PageSize: limit)
        //apiCallForMemberList(text: "", nextPageKey: nextPageKey, limit: limit)
        
        doneButtonKeyboard()
        
        self.collectionView?.register(UINib.init(nibName: "NoDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoDataCollectionViewCell")
        
    }
    
    /// Clicking done button to dismiss the keyboard.
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    /// Setup the closed connection list view mdel to show the paginator data with reload the collectionview
    func setUpClosedConnectionListViewModel() {
        
        viewModel.memberListBaseModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.memberListBaseModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            
            if self.viewModel.memberListdata.count > 0{
                
             
                self.collectionView?.isHidden = false
                self.noDatView.isHidden = true
                self.isLoading = false
                
                if self.viewModel.memberListBaseModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.memberListdata.count > 0 { //Loading
                    
                    DispatchQueue.main.async {
                       
                        //self.isLoading = false
                        self.collectionView?.reloadData()
                        self.loadingData = false
                        
                        //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .bottom)
                       
                        

                    }
                }else { //No extra data available
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        //self.loadingData = false
                        self.loadingData = true
                        
                    }
                }
                
            }else{
                self.loadingData = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    
                    self.collectionView?.isHidden = true
                    self.noDatView.isHidden = false
                    
                })
            }
            
//            if let values = value.isOk, values {
//
//                if self.viewModel.memberListBaseModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.memberListBaseModel.value?.data?.membersList?.count ?? 0 > 0 { //Loading
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
//
//                        //self.isLoading = false
//
//                        self.loadingData = false
//
//                    }
//                }else { //No extra data available
//
//
//                    DispatchQueue.main.async {
//
//                        self.loadingData = true
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.collectionView?.reloadData()
//                }
//
//
//
//            }
        }
    }
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData(searchText:String) {
        if !self.loadingData {
            limit = 40
            self.loadingData = true
            self.nextPageKey = self.viewModel.memberListBaseModel.value?.data?.paginator?.nextPage ?? 0
            self.getListValues(text: searchText, PageNumber: self.nextPageKey, PageSize: self.limit)
        }
        else {
            //self.noMoreView.isHidden = true
        }
    }
    
    /// Done button is tapped to dimsiss the page
    @IBAction func doneButtonTapped(sender:UIButton) {
        // delegate?.closedConnectionList(friendsList: selectedFriendsList)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// Api call for to get the memberlist
    func apiCallForMemberList(text:String,nextPageKey:Int, limit:Int ) {
        
        let dict = [
            "threadId" : threadId,
            "text" : text,
            "paginator":["nextPage": nextPageKey,
                         "pageSize": limit,
                         "pageNumber": 1,
                         "totalPages" : 1,
                         "previousPage" : 1]
            
            
        ] as [String : Any]
        
        viewModel.getMemberList(postDict: dict)
        
    }
    
    
    /// List all the values of member from the api
    func getListValues(text:String,PageNumber:Int,PageSize:Int) {
       
        let params = [
            "threadId" : threadId,
            "text" : text,
            "paginator":[
                "nextPage": PageNumber,
                "pageNumber": 1,
                "pageSize": PageSize,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
            
            
        
        viewModel.getMemberList(postDict: params)
    }
    
    
    /// List all the values of member from the api
    func getListValuesSearch(text:String,PageNumber:Int,PageSize:Int) {
       
        let params = [
            "threadId" : threadId,
            "text" : text,
            "paginator":[
                "nextPage": PageNumber,
                "pageNumber": 1,
                "pageSize": PageSize,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
            
            
        
        viewModel.getMemberListRemoveDuplicates(postDict: params)
    }
    
    
    /// Handle close section to dismiss the view with animation
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    /// Setup the pan gesture here to close the bottom sheet.
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    /// Handle the bottom sheet to close the gesture by dragging down
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
            
           // self.delegate?.dismissAfterMemberRemove(postId: self.selectedPostId, threadId: self.selectedThreadId, linkUserId: "")
            
        default:
            break
        }
    }
    
    /// Animate the container height
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
    
    /// Animate the presenter container height
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    /// Show the view dimmed with alpha
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    /// Animate and dismiss the view
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
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    
    /// It is used to dismiss the page
    @IBAction func closeBtnOnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}

extension MemberListDetailViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - collectionView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isLoading{
            return 20
        }
        else{
            return viewModel.memberListdata.count
        }
          
        //}
        
       // return viewModel.memberListdata.count == 0 ? 1 : viewModel.memberListdata.count //viewModel.memberListBaseModel.value?.data?.membersList?.count ?? 0 == 0 ? 1 : viewModel.memberListBaseModel.value?.data?.membersList?.count ?? 0
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath as IndexPath) as? memberCell
        
        if isLoading{
            cell?.showDummy()
        }
        else{
            cell?.hidedummy()
            let myView = View(frame: CGRect(x: 0, y: 0, width: cell?.bgView.frame.width ?? 0.0, height: 64), cornerRadius: 6, colors: [UIColor.init(hexString: "ee657a"),UIColor.init(hexString: "33beb8"),UIColor.init(hexString: "b2c225"),UIColor.init(hexString: "fecc2f"),UIColor.init(hexString: "db3838"),UIColor.init(hexString: "a363d9")], lineWidth: 2, direction: .horizontal)
            
            cell?.bgView.addSubview(myView)
            
            cell?.userProfileImgView.backgroundColor = .clear
            cell?.userProfileImgView.layer.cornerRadius = 6
            cell?.userProfileImgView.layer.borderWidth = 1
            cell?.userProfileImgView.clipsToBounds = true
            cell?.userProfileImgView.layer.borderColor = UIColor.clear.cgColor
            
            let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(viewModel.memberListdata[indexPath.item].profilePic ?? "")"
            
            if viewModel.memberListdata[indexPath.item].allowAnonymous ?? false {
                cell?.userProfileImgView.image = #imageLiteral(resourceName: "ananomous_user")
                cell?.bubbleNameLbl.text = "Anonymous User"
            }else{
                cell?.userProfileImgView.setImage(
                    url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModel.memberListdata[indexPath.item].gender == 1 ?  "no_profile_image_male" : viewModel.memberListdata[indexPath.item].gender == 2 ? "no_profile_image_female" : "others"))
                cell?.bubbleNameLbl.text = viewModel.memberListdata[indexPath.item].displayName ?? ""
            }
            
            cell?.grayView.isHidden = viewModel.memberListdata[indexPath.item].isClap == false ? false : true
            cell?.grayView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }
        
       
        
        return cell ?? UICollectionViewCell()
    }
    
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel.memberListdata.count > 0 {
            if isFromRemoveMember {
                
                receiveBaseUserCloseThread()
                receiveMemberCloseThread()
                
                if viewModel.memberListdata[indexPath.item].isClap ?? false {
                    memberRemoveConfirmationAlert(threadId: viewModel.memberListdata[indexPath.item].threadId ?? "", postId: viewModel.memberListdata[indexPath.item].postId ?? "", userId: viewModel.memberListdata[indexPath.item].bubbleUserId ?? "")
                }else{
                    self.showErrorAlert(error: "You can't remove this member.since it is not belong to this Loop")
                }
                
            }
            else if isReportEnabled{
                self.memberReportConfirmationAlert(threadId: viewModel.memberListdata[indexPath.item].threadId ?? "", postId: viewModel.memberListdata[indexPath.item].postId ?? "", userId:  viewModel.memberListdata[indexPath.item].bubbleUserId ?? "", displayName: viewModel.memberListdata[indexPath.item].displayName ?? "")
            }
            else{
                selectedPostId = viewModel.memberListdata[indexPath.item].postId ?? ""
                selectedThreadId = viewModel.memberListdata[indexPath.item].threadId ?? ""
                
                dismiss(animated: true) {
                    self.delegate?.selectedMember(postId: self.selectedPostId, threadId: self.selectedThreadId, linkUserId: self.viewModel.memberListdata[indexPath.item].bubbleUserId ?? "")
                }
            }
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
        //return CGSize(width: viewModel.memberListdata.count == 0 ? collectionView.frame.size.width - 50 : collectionView.frame.size.width / 4 - 16 , height: viewModel.memberListdata.count == 0 ? collectionView.frame.size.height : 100)
        
        if isLoading{
            return CGSize(width: collectionView.frame.size.width / 4 - 16, height: 100)
        }
        else{
            return CGSize(width: collectionView.frame.size.width / 4 - 16, height: 100)
        }
        
    }
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       // let lastItem = viewModel.memberListBaseModel.value?.data?.membersList?.count ?? 0 - 3
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        print((viewModel.memberListdata.count) - 1)
        if indexPath.item == (viewModel.memberListdata.count) - 1 && !loadingData {
            self.loadMoreData(searchText: textSearch)
        }
    }
    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose line spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive lines in a section.
    ///  - If you do not implement this method, the flow layout uses the value in its minimumLineSpacing property to set the space between lines instead. Your implementation of this method can return a fixed value or return different spacing values for each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    
    
    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 12)
    }
    
    

    
    /// Remove the member list alert details and dimiss after the member removed
    func memberRemoveConfirmationAlert(threadId:String,postId:String,userId:String) {
        let alert = UIAlertController(title: "", message: "Do you want to remove the selected member from this loop?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
            alert.addAction(UIAlertAction(title: "Yes",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            
                SocketIOManager.sharedSocketInstance.closeThreadEmit(param: ["postId":postId,"threadId":threadId,"userId":userId,"status":2])
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate?.dismissAfterMemberRemove(postId: self.selectedPostId, threadId: self.selectedThreadId, linkUserId: "")
                    }
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    ///Confirm for report alert and show the user top be reported
    func memberReportConfirmationAlert(threadId:String,postId:String,userId:String,displayName:String) {
        let alert = UIAlertController(title: "", message: "Do you want to report the selected member from this loop?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
            alert.addAction(UIAlertAction(title: "Report",
                                          style: .default,
                                          handler: {(_: UIAlertAction!) in
                                            
                let param = ["postId":postId, "threadId":threadId,"userId":userId,"displayName":displayName] as [String : Any]
                self.viewModel.reportThreadUser(postDict:param)
                Toast(text: "User reported successfully").show()
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                       // self.delegate?.dismissAfterMemberRemove(postId: self.selectedPostId, threadId: self.selectedThreadId, linkUserId: "")
                    }
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    
    ///Socket will be called for the base close thread when someone left
    func receiveBaseUserCloseThread() {
        
        SocketIOManager.sharedSocketInstance.newsocket.on("basecloseThread") { data, ack in
            print("Base User Close Thread",data[0])
            self.showErrorAlert(error: "Someone left from this loop")
            print("Calling member close thread")
           // self.apiCallForMemberList(text: "", nextPageKey: 1, limit: 10)
        }
    }
    
    
    
    ///Socket will be called for the member closeThread when someone left
    func receiveMemberCloseThread() {
        
        SocketIOManager.sharedSocketInstance.newsocket.on("membercloseThread") { data, ack in
                print("Member Close Thread",data[0])
            self.showErrorAlert(error: "Someone left from this loop")
            print("Calling member close thread")
            //self.apiCallForMemberList(text: "", nextPageKey: 1, limit: 10)
        }
    }
}


/**
 This cell is used to set the collectionview in the member cell
 */
//#MARK: Collectionview Cell Class - Tag Cell
class memberCell: UICollectionViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var userProfileImgView: customImageView!
    @IBOutlet weak var bubbleNameLbl: UILabel!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var DummyView: UIView!
    
    var shimmeringAnimatedItems: [UIView] {
        [
            DummyView
            
            
        ]
    }
    
    func showDummy(){
        self.DummyView.isHidden = false
        self.bgView.isHidden = true
        self.grayView.isHidden = true
    }
    
    
    func hidedummy(){
        self.DummyView.isHidden = true
        self.bgView.isHidden = false
        self.grayView.isHidden = false
    }
}

extension MemberListDetailViewController : UISearchBarDelegate {
    
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.memberListdata = []
        if searchText.count > 2 {
            searchBar.placeholder = ""
            nextPageKey = 1
            textSearch = searchText
            
           // self.isLoading = true
            self.collectionView?.reloadData()
            //self.viewModel.memberListdata.removingDuplicates(withSame: \.)
            //DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.getListValuesSearch(text: searchText, PageNumber: self.nextPageKey, PageSize: self.limit)
            //viewModel.memberListdata = []
            //}
           
            //apiCallForMemberList(text: searchText, nextPageKey: 1, limit: 10)
        }else if searchText.count == 0 {
            searchBar.placeholder = "Search here"
            nextPageKey = 1
            textSearch = ""
            viewModel.memberListdata = []
            //self.isLoading = true
            self.collectionView?.reloadData()
            self.getListValues(text: searchText, PageNumber: nextPageKey, PageSize: limit)
            //apiCallForMemberList(text: searchText, nextPageKey: 1, limit: 10)
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
        
        if newString.count >= 30 {
            showErrorAlert(error: "Please enter less than 30 characters.")
            return false
        }
        return true
    }
}



extension Sequence {
    func removingDuplicates<T: Hashable>(withSame keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            guard seen.insert(element[keyPath: keyPath]).inserted else { return false }
            return true
        }
    }
}
