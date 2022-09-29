//
//  OverlayView.swift
//  SlideOverTutorial
//
//  Created by Aivars Meijers on 09/09/2020.
//

import UIKit
import Lottie
import ListPlaceholder
import UIView_Shimmer

class OverlayView: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var nextPageKey = 1
    var previousPageKey = 1
    var limit = 10
    //paginator
    var loadingData = false
    //var loadingPreviousData = false
    var isAPICalled = false
    var isFromLoopConversation = false
    var isFromHome = false
    
    @IBOutlet weak var slideIdicator: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var isLoading = true {
            didSet {
                tableView.isUserInteractionEnabled = !isLoading
                tableView.reloadData()
            }
        }
    
    let viewModel = ViewUserViewModel()
    var userId = ""
    var type = 0
    var delegate : backFromOverlay?
    var index_Path : Int?
    var backdelegate : backfromFeedDelegate?
    var membersList : [MembersList]?
    
    var myPostId = ""
    var myThreadId = ""
    var myUserId = ""
    var isFromNotification = false
    var isThread = 0
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UserGroupTableViewCell.self)
        
        setUpUserViewModel()
        isLoading = true
        userListApiCall()
        
        tableView.tableFooterView = UIView()
        let tableViewLoadingCellNib = UINib(nibName: "LoaderTableViewCell", bundle: nil)
        self.tableView.register(tableViewLoadingCellNib, forCellReuseIdentifier: "LoaderTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               //self.isLoading = false
           }
       }
    
    
     func removeLoader()
    {
        self.tableView.hideLoader()
    }
    func userListApiCall() {
        
       let paramDict = [
            "text": "",
            "paginator": [
                "pageNumber": nextPageKey,
                "nextPage": 1,
                "totalPages": 1,
                "pageSize": limit,
                "previousPage": previousPageKey
            ],
            "postId": userId
       ] as [String : Any]
        
        viewModel.viewUserViewAPICall(postDict: paramDict, type: type)

    }
    
    func getListValues(PageNumber:Int,PageSize:Int) {
        
        let params = [
            "text": "",
            "paginator":[
                "nextPage": nextPageKey,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ],
            "postId": userId
        ] as [String : Any]
        viewModel.viewUserViewAPICall(postDict: params, type: type)
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData {
            limit = 10
            self.loadingData = true
            self.nextPageKey = self.viewModel.userViewModel.value?.data?.paginator?.nextPage ?? 0
            self.getListValues(PageNumber: nextPageKey, PageSize: limit)
        }
        else {
            //self.noMoreView.isHidden = true
        }
    }
    
    func setUpUserViewModel() {
        
        viewModel.userViewModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.userViewModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            debugPrint(self.viewModel.userListData)
            if self.viewModel.userListData.count > 0 {
                
                if self.viewModel.userViewModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.userListData.count > 0 { //Loading
                   
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                       
                        self.isLoading = false
                        
                        self.loadingData = false
                       
                    }
                }else { //No extra data available
                    
                    
                    DispatchQueue.main.async {
                        
                        self.loadingData = true
                    }
                }
                
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    //self.loadingData = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isLoading = false
                    }
                    //                    self.removeLoader()
                }
            }
            else{
                self.tableView.reloadData()
                self.loadingData = true
            }
        }
        
    }
    
    
    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.

    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true) { [self] in
                    //self.backdelegate?.back(postId: myPostId, threadId: myThreadId, userId: myUserId,  memberList: self.membersList ?? [MembersList](), messageListApproved:false, isFromLoopConversation: self.isFromLoopConversation)
                }
                //self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}

// tableview delegate and datsource

extension OverlayView : UITableViewDelegate, UITableViewDataSource {
    
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if isLoading{
                return 10
            }
            else{
                return viewModel.userListData.count
            }
        }
        else if section == 1 {
            //Return the Loading cell
                return 0

        } else {
            //Return nothing
            return 0
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserGroupTableViewCell.identifier, for: indexPath) as? UserGroupTableViewCell
            else { preconditionFailure("Failed to load collection view cell") }
            
            if isLoading{
                cell.showDummy()
            }
            else{
                cell.hideDummy()
                cell.viewModelCell = viewModel.userListData(indexpath: indexPath)
                

                if type == 1 {

                    cell.typeImg.image = UIImage(named: "notificationView")
                } else {
                    cell.typeImg.image = UIImage(named: "notificationClap")
                }
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoaderTableViewCell", for: indexPath) as! LoaderTableViewCell
            if type == 1 {
                cell.loadingViewsLbl.text = "Loading views"
            }
            else{
                cell.loadingViewsLbl.text = "Loading claps"
            }
            cell.activityIndicator.startAnimating()
            return cell
        }
       
    }
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let userId = self.viewModel.userListData[indexPath.row].userid ?? ""
            self.delegate?.dismissOverlay(userId: userId, IndexPath:self.index_Path ?? 0)
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
            return  UITableView.automaticDimension
        }
        else{
            return 50
        }
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
    
    
    /// Asks the delegate for the height to use for the header of a particular section.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: An index number identifying a section of tableView .
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) of the header for section.
    /// - Use this method to specify the height of custom header views returned by your tableView(_:viewForHeaderInSection:) method.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let headerView = UIView()
            var headerLabel = UILabel()
            headerView.backgroundColor = UIColor.init(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
            
                headerLabel = UILabel(frame: CGRect(x: 20, y: 13, width:
                100, height: 25))
            headerLabel.text = type == 1 ? "People who eyeshot this post" : "People who clapped this post"
            
            headerLabel.font = UIFont.MontserratMedium(.large)
            headerLabel.textColor = UIColor.black
            headerLabel.sizeToFit()
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        else{
            return nil
        }
      
    }

    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        let lastItem = viewModel.userListData.count - 1
        
        if lastItem == indexPath.row{
            self.loadMoreData()
        }
        
//        if
        
       
    }
    
    /// Asks the delegate for a view to display in the header of the specified section of the table view.
    /// - Parameters:
    ///   - tableView: The table view asking for the view.
    ///   - section: The index number of the section containing the header view.
    /// - Returns: A UILabel, UIImageView, or custom view to display at the top of the specified section.
    /// - If you implement this method but don’t implement tableView(_:heightForHeaderInSection:), the table view calculates the height automatically, or uses the value of sectionHeaderHeight if set.
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44  // or whatever
    }
}


extension OverlayView {
    
    
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == tableView {
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                //loadMoreData()
            }
        }
    }
    
    
    
    
}
