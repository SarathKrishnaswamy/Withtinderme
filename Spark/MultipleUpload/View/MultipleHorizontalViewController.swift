//
//  MultipleHorizontalViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import UIKit
import RSLoadingView


/**
 This class is used to set all the media list from monetize media  will be shown in the tableview with vertical scrolling will be happen
 */
class MultipleHorizontalViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = MultipleViewModel()
    var multipleFeedListData = [MultipleMediaList]()
    
    var loadingData = false
    var nextPageKey = 1
    var postId = ""
    var limit = 10
    var loadNextPage = false
    var isPlayerFullScreenDismissed = false
    var indexPathItem = Int()
    var playedVideoIndexPath = 0
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        print(indexPathItem)
        self.configurecollectionView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.scrollToIndex(index: self.indexPathItem)
           
            
        }
        //self.collectionView.scrollToItem(at: IndexPath(item: indexPathItem, section: 0), at: .right, animated: false)
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
    
    
    
    /// This method is used to get the observer value from api to set all the media list in collectionview with data
    func setUpViewModel() {
        
        viewModel.multipleModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        viewModel.multipleModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if self.multipleFeedListData.count > 0 {
                
                if self.viewModel.multipleModel.value?.data?.mediaList?.count ?? 0 > 0{
                    self.multipleFeedListData.append(contentsOf: self.viewModel.multipleModel.value?.data?.mediaList ?? [MultipleMediaList]())
                    print(self.multipleFeedListData)
                }
                
                if self.viewModel.multipleModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.multipleFeedListData.count > 0 { //Loading
                    self.loadNextPage = true
                    self.nextPageKey = self.viewModel.multipleModel.value?.data?.paginator?.nextPage ?? 0
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                       
                        self.loadingData = false
                       
                    }
                }else { //No extra data available
                    
                    
                    DispatchQueue.main.async {
                        
                        self.loadingData = true
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            else{
                self.collectionView.reloadData()
                self.loadingData = true
            }
            
        
        }
    }
    
    
    /// Scroll to index with with attributes of item in the collectionview to scroll.
    func scrollToIndex(index:Int) {
         let rect = self.collectionView.layoutAttributesForItem(at:IndexPath(row: index, section: 0))?.frame
         self.collectionView.scrollRectToVisible(rect!, animated: false)
     }
   
    /// Call Api to append the datas
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
            if nextPageKey != 0{
                self.setUpViewModel()
                self.callAPi(pageNumber: nextPageKey)
            }
            
        }
        else {
            //self.noMoreView.isHidden = true
        }
    }
    
    /// Configure the collection view layout with vertical scroll indicatore diasbling and set the opagig enabled
    func configurecollectionView(){
        let layout = UICollectionViewFlowLayout()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
        self.collectionView.contentInset = UIEdgeInsets(top:0, left: 0, bottom:0, right: 0)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        
    }
    
    

   /// Back button on pressed to dismiss the page
    @IBAction func backBtnOnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MultipleHorizontalViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
  
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return multipleFeedListData.count
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleFeedCollectionViewCell", for: indexPath) as! MultipleFeedCollectionViewCell
        if multipleFeedListData.count > 0{
         
            
            switch multipleFeedListData[indexPath.item].mediaType {
            case 1:  //Text
               
                cell.bgTextView.isHidden = false
                cell.textView.isHidden = false
                cell.ContentBgImageView.isHidden = true
                cell.contentBgView.isHidden = true
                cell.videoBgView.isHidden = true
                cell.textView.backgroundColor = .clear
                cell.textView.textAlignment = .center
                cell.textView.font = UIFont.MontserratMedium(.veryLarge)
                cell.playBtn.isHidden = true
                cell.activityLoader.isHidden = true
                if self.multipleFeedListData[indexPath.item].bgColor ?? "" != "" {
                    if self.multipleFeedListData[indexPath.item].bgColor ?? "" == "#ffffff" {
                        Helper.sharedInstance.loadTextIntoCell(text: self.multipleFeedListData[indexPath.item].postContent ?? "", textColor: "#ffffff", bgColor: "368584", label: cell.textView, bgView: cell.bgTextView)
                    }else{
                        Helper.sharedInstance.loadTextIntoCell(text: self.multipleFeedListData[indexPath.item].postContent ?? "", textColor: self.multipleFeedListData[indexPath.item].textColor ?? "", bgColor: self.multipleFeedListData[indexPath.item].bgColor ?? "", label: cell.textView, bgView: cell.bgTextView)
                    }
                }else{
                    Helper.sharedInstance.loadTextIntoCell(text: self.multipleFeedListData[indexPath.item].postContent ?? "", textColor: "FFFFFF", bgColor: "358383", label: cell.textView, bgView: cell.bgTextView)
                }
                
            case 2: //Image
                cell.bgTextView.isHidden = true
                cell.textView.isHidden = true
                cell.ContentBgImageView.isHidden = false
                cell.contentBgView.isHidden = false
                cell.videoBgView.isHidden = true
                cell.playBtn.isHidden = true
                cell.activityLoader.isHidden = true
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                cell.contentBgView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                
                cell.ContentBgImageView.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                
            case 3: // Video
                cell.delegate = self
                cell.bgTextView.isHidden = true
                cell.textView.isHidden = true
                cell.ContentBgImageView.isHidden = false
                cell.contentBgView.isHidden = true
                cell.videoBgView.isHidden = false
                cell.videoBgView.tag = indexPath.row
                cell.playBtn.isHidden = true
                cell.activityLoader.isHidden = true
                
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.multipleFeedListData[indexPath.item].thumbNail ?? "")"
                cell.mediaUrl = self.multipleFeedListData[indexPath.item].mediaUrl ?? ""
                cell.ContentBgImageView.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: UIImage(named: "NoImage"))
                cell.playOrPauseVideo(url: self.multipleFeedListData[indexPath.item].mediaUrl ?? "", parent: self, play: false)
            case 4: //Audio
                cell.delegate = self
                cell.bgTextView.isHidden = true
                cell.textView.isHidden = true
                cell.ContentBgImageView.isHidden = true
                cell.contentBgView.isHidden = true
                cell.videoBgView.isHidden = false
                cell.videoBgView.tag = indexPath.row
                cell.playBtn.isHidden = true
                cell.activityLoader.isHidden = true
                
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                cell.mediaUrl = fullMediaUrl//self.viewModel.feedListData[indexPath.item].mediaUrl ?? ""
                cell.AudioplayOrPauseVideo(url: fullMediaUrl, parent: self, play: false)
            case 5: //Document
                cell.bgTextView.isHidden = true
                cell.textView.isHidden = true
                cell.ContentBgImageView.isHidden = false
                cell.contentBgView.isHidden = false
                cell.videoBgView.isHidden = true
                cell.contentBgView.image = UIImage(named: "document_image")
                cell.ContentBgImageView.image = UIImage(named: "document_image")
                cell.playBtn.isHidden = true
                cell.activityLoader.isHidden = true
                
            default:
                break
            }
            
        }
        
        return cell
    }
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        let mediaType = multipleFeedListData[indexPath.item].mediaType ?? 0
        
        if mediaType == 2{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
                vc.url = fullMediaUrl
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.present(vc, animated: false, completion: nil)
            }
            
            
        }
        else if mediaType == 5{
            DispatchQueue.main.async {
                RSLoadingView().showOnKeyWindow()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.multipleFeedListData[indexPath.item].mediaUrl ?? "")"
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let docVC = storyBoard.instantiateViewController(identifier: "DocumentViewerWebViewController") as! DocumentViewerWebViewController
                docVC.url = fullMediaUrl
                self.present(docVC, animated: false, completion: nil)
            }
        }
       
    }
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = multipleFeedListData.count - 1
        if lastItem == indexPath.item{
            self.loadMoreData()
        }
    }
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return view.frame.size//CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }

    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose line spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive lines in a section.
    ///  - If you do not implement this method, the flow layout uses the value in its minimumLineSpacing property to set the space between lines instead. Your implementation of this method can return a fixed value or return different spacing values for each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
    
    /// Tells the delegate that the scroll view is starting to decelerate the scrolling movement.
    /// Declare the tableview scroll to pause the player when it is playing
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method as the user’s finger touches up as it’s moving during a scrolling operation; the scroll view continues to move a short distance afterwards. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? MultipleFeedCollectionViewCell
        //cell?.audioAnimationBg.stopAnimatingGif()
        
        cell?.playerController?.player?.pause()
        //cell?.isReuse = true
        
        print("scrolling")
        
    }
    
    
    
    /// Tells the delegate that the scroll view ended decelerating the scrolling movement.
    /// - Parameter scrollView: The scroll-view object that’s decelerating the scrolling of the content view.
    ///  - The scroll view calls this method when the scrolling movement comes to a halt. The isDecelerating property of UIScrollView controls deceleration.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? MultipleFeedCollectionViewCell
        //cell?.audioAnimationBg.stopAnimatingGif()
        
        
        cell?.playerController?.player?.pause()
        
    }
    
}


/// This extension class is used to get the delegates of video or audio player dismiss the fullscreen to get the indexpath of currently playing
extension MultipleHorizontalViewController : getPlayerVideoAudioIndexDelegate {
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
        
//        let indexPath = IndexPath(row: playedVideoIndexPath, section: 0)
//        let cell = collectionView?.cellForItem(at: indexPath) as? NewsCardCollectionCell
//        if isPlaying == true{
//            //cell?.audioAnimationBg.startAnimatingGif()
//        }
//        else{
//            //cell?.audioAnimationBg.stopAnimatingGif()
//        }
    }
    
}
