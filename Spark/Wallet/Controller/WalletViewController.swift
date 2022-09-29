//
//  WalletViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 07/02/22.
//

import UIKit
import UIView_Shimmer


protocol callBackFromdetail {
    func backFromFeed()
}

/**
 This class is used to show the nft sparklines media using collectionview
 */
class WalletViewController: UIViewController, CHTCollectionViewDelegateWaterfallLayout, callBackFromdetail, backfromFeedDelegate {
    func back(postId: String, threadId: String, userId: String, memberList:[MembersList], messageListApproved:Bool, isFromLoopConversation:Bool, isFromNotify:Bool, isFromHome:Bool, isFromBubble:Bool, isThread:Int, linkPostId:String) {
        isFromback = false
    }
    
   
    
    func backFromFeed() {
        self.isFromback = false
    }
    
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var viewModel = WalletViewModel()
    
    let limit = 10
    
    var nextPageKey = 1
    var previousPageKey = 1
    var userId = ""
    
    //paginator
    var loadingData = false
    var isLoading = false
    var isFromback = false
    
   
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.feedList = []
        setupCollectionView()
        setUpWalletObserver()
        call_wallet(PageNumber: 1, PageSize: self.limit)
    }
    
    
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        if isFromback{
            self.isLoading = false
            self.isFromback = false
        }
        else{
            self.isLoading = false
        }
       
    }
    
    
    
    /// Setup the wallet observer to set the data from api and reload the data
    func setUpWalletObserver() {
        
        viewModel.walletModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.walletModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                if value.data?.feeds?.count ?? 0 > 0 {
                    self.isLoading = false
                    self.noDataLbl.isHidden = true
                    
                    if self.viewModel.walletModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.feedList.count > 1 {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.loadingData = false
                            self.CollectionView.isHidden = false
                            self.CollectionView.reloadData()
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.CollectionView.reloadData()
                            self.isLoading = false
                            self.loadingData = true
                            
                        }
                    }
                    
                    
                }else{
                    
                    self.isLoading = false
                    self.noDataLbl.isHidden = false
                    self.CollectionView.isHidden = true
                    self.loadingData = true
                }
            }
        }
        
    }
    
    /// call the wallet api
    /// - Parameters:
    ///   - PageNumber: Set the page number here
    ///   - PageSize: set  the page size here
    func call_wallet(PageNumber:Int,PageSize:Int){
        let param = [
            "userId": userId,
            "paginator":[
                "nextPage": PageNumber,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String:Any]
        viewModel.getNFTListApiCallNoLoading(params: param)
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        if !self.loadingData {
            self.loadingData = true
            self.nextPageKey = viewModel.walletModel.value?.data?.paginator?.nextPage ?? 0
            self.call_wallet(PageNumber: self.nextPageKey, PageSize: self.limit)
        }
    }
    
    /// Setup the collectionview using layout model with the custom waterfall layout
    func setupCollectionView(){
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 3.0
        layout.minimumInteritemSpacing = 3.0
        
        // Collection view attributes
        CollectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        CollectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        CollectionView.collectionViewLayout = layout
    }
    
  
    /// Back button pressed top dismiss the page
    @IBAction func BackBtnOnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
}

extension WalletViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading{
           return 10
        }
        else{
            return self.viewModel.feedList.count
        }
        
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUICollectionViewCell", for: indexPath) as! ImageUICollectionViewCell
        
        
        if isLoading{
            cell.showDummy()
        }
        else{
            let walletData = self.viewModel.feedList[indexPath.row]
            cell.hideDummy()
            cell.viewBtn.setTitle("\(walletData.viewCount ?? 0)", for: .normal)
            
            //cell.clapBtn.setTitle("\(walletData.clapCount ?? 0)", for: .normal)
            
            let isMonetize = self.viewModel.feedList[indexPath.row].monetize
            if isMonetize == 1{
                cell.monetizeLbl.text = self.viewModel.feedList[indexPath.row].currencySymbol ?? ""
                cell.monetizeView.isHidden = false
            }
            else{
                
                cell.monetizeView.isHidden = true
            }
            
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(walletData.mediaUrl ?? "")"
            
            // Add image to cell
            
            cell.image.setImage(
                url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: "NoImage"))
            
            
            switch walletData.mediaType {
                
            case 1: //Text
                cell.imageBgImage.isHidden = true
                cell.txtBgView.isHidden = false
                cell.image.isHidden = true
                cell.docImageView.isHidden = true
                cell.NftImage.isHidden = true
                cell.txtLbl.text = walletData.postContent
                cell.txtBgView.backgroundColor = UIColor.init(hexString: walletData.bgColor ?? "")
                cell.txtLbl.textColor = UIColor.init(hexString: walletData.textColor ?? "")
                cell.txtBgView.layer.cornerRadius = 5.0
                cell.txtBgView.clipsToBounds = true
                
            case 2: //Image
                
                cell.image.contentMode = .scaleAspectFit
                cell.imageBgImage.isHidden = false
                cell.contentView.backgroundColor = .black
                cell.contentView.layer.cornerRadius = 6.0
                cell.contentView.clipsToBounds = true
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                let isNft = walletData.nft ?? 0
                
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if !(fullMediaUrl.isEmpty) {
                    cell.image.setImage(
                        url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    
                    cell.imageBgImage.setImage(
                        url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    
                    
                } else {
                    cell.image.image = UIImage(named: "NoImage")
                    
                }
                
            case 3 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = false
                
                cell.contentView.backgroundColor = .black
                cell.contentView.layer.cornerRadius = 6.0
                cell.contentView.clipsToBounds = true
                
                let thumpNailUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(walletData.thumbNail ?? "")"
                let isNft = walletData.nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if !(fullMediaUrl.isEmpty) {
                    cell.image.setImage(
                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    cell.imageBgImage.setImage(
                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    
                } else {
                    cell.image.image = UIImage(named: "NoImage")
                    
                }
                
            case 4 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = false
                cell.imageBgImage.contentMode = .scaleAspectFill
                
                let isNft = walletData.nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                cell.image.image = UIImage(named: "Band")
                cell.imageBgImage.image = UIImage(named: "Band")
                
            case 5 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = true
                cell.docImageView.isHidden = false
                cell.imageBgImage.isHidden = true
                
                let isNft = walletData.nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if let fileArray = walletData.mediaUrl {
                    let imageName = fileArray.components(separatedBy: ".")
                    
                    //                if imageName.last == "pdf" {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "pdf")
                    //                }else if imageName.last == "ppt" {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "ppt")
                    //                }else if imageName.last == "doc" ||  imageName.last == "docx" {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "doc")
                    //                }else if imageName.last == "xlsx" {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "xls")
                    //                }else if imageName.last == "xls" {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "xls")
                    //                }
                    //                else  {
                    //                    cell.docImageView.image = #imageLiteral(resourceName: "text")
                    //                }
                    
                    cell.docImageView.image = #imageLiteral(resourceName: "document_image")
                }
                
                
            default:
                break
            }
        }
        
        
        
        return cell
        
    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 20, height: 170)
    }
    
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        let walletData = self.viewModel.feedList.count
        if indexPath.item == walletData - 1 && !loadingData {
            print("loading")
            self.loadMoreData()
        }
    }
    
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NftFeedDetailViewController") as! NftFeedDetailViewController
        vc.postId = self.viewModel.feedList[indexPath.row].postId ?? ""
        vc.userId = self.viewModel.feedList[indexPath.row].userId ?? ""
        vc.backDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
