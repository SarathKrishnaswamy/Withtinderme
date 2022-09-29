//
//  BubbleViewController.swift
//  Spark me
//
//  Created by adhash on 17/08/21.
//

import UIKit
import VariousViewsEffects
import LRSpotlight
import UIView_Shimmer
import ListPlaceholder


/**
 This class is used to show the recent loops and bubble page to accept the user or without accept the user
 */
class BubbleViewController: UIViewController, TagListViewDelegate {
    
    
    
    
    var identifier = "BubbleCollectionViewCell"
    
    @IBOutlet weak var bubbleCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profilePicImgView: UIImageView?
    @IBOutlet weak var profilePicBtn: UIButton?
    //    @IBOutlet weak var bubbleSegment: UISegmentedControl!
    @IBOutlet weak var tagSelectionBtn: UIButton!
    @IBOutlet weak var conversationTagSelectionBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var loadingData = true
    
    var selectedTagId = ""
    
    let viewModel = BubbleViewModel()
    
    @IBOutlet weak var recentConversationBtn: UIButton?
    @IBOutlet weak var bubbleBtn: UIButton?
    
    var selectedButton: UIButton? = nil
    let columnLayout = TagsLayout()
    var nodess = [SpotlightNode]()
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataDesc: UILabel!
    @IBOutlet weak var nftImage: UIImageView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var searchBgView: UIView!
    
    
    var isLoading = false
    
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearBtn.isHidden = false
        tagListView.delegate = self
        tagListView.isHidden = true
        
        if let collectionViewLayout = bubbleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
                        
        bubbleCollectionView.delegate = self
        bubbleCollectionView.dataSource = self
       
        self.searchBar.delegate = self
        self.searchBar.searchTextField.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.font = UIFont.MontserratRegular(.normal)
        searchBar.searchTextField.clearButtonMode = .whileEditing
        
        
        bubbleCollectionView.register(UINib.init(nibName: "RecentConversationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecentConversationCollectionViewCell")
        bubbleCollectionView.register(UINib.init(nibName: "ActivityIndicatorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ActivityIndicatorCollectionViewCell")
        self.bubbleCollectionView.register(UINib.init(nibName: "NoDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoDataCollectionViewCell")
        
        
        setUpRecentConversationViewModel()
        
        tagSelectionBtn.isHidden = true
        conversationTagSelectionBtn.isHidden = false
        self.searchBgView.layer.cornerRadius = 6.0
        self.searchBgView.layer.borderWidth = 0.5
        self.searchBgView.layer.borderColor = UIColor.lightGray.cgColor
        
        doneButtonKeyboard()
    }
//        startSpotlight()
       //{
//        if SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot == false{
//            self.nodess = [
//                SpotlightNode(text: "View your recent loop members here", target: .view(recentConversationBtn ?? UIButton()), roundedCorners: true, imageName: ""),
//                SpotlightNode(text: "View your recent bubble request's here", target: .view(bubbleBtn ?? UIButton()), roundedCorners: true, imageName: "")]
//            Spotlight().startIntro(from: self, withNodes: nodess)
//            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = true
//
//        }
//    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    /// - Parameter animated: If true, the view was added to the window using an animation.
    /// You can override this method to perform additional tasks associated with presenting the view. If you override this method, you must call super at some point in your implementation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    
    
    /// Api call for show the bubble list with call the api view model
    func apiCall(text:String,tagId:String) {
        let bubbleDict = [
            "text":text,
            "tagId" :tagId,
            "paginator":[
                "nextPage": nextPageKey,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
            
        ] as [String : Any]
        viewModel.bubbleListApiCall(postDict: bubbleDict)
    }
    
    
    ///api call for search in bubble list
    func apiCallSearch(text:String,tagId:String) {
        let bubbleDict = [
            "text":text,
            "tagId" :tagId,
            "paginator":[
                "nextPage": nextPageKey,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
            
        ] as [String : Any]
        viewModel.bubbleListApiCallNoLoadingSearch(postDict: bubbleDict)
    }
    
    /// Observe the view model to set the tableview to reload and set the paginator to load the data
    func setUpBubbleViewModel() {
        viewModel.bubbleModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.bubbleModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            self.noDataView.isHidden = true
            self.bubbleCollectionView.isHidden = false
            if value.isOk ?? false, value.data?.bubbleList?.count ?? 0 > 0 {
                
                self.noDataView.isHidden = true
                self.bubbleCollectionView.isHidden = false
                
                
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    self.loadingData = false
                }else{
                    self.loadingData = true
                }
                self.descLbl.isHidden = false
                DispatchQueue.main.async {
                    self.bubbleCollectionView.reloadData()
                }
                
            } else {
                
                self.noDataDesc.text = "There are no Claps from both ends! \nPlease Clap appropriate Spark and start the Loop"
                self.noDataImg.image = #imageLiteral(resourceName: "no_bubble")
                
                self.noDataView.isHidden = false
                self.bubbleCollectionView.isHidden = true
                self.descLbl.isHidden = true
                DispatchQueue.main.async {
                    self.bubbleCollectionView.reloadData()
                }
                
            }
        }
    }
    
    /// recent conversation list api observer to set in the collectionview to reload the data and set the paginator
    func setUpRecentConversationViewModel() {
        viewModel.recentConversationModel.observeError = { [weak self] error in
            guard let self = self else { return }
            self.bubbleBtn?.isEnabled = true
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.recentConversationModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            self.noDataView.isHidden = true
            self.bubbleCollectionView.isHidden = false
            //self.viewModel.recentConversationList = []
            
            if value.isOk ?? false, value.data?.conversationList?.count ?? 0 > 0 {
                
                self.noDataView.isHidden = true
                self.bubbleCollectionView.isHidden = false
                
                if value.data?.paginator?.nextPage ?? 0 > 0 {
                    self.loadingData = false
                }else{
                    self.loadingData = true
                }
                self.descLbl.isHidden = false
                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isLoading = false
                        self.bubbleBtn?.isEnabled = true
                        self.bubbleCollectionView.reloadData()
                        self.isLoading = false
                        
                    }
                   
                }
              
            } else {
                if SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot == false{ //&& SessionManager.sharedInstance.isProfileUpdatedOrNot == false{
                    self.nodess = [
                        SpotlightNode(text: "View your recent loop members here", target: .view(self.recentConversationBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                        SpotlightNode(text: "View your recent bubble request's here", target: .view(self.bubbleBtn ?? UIButton()), roundedCorners: true, imageName: "")]
//                    if viewModel.recentConversationList.count > 0 {
//                        self.nodess.append(SpotlightNode(text: "Comment here with your loop members", target: .view(cell.viewMoreBgView), roundedCorners: true, imageName: ""))
//
//                    }
                    Spotlight().startIntro(from: self, withNodes: self.nodess)
                    SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = true
                }
                
                self.loadingData = true
                if self.viewModel.recentConversationList.count <= 0 {
                    self.noDataDesc.text = "There are no recent Loops! \nPlease Clap appropriate Spark and start the Loop"
                    self.noDataImg.image = #imageLiteral(resourceName: "no_recent_conversation")
                    
                    self.noDataView.isHidden = false
                    self.bubbleCollectionView.isHidden = true
                    
                    self.descLbl.isHidden = true
                    self.bubbleBtn?.isEnabled = true
                    DispatchQueue.main.async {
                        self.bubbleCollectionView.reloadData()
                    }
                }
            }
            
            
        }
    }
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isLoading = true
        self.bubbleBtn?.isEnabled = false
        //bubbleCollectionView.reloadData()
        
    
       // SocketIOManager.sharedSocketInstance.ConnectsToSocket()
        
        SessionManager.sharedInstance.isUserPostId = ""
        
        nextPageKey = 1 //To reset previous selection
        
        tagSelectionBtn.isHidden = true
        conversationTagSelectionBtn.isHidden = false
        self.clearBtn.isHidden = true
        self.tagListView.isHidden = true
        self.searchBar.placeholder = "Search here"
        
        viewModel.bubbleListData = []
        viewModel.recentConversationList = []
        
        DispatchQueue.main.async {
            self.bubbleCollectionView.reloadData()
        }
        //apiCall(text: "", tagId: "")
        
        searchBar.text = ""
        selectedTagId = ""
        recentConversationAPICall(text: "", isSearch: false, isLoadMore: false)
        
        descLbl.text = "Here you can start conversations in your joined loops"
        
        recentConversationBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        bubbleBtn?.titleLabel?.font = UIFont.MontserratSemiBold(.small)
        
        recentConversationBtn?.setTitleColor(UIColor.white, for: .normal)
        bubbleBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        
        updateButtonSelection(recentConversationBtn ?? UIButton())
        
        if #available(iOS 10.0, *) {
            columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        } else {
            columnLayout.estimatedItemSize = CGSize(width: 41, height: 41)
        }
        bubbleCollectionView.collectionViewLayout = columnLayout
        
        conversationTagSelectionBtn.setTitle("All", for: .normal)
        
        let profilePicUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] ?? "")"
        
        self.profilePicImgView?.setImageFromUrl(urlString: profilePicUrl, imageView: profilePicImgView ?? UIImageView(), placeHolderImage: SessionManager.sharedInstance.saveGender == 1 ?  "no_profile_image_male" : SessionManager.sharedInstance.saveGender == 2 ? "no_profile_image_female" : "others")
        profilePicImgView?.clipsToBounds = true
        profilePicImgView?.contentMode = .scaleAspectFill
        profilePicImgView?.cornerRadius = 6.0
        
        self.profilePicBtn?.setTitle("", for: .normal)
         
        
        let nft = SessionManager.sharedInstance.saveUserDetails["nft"] as? Int ?? 0
        if nft == 1{
            self.nftImage.isHidden = false
        }
        else{
            self.nftImage.isHidden = true
        }
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(removeLoader), userInfo: nil, repeats: false)
    }
    

    /// Remove the loader from collection
    @objc func removeLoader()
    {
        self.bubbleCollectionView.hideLoader()
    }
//    func startSpotlight()
    
    
    /// Tag pressed to remove the tags from tagview and sender list
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    /// Tag removed button is used to remove all the tags and remove user interaction
    ///  Set the Array list empty and searchbar to empty
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        tagListView.isHidden = true
        
        searchBar?.placeholder = "Search here"
        viewModel.bubbleListData = []
        apiCall(text: "", tagId: "")
        
    }
    
    
    ///back button tapped
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    /// Call the recent conversation text with pagination
    /// - Parameters:
    ///   - text: The string of text need to pass and search in the api call
    ///   - isSearch: isSearch is used as boolean value to set tableview
    ///   - isLoadMore: isLoad more is used to loadmore datas
    fileprivate func recentConversationAPICall(text:String,isSearch:Bool,isLoadMore:Bool) {
        let paramDict = [
            "text": text,
            "paginator": [
                "pageNumber": 1,
                "nextPage": nextPageKey,
                "previousPage": 1,
                "totalPages": 1,
                "pageSize": 10
            ],
            "tagId": selectedTagId
        ] as [String : Any]
        viewModel.recentConversationListApiCall(postDict: paramDict, isSearch: isSearch, isLoadMore: isLoadMore)
    }
    
    /// It is used to open tags to search using bubble tag list page.
    @IBAction func moveToTagSearchButtonTapped(sender:UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
        let tagSearchVC = storyBoard.instantiateViewController(identifier: "BubbleTagListViewController") as! BubbleTagListViewController
        tagSearchVC.view.backgroundColor = .black.withAlphaComponent(0.5)
        tagSearchVC.modalPresentationStyle = .overCurrentContext
        tagSearchVC.delegate = self
        self.present(tagSearchVC, animated: true, completion: nil)
    }
    
    /// Clear button is used clear all the tag which used for search
    @IBAction func clearBtnOnPressed(_ sender: Any) {
        
        if selectedButton?.tag == 1 {
            viewModel.bubbleListData = []
            searchBar.text = ""
            selectedTagId = ""
            conversationTagSelectionBtn.setTitle("All", for: .normal)
            self.apiCall(text: "", tagId: "")
            self.clearBtn.isHidden = true
        }
        else{
            viewModel.recentConversationList = []
            searchBar.text = ""
            selectedTagId = ""
            conversationTagSelectionBtn.setTitle("All", for: .normal)
            recentConversationAPICall(text: "", isSearch: false, isLoadMore: false)
            self.clearBtn.isHidden = true
        }
        
    }
    
    
    /// Profile button tapped to open the profile page.
    @IBAction func profileBtnTapped(sender:UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
}

extension BubbleViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isLoading == true{
            return 10
            
        }
        else{
            if selectedButton?.tag == 1{
                
                
                return viewModel.bubbleListData.count
                
                
            }
            else{
                return  viewModel.recentConversationList.count
            }
        }
        
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch selectedButton?.tag {
            
        case 1:
            
            //            if viewModel.bubbleListData.count == 0 {
            //                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoDataCollectionViewCell", for: indexPath as IndexPath) as? NoDataCollectionViewCell else {
            //
            //                    preconditionFailure("Failed to load collection view cell")
            //                }
            //
            //                cell.noDataLbl.text = "There are no Claps from both ends! \nPlease Clap appropriate Spark and start the Loop"
            //                cell.imgView.image = #imageLiteral(resourceName: "no_bubble")
            //
            //                return cell
            //            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as? BubbleCollectionViewCell else {
                
                preconditionFailure("Failed to load collection view cell")
            }
            cell.delegate = self
            cell.userProfileImgView.tag = indexPath.row
            cell.viewModelCell = viewModel.bubblenData(indexpath: indexPath)
            
            return cell
        case 0:
            
            //            if viewModel.recentConversationList.count == 0 {
            //                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoDataCollectionViewCell", for: indexPath as IndexPath) as? NoDataCollectionViewCell else {
            //                    preconditionFailure("Failed to load collection view cell")
            //                }
            //
            //                cell.noDataLbl.text = "There is no recent conversations! \nPlease clap appropriate post and start the threads..."
            //                cell.imgView.image = #imageLiteral(resourceName: "no_recent_conversation")
            //
            //                return cell
            //
            //            }
            
            if indexPath.row != viewModel.recentConversationList.count{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentConversationCollectionViewCell", for: indexPath as IndexPath) as? RecentConversationCollectionViewCell else {
                    
                    preconditionFailure("Failed to load collection view cell")
                }
               
                if isLoading == true{
                    cell.showDummy()
                }
                else{
                    cell.hideDummy()
                    if viewModel.recentConversationList.count > 0{
                        if SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot == false{ //&& SessionManager.sharedInstance.isProfileUpdatedOrNot == false{
                            self.nodess = [
                                SpotlightNode(text: "View your recent loop members here", target: .view(self.recentConversationBtn ?? UIButton()), roundedCorners: true, imageName: ""),
                                SpotlightNode(text: "View your recent bubble request's here", target: .view(self.bubbleBtn ?? UIButton()), roundedCorners: true, imageName: "")]
                            if self.viewModel.recentConversationList.count > 0 {
                                self.nodess.append(SpotlightNode(text: "Comment here with your loop members", target: .view(cell.viewMoreBgView), roundedCorners: true, imageName: ""))

                            }
                            Spotlight().startIntro(from: self, withNodes: self.nodess)
                            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = true
                        }
                    }
                 
                    cell.delegate = self
                    cell.conversationPostThumb.tag = indexPath.row
                    cell.viewModelCell = viewModel.recentConversationData(indexpath: indexPath)
                }
                
                return cell
            }
            else{
                if isLoading == true{
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentConversationCollectionViewCell", for: indexPath as IndexPath) as? RecentConversationCollectionViewCell else {
                        
                        preconditionFailure("Failed to load collection view cell")
                    }
                    cell.showDummy()
                    return cell
                   
                }
                else{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityIndicatorCollectionViewCell", for: indexPath) as! ActivityIndicatorCollectionViewCell
                    cell.activityIndicator.startAnimating()
                    return cell
                }
               
            }
           
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath) as? BubbleCollectionViewCell else {
                
                preconditionFailure("Failed to load collection view cell")
            }
            
            return cell
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
        if selectedButton?.tag == 1 {
            return CGSize(width: viewModel.bubbleListData.count == 0 ? collectionView.frame.size.width - 50 : collectionView.frame.size.width / 4 - 16 , height: viewModel.bubbleListData.count == 0 ? collectionView.frame.size.height : 100)
        }
        else {
            if indexPath.row != viewModel.recentConversationList.count{
            return CGSize(width: viewModel.recentConversationList.count == 0 ? collectionView.frame.size.width - 50 : collectionView.frame.size.width , height: viewModel.recentConversationList.count == 0 ? collectionView.frame.size.height : 100)
            }
            else{
                return CGSize(width:collectionView.frame.size.width , height: 40)
            }
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
        if selectedButton?.tag == 1 {
            return 12.0
        } else {
            return 0.0
        }
    }
    
    
    
    
    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if selectedButton?.tag == 1 {
            return 3.0
        } else {
            return 0.0
        }
    }
    
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if selectedButton?.tag == 1 {
            return UIEdgeInsets(top: 0,left: 12,bottom: 0,right: 12)
        }else {
            return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        }
    }
    
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedButton?.tag == 1 && viewModel.bubbleListData.count > 0 {
//
//            let start = Date(timeIntervalSince1970: TimeInterval(Int(viewModel.bubbleListData[indexPath.item].visibleDate ?? 0)))
//            let end = Date()
//            let calendar = Calendar.current
//            let unitFlags = Set<Calendar.Component>([ .second])
//            let datecomponents = calendar.dateComponents(unitFlags, from: start, to: end)
//            let seconds = datecomponents.second
//            print(String(describing: seconds))
//
//            let bubbleDestroyValue = SessionManager.sharedInstance.settingData?.data?.BubbleDestroyTime ?? 0
//
//            if seconds ?? 0 > bubbleDestroyValue {
//
//                DispatchQueue.main.async {
//                    self.bubbleCollectionView.reloadData()
//                }
//            }else{
                let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
                let feedDetailVC = storyBoard.instantiateViewController(identifier: "FeedDetailsViewController") as! FeedDetailsViewController
                feedDetailVC.postId = viewModel.bubbleListData[indexPath.item].linkpostId ?? ""
                feedDetailVC.selectedMemberPostId = viewModel.bubbleListData[indexPath.item].linkpostId ?? ""
                feedDetailVC.selectedMemberAnonymous = viewModel.bubbleListData[indexPath.item].allowAnonymous ?? false
                feedDetailVC.threadId = viewModel.bubbleListData[indexPath.item].threadId ?? ""
                
                feedDetailVC.myPostId = viewModel.bubbleListData[indexPath.item].linkpostId ?? ""
                feedDetailVC.myUserId = viewModel.bubbleListData[indexPath.item].linkuserId ?? ""
                feedDetailVC.myThreadId = viewModel.bubbleListData[indexPath.item].threadId ?? ""
                
                
                feedDetailVC.isFromBubble = true
                feedDetailVC.isCallBubbleAPI = true
                feedDetailVC.senderUserName = viewModel.bubbleListData[indexPath.item].displayName ?? ""
                feedDetailVC.userId = viewModel.bubbleListData[indexPath.item].linkuserId ?? ""
                SessionManager.sharedInstance.threadId = viewModel.bubbleListData[indexPath.item].threadId ?? ""
                self.navigationController?.pushViewController(feedDetailVC, animated: true)
//            }
            
            
            
        } else if selectedButton?.tag == 0 && viewModel.recentConversationList.count > 0 {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let feedDetailVC = storyBoard.instantiateViewController(identifier: "FeedDetailsViewController") as! FeedDetailsViewController
            feedDetailVC.postId = viewModel.recentConversationList[indexPath.item].linkpostId ?? ""
            feedDetailVC.selectedMemberPostId = viewModel.recentConversationList[indexPath.item].linkpostId ?? ""
            feedDetailVC.selectedMemberAnonymous = viewModel.recentConversationList[indexPath.item].allowAnonymous ?? false
            feedDetailVC.threadId = viewModel.recentConversationList[indexPath.item].threadId ?? ""
            
            feedDetailVC.myPostId = viewModel.recentConversationList[indexPath.item].linkpostId ?? ""
            feedDetailVC.myUserId = viewModel.recentConversationList[indexPath.item].linkuserId ?? ""
            feedDetailVC.myThreadId = viewModel.recentConversationList[indexPath.item].threadId ?? ""
            feedDetailVC.mySelectedMemberPostId = viewModel.recentConversationList[indexPath.item].linkpostId ?? ""
            feedDetailVC.mySelectedMemberAnonymous = viewModel.recentConversationList[indexPath.item].allowAnonymous ?? false
            
            feedDetailVC.isFromBubble = false
            feedDetailVC.isCallBubbleAPI = false
            //feedDetailVC.senderUserName = viewModel.recentConversationList[indexPath.item].displayName ?? ""
            SessionManager.sharedInstance.userIdFromSelectedBubbleList = viewModel.recentConversationList[indexPath.item].linkuserId ?? ""
            SessionManager.sharedInstance.threadId = viewModel.recentConversationList[indexPath.item].threadId ?? ""
            self.navigationController?.pushViewController(feedDetailVC, animated: true)
        }
    }
    
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      
        
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        let lastElement = selectedButton?.tag == 1 ? viewModel.bubbleListData.count - 1 : viewModel.recentConversationList.count - 1
        
        if indexPath.item == lastElement {
          loadMoreData()
        }
      }
}

extension BubbleViewController : bubbleListUpdateDelegate {
    /// It is used to update the api call with empty the array list
    /// - Parameter senderTag: Send the integer value with api call
    func bubbleListUpdatedFunction(senderTag: Int) {
        
        //self.viewModel.bubbleListData.remove(at: senderTag)
        viewModel.bubbleListData = []
        apiCall(text: "", tagId: "")
        
        DispatchQueue.main.async {
            self.bubbleCollectionView.reloadData()

        }
    }
}

extension BubbleViewController : conversationListUpdateDelegate {
    func conversationListFunction(senderTag: Int) {
        
    }
}


extension BubbleViewController : UISearchBarDelegate {
    
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if selectedButton?.tag == 0 {
            viewModel.recentConversationList = []
            if searchText.count > 0 {
            let paramDict = [
                "text": searchText,
                "paginator": [
                    "pageNumber": 1,
                    "nextPage": 1,
                    "previousPage": 1,
                    "totalPages": 2,
                    "pageSize": 10
                ],
                "tagId": selectedTagId
            ] as [String : Any]
                viewModel.recentConversationListApiCall(postDict: paramDict, isSearch: true, isLoadMore: false)
            
            }else if searchText.count == 0
                {
                viewModel.bubbleListData = []
                let paramDict = [
                    "text": searchText,
                    "paginator": [
                        "pageNumber": 1,
                        "nextPage": 1,
                        "previousPage": 1,
                        "totalPages": 2,
                        "pageSize": limit
                    ],
                    "tagId": selectedTagId
                ] as [String : Any]
                viewModel.recentConversationListApiCall(postDict: paramDict, isSearch: true, isLoadMore: false)
            }
            
        }
        
        else{
            //apiCall(text: searchText, tagId: selectedTagId)
            apiCallSearch(text: searchText, tagId: selectedTagId)
        }
    }
    
    
    
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
        
        let newString = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)
        
       // let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        //let filtered = newString.components(separatedBy: cs).joined(separator: "")
        
        if newString.count >= 30 {
            showErrorAlert(error: "Please enter less than 30 characters.")
            return false
        }
        
        return true//newString//(newString == filtered)
    }
    
    
}

extension BubbleViewController {
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        if scrollView == bubbleCollectionView {
//
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
//            {
//                loadMoreData()
//            }
//        }
//    }
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData  {
            self.loadingData = true
            self.nextPageKey = selectedButton?.tag == 1 ? self.viewModel.bubbleModel.value?.data?.paginator?.nextPage ?? 0 : self.viewModel.recentConversationModel.value?.data?.paginator?.nextPage ?? 0
            
            if selectedButton?.tag == 1 {
                apiCall(text: "", tagId: "")
            }else{
                recentConversationAPICall(text: searchBar.text ?? "", isSearch: searchBar.text ?? "" == "" ? false : true, isLoadMore: true)
            }
        }
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
        searchBar?.inputAccessoryView = doneToolbar
    }
    
    
    /**
     It is used to dimiss the current page
     */
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
}

extension BubbleViewController {
    
    /// Segment button is used select the my recents and bubble page 
    @IBAction func segmentButtonTapped(sender:UIButton) {
        
        nextPageKey = 1 //To reset previous selection
        selectedTagId = ""
        conversationTagSelectionBtn.setTitle("All", for: .normal)
        viewModel.recentConversationList = []
        searchBar?.placeholder = "Search here"
        self.tagListView.isHidden = true
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
            
            //bubbleCollectionView.collectionViewLayout = UICollectionViewFlowLayout.init()
            self.noDataView.isHidden = true
            self.tagListView.isHidden = true
            self.bubbleCollectionView.isHidden = false
            recentConversationBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            bubbleBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.bubbleBtn?.isEnabled = false
            self.clearBtn.isHidden = true
            searchBar.text = ""
            searchBar?.placeholder = "Search here"
            descLbl.text = "Here you can start comment in your joined loops"
            self.bubbleCollectionView.reloadData()
            viewModel.recentConversationList = []
            tagSelectionBtn.isHidden = true
            isLoading = true
            conversationTagSelectionBtn.isHidden = false
            recentConversationAPICall(text: searchBar.text ?? "", isSearch: false, isLoadMore: false)
            
            
        } else if sender.tag == 1 {
            
            //            if viewModel.bubbleListData.count > 0{
            //                let alignedFlowLayout = TagsLayout()
            //                bubbleCollectionView.collectionViewLayout = alignedFlowLayout
            //            }
            
            recentConversationBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            bubbleBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
            self.clearBtn.isHidden = true
            viewModel.bubbleListData = []
            self.bubbleCollectionView.reloadData()
            searchBar.text = ""
            isLoading = false
            let bubbleDestroyValue = SessionManager.sharedInstance.settingData?.data?.BubbleDestroyTime ?? 0
            let convertedbubbleDestroyValueToSeconds = ((bubbleDestroyValue) / 3600)
            //descLbl.text = "The bubble will burst in 8 hours, if not revealed"
            descLbl.text = ""
            tagSelectionBtn.isHidden = false
            conversationTagSelectionBtn.isHidden = false
            setUpBubbleViewModel()
            apiCall(text: "", tagId: "")
            
        }
    }
    
    /// Update the selected button with gradient type
    func updateButtonSelection(_ sender: UIButton){
        selectedButton = sender
        selectedButton?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 6
        selectedButton?.layer.masksToBounds = true
        selectedButton?.setTitleColor(UIColor.white, for: .normal)
        
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
        
        recentConversationBtn?.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.4901960784, blue: 0.5058823529, alpha: 1)
        bubbleBtn?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    
}
extension BubbleViewController : selectedBubbleTagDelegate {
    
    /// Update the selected tag details with api call from the delegate communcation
    /// - Parameters:
    ///   - tagId: Send the tag id as string here
    ///   - tagName: Send the tag name 
    func selectedTagDetails(tagId: String, tagName: String) {
        if selectedButton?.tag == 1 {
            viewModel.bubbleListData = []
            tagListView.isHidden = true
            tagListView.removeAllTags()
            searchBar?.text = ""
            searchBar?.placeholder = "Search here"
           
            //tagListView.addTag(tagName.uppercased())
            conversationTagSelectionBtn.setTitle(tagName, for: .normal)
            clearBtn.isHidden = false

            apiCall(text: "", tagId: tagId)
        } else {
            selectedTagId = tagId
            viewModel.recentConversationList = []
            conversationTagSelectionBtn.setTitle(tagName, for: .normal)
            clearBtn.isHidden = false
            
            
            let paramDict = [
                "text": searchBar.text ?? "",
                "paginator": [
                    "pageNumber": 1,
                    "nextPage": 1,//nextPageKey,
                    "previousPage": 1,
                    "totalPages": 1,
                    "pageSize": 10
                ],
                "tagId": selectedTagId
            ] as [String : Any]
            viewModel.recentConversationListApiCall(postDict: paramDict, isSearch: true, isLoadMore: false)
        }
    }
    
}


