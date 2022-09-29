//
//  TimelineTableViewCell.swift
//  Spark
//
//  Created by adhash on 21/07/21.
//

import UIKit
import UIView_Shimmer
import SocketIO
import CoreLocation
import Kingfisher

protocol ProfileTimeLineDelegate {
    func getSelectedTimelineData(postId:String,threadId:String,isFromBubble:Bool)
}

class TimelineImageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout,ShimmeringViewProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate:ProfileTimeLineDelegate?
    
    @IBOutlet weak var noDataImgView: UIImageView!
    @IBOutlet weak var noDatalbl: UILabel!
    
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    @IBOutlet weak var dummyView3: UIView!

    
    //Btns
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var socialBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var sparkLinesHeading: UILabel!
    
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    
    var locationManager = CLLocationManager()
    
    //paginator
    var loadingData = false
    var isLoading = false
    var postType = 1
    
    var viewModel = ProfileViewModel()
    var tableView = UITableView()
    var reloadDelegate : sparklinesReloadDelegate?
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3
            
        ]
    }
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Attach datasource and delegate
        collectionView.dataSource  = self
        collectionView.delegate = self
        //isLoading = true
        
        setupCollectionView()
        setupTimelineViewModel()
        //self.global()
        resetBtn()
        globalBtn.tintColor = .white
        globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        globalBtn.setTitleColor(.white, for: .normal)
        globalBtn.layer.borderWidth = 0
        globalBtn.layer.cornerRadius = 3
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 1)

        //Register nibs
       // registerNibs()
    }

    func getMyTimelineListValues(PageNumber:Int,PageSize:Int,postType:Int) {
        let params = [
            "postType" :postType,
            "paginator":[
                "nextPage": PageNumber,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
            
            
        
        self.viewModel.getMyTimelineAPICall(postDict: params)
    }
    
    
    
    ///This load more data is used to call the pagination and load the next set of datas.
    func loadMoreData() {
        DisableBtn()
        if !self.loadingData {
            self.loadingData = true
            self.nextPageKey = viewModel.timelineModel.value?.data?.paginator?.nextPage ?? 0
            self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, postType: postType)
        }
    }
    
    
    /// Sets the selected state of the cell, optionally animating the transition between states.
    /// - Parameters:
    ///   - selected: true to set the cell as selected, false to set it as unselected. The default is false.
    ///   - animated: true to animate the transition between selected states, false to make the transition immediate.
    ///    - The selection affects the appearance of labels, image, and background. When the selected state of a cell is true, it draws the background for selected cells (Reusing cells) with its title in white.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showDummy(){
        self.dummyView1.isHidden = false
        self.dummyView2.isHidden = false
        self.dummyView3.isHidden = false
        //collectionView.isHidden = true
        noDataImgView.isHidden = true
        noDatalbl.isHidden = true
        btnView.isHidden = true
        
    }
    
    func hideDummy(){
        self.dummyView1.isHidden = true
        self.dummyView2.isHidden = true
        self.dummyView3.isHidden = true
        collectionView.isHidden = false
        noDataImgView.isHidden = false
        noDatalbl.isHidden = false
        btnView.isHidden = false
    }
    
    
    ///View Model Setup to reload the collectionview data
       func setupTimelineViewModel() {
           
           viewModel.timelineModel.observeError = { [weak self] error in
               guard let self = self else { return }
               self.enableBtn()
               print(statusHttpCode.statusCode)
               print("Its error")
              
        
               
           }
           viewModel.timelineModel.observeValue = { [weak self] value in
               guard let self = self else { return }
               
               if self.viewModel.feedListData.count > 0 {
                   
                   self.noDataImgView.isHidden = true
                    self.noDatalbl.isHidden = true
                   //self.collectionView.isHidden = false
                   
                   if self.viewModel.timelineModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.feedListData.count > 1 { //Loading
                       DispatchQueue.main.async {
                           self.isLoading = false
                           self.collectionView.reloadData()
                           self.reloadDelegate?.reloadTableViewIndex()
                           //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .bottom)
                           self.loadingData = false
                           self.enableBtn()

                       }
                   }else { //No extra data available
                       DispatchQueue.main.async {
                           self.collectionView.reloadData()
                           self.isLoading = false
                           self.reloadDelegate?.reloadTableViewIndex()
                           //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .bottom)
                           self.loadingData = false
                           self.loadingData = true
                           
                       }
                   }
                   
               }else{
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                       self.isLoading = false
                       self.noDataImgView.isHidden = false
                       self.noDatalbl.isHidden = false
                       self.collectionView.isHidden = true
                       self.reloadDelegate?.reloadTableViewIndex()
                   })
               }
               self.enableBtn()
           }
       }
    
    /// Setup the collectionview
    //MARK: - CollectionView UI Setup
    func setupCollectionView(){
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 3.0
        layout.minimumInteritemSpacing = 3.0
        
        // Collection view attributes
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        collectionView.collectionViewLayout = layout
    }
    
    /// Reset button is used to  gradient can be reset here
    func resetBtn(){
        globalBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        localBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        socialBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        closedBtn?.setGradientBackgroundColors([#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)], direction: .toRight, for: .normal)
        
        globalBtn?.layer.masksToBounds = true
        localBtn?.layer.masksToBounds = true
        socialBtn?.layer.masksToBounds = true
        closedBtn?.layer.masksToBounds = true
        
        globalBtn.layer.borderColor = UIColor.lightGray.cgColor
        localBtn.layer.borderColor = UIColor.lightGray.cgColor
        socialBtn.layer.borderColor = UIColor.lightGray.cgColor
        closedBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        globalBtn.layer.borderWidth = 1.0
        localBtn.layer.borderWidth = 1.0
        socialBtn.layer.borderWidth = 1.0
        closedBtn.layer.borderWidth = 1.0
        
        globalBtn.layer.cornerRadius = 3.0
        localBtn.layer.cornerRadius = 3.0
        socialBtn.layer.cornerRadius = 3.0
        closedBtn.layer.cornerRadius = 3.0
        
        globalBtn.tintColor = .lightGray
        localBtn.tintColor = .lightGray
        socialBtn.tintColor = .lightGray
        closedBtn.tintColor = .lightGray
        
        globalBtn.setTitleColor(.lightGray, for: .normal)
        localBtn.setTitleColor(.lightGray, for: .normal)
        socialBtn.setTitleColor(.lightGray, for: .normal)
        closedBtn.setTitleColor(.lightGray, for: .normal)
        
        
        globalBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        localBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        socialBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        closedBtn.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    }
    
    
    
    /// Set a gradient color to use in background buttons and views
    /// - Parameters:
    ///   - colors: Multiple colors can be declared inside colors
    ///   - locations: From value of 0 - 1 to set the position of colors
    ///   - size: set the coolor for width and height for any of the view
    /// - Returns: It returns the UIColor to set on the view or buttons
    func linearGradientColor(from colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIColor {
        let image = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)).image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locations
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y:size.width),
                options:[]
            )
        }
        return UIColor(patternImage: image)
    }
    
    ///Enable global button slect with gradient
    func global(){
        resetBtn()
        globalBtn.tintColor = .white
        globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        globalBtn.setTitleColor(.white, for: .normal)
        globalBtn.layer.borderWidth = 0
        globalBtn.layer.cornerRadius = 3
        self.collectionView.reloadData()
        isLoading = true
        viewModel.feedListData = []
        postType = 1
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 1)
        
    }
    
    ///Enable diable button with gradient
    func DisableBtn() {
        self.globalBtn.isEnabled = false
        self.localBtn.isEnabled = false
        self.socialBtn.isEnabled = false
        self.closedBtn.isEnabled = false
    }
    
    /// Enable the button
    func enableBtn(){
        self.globalBtn.isEnabled = true
        self.localBtn.isEnabled = true
        self.socialBtn.isEnabled = true
        self.closedBtn.isEnabled = true
    }
    
    /// It will show the count if its greater than '1000' and less than  '1000000' it will show K if its greater than 1000000 it will show M
    /// - Parameter num: Here we need to pass the double value of the count
    /// - Returns: It will return as string to append in the label
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))K")
            }
            return("\(thousandNum.roundToPlaces(places: 1))K")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))K")
            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }

    }
    
    ///Global button pressed to highlight the global button with reload the collectionview
    @IBAction func globalBtnOnPressed(_ sender: Any) {
        resetBtn()
        globalBtn.tintColor = .white
        globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        globalBtn.setTitleColor(.white, for: .normal)
        globalBtn.layer.borderWidth = 0
        globalBtn.layer.cornerRadius = 3
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        isLoading = true
        viewModel.feedListData = []
        postType = 1
        self.DisableBtn()
        self.nextPageKey = 1
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 1)
        
        
    }
    
    ///Local button pressed to highlight the global button with reload the collectionview
    @IBAction func localBtnOnPressed(_ sender: Any) {
        resetBtn()
        localBtn.tintColor = .white
        localBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        localBtn.setTitleColor(.white, for: .normal)
        localBtn.layer.borderWidth = 0
        localBtn.layer.cornerRadius = 3
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        isLoading = true
        viewModel.feedListData = []
        postType = 2
        self.DisableBtn()
        self.nextPageKey = 1
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 2)
        // setupTimelineViewModel()getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
        
        
    }
    
    /// Social button pressed to highlight the social button and reload the collectionView
    @IBAction func socialBtnOnPressed(_ sender: Any) {
        resetBtn()
        socialBtn.tintColor = .white
        socialBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        socialBtn.setTitleColor(.white, for: .normal)
        socialBtn.layer.borderWidth = 0
        socialBtn.layer.cornerRadius = 3
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        isLoading = true
        viewModel.feedListData = []
        postType = 3
        self.DisableBtn()
        self.nextPageKey = 1
        //setupTimelineViewModel()
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 3)
        
    }
    
    /// Select the closed button pressed to highlight the closed button and reload the collectionview
    @IBAction func closedBtnOnPressed(_ sender: Any) {
        resetBtn()
        closedBtn.tintColor = .white
        closedBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        closedBtn.setTitleColor(.white, for: .normal)
        closedBtn.layer.borderWidth = 0
        closedBtn.layer.cornerRadius = 3
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        isLoading = true
        viewModel.feedListData = []
        postType = 4
        self.DisableBtn()
        self.nextPageKey = 1
        self.getMyTimelineListValues(PageNumber: 1, PageSize: self.limit, postType: 4)
        //setupTimelineViewModel()
        
    }
    //MARK: - CollectionView Delegate Methods
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if isLoading{
            return 4
        }
        else{
            return self.viewModel.feedListData.count
        }
            
        
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Create the cell and return the cell
        
       
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUICollectionViewCell", for: indexPath) as! ImageUICollectionViewCell
        
        
        if isLoading{
            cell.showDummy()
        }
        else{
            cell.hideDummy()
            cell.viewBtn.setTitle("\(formatPoints(num: Double(viewModel.feedListData[indexPath.item].viewCount ?? 0)))", for: .normal)
            let isRepost = viewModel.feedListData[indexPath.item].isRepost ?? false
            if isRepost == false{
                cell.repostImage.isHidden = true
            }
            else{
                cell.repostImage.isHidden = false
            }
            let isMonetize = viewModel.feedListData[indexPath.item].monetize ?? 0
            if isMonetize == 1{
                cell.monetizeLbl.text = self.viewModel.feedListData[indexPath.item].currencySymbol ?? ""
                cell.monetizeView.isHidden = false
            }
            else{
                cell.monetizeView.isHidden = true
            }
           
            //cell.clapBtn.setTitle("\(formatPoints(num: Double(viewModel.feedListData[indexPath.item].clapCount ?? 0)))", for: .normal)
            
           // cell.postTypeImgView.isHidden = false
            
//            let postType = self.viewModel.feedListData[indexPath.row].postType
//            
//            switch postType {
//            case 1:
//                cell.postTypeImgView.image = #imageLiteral(resourceName: "global")
//            case 2:
//                cell.postTypeImgView.image = #imageLiteral(resourceName: "local")
//            case 3:
//                cell.postTypeImgView.image = #imageLiteral(resourceName: "social")
//            case 4:
//                cell.postTypeImgView.image = #imageLiteral(resourceName: "closed")
//            default:
//                break
//            }
            
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.row].mediaUrl ?? "")"
            
            // Add image to cell
            
                cell.image.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                  placeholder: #imageLiteral(resourceName: "NoImage"))
                            
          
            switch self.viewModel.feedListData[indexPath.row].mediaType {
            
            case 1: //Text
                
                cell.txtBgView.isHidden = false
                cell.image.isHidden = true
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = true
                cell.NftImage.isHidden = true
                cell.txtLbl.text = self.viewModel.feedListData[indexPath.row].postContent
                cell.txtBgView.backgroundColor = UIColor.init(hexString: self.viewModel.feedListData[indexPath.row].bgColor ?? "")
                cell.txtLbl.textColor = UIColor.init(hexString: self.viewModel.feedListData[indexPath.row].textColor ?? "")
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
                let isNft = self.viewModel.feedListData[indexPath.row].nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if !(fullMediaUrl.isEmpty) {
                    
                    cell.image.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                    
                    cell.imageBgImage.kf.setImage(with:URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
//                    cell.image.setImage(
//                        url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
//                      placeholder: #imageLiteral(resourceName: "NoImage"))
//
//                    cell.imageBgImage.setImage(
//                        url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
//                      placeholder: #imageLiteral(resourceName: "NoImage"))

                    
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
                
                let thumpNailUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.row].thumbNail ?? "")"
                let isNft = self.viewModel.feedListData[indexPath.row].nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if !(fullMediaUrl.isEmpty) {
                    cell.image.kf.setImage(with:URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
                    
                    cell.imageBgImage.kf.setImage(with:URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: "") , placeholder: UIImage(named: "NoImage"), options: [.keepCurrentImageWhileLoading], progressBlock: nil, completionHandler: nil)
//                    cell.image.setImage(
//                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
//                      placeholder: #imageLiteral(resourceName: "NoImage"))
//                    cell.imageBgImage.setImage(
//                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
//                      placeholder: #imageLiteral(resourceName: "NoImage"))
                                    
                } else {
                    cell.image.image = UIImage(named: "NoImage")
                    cell.imageBgImage.image = UIImage(named: "NoImage")
                }
                
            case 4 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = false
                cell.imageBgImage.contentMode = .scaleAspectFill
                
                
                
                let isNft = self.viewModel.feedListData[indexPath.row].nft ?? 0
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
                let isNft = self.viewModel.feedListData[indexPath.row].nft ?? 0
                if isNft == 0{
                    cell.NftImage.isHidden = true
                }
                else{
                    cell.NftImage.isHidden = false
                }
                if let fileArray = self.viewModel.feedListData[indexPath.row].mediaUrl {
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
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.getSelectedTimelineData(postId: self.viewModel.feedListData[indexPath.row].postId ?? "", threadId: self.viewModel.feedListData[indexPath.row].threadId ?? "", isFromBubble: false)
        
    }
    
    //MARK: - CollectionView Waterfall Layout Delegate Methods (Required)
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width / 2 - 20, height: 170)
        // create a cell size from the image size, and return the size
//        var cellSizes = [CGSize]()
//        for _ in 0...(self.viewModel.feedListData.count ) {
//                  let randomDouble = Double.random(in: 10...100)
//            cellSizes.append(CGSize(width: 240, height: 200 + randomDouble))
//        }
//
//        return cellSizes[indexPath.row]
    }
    
    
    /// Asks the delegate for the size of the header view in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index of the section whose header size is being requested.
    /// - Returns: The size of the header. If you return a value of size (0, 0), no header is added.
    /// - If you do not implement this method, the flow layout uses the value in its headerReferenceSize property to set the size of the header.
    /// - During layout, only the size that corresponds to the appropriate scrolling direction is used. For example, for the vertical scrolling direction, the layout object uses the height value returned by your method. (In that instance, the width of the header would be set to the width of the collection view.) If the size in the appropriate scrolling dimension is 0, no header is added.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForHeaderIn section: Int) -> CGFloat {
        return section == 0 ? self.viewModel.feedListData.count == 0 ? 0 : 40 : 0
    }
    
    
    
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
        
        if indexPath.item == self.viewModel.feedListData.count  - 1 && !loadingData {
            self.loadMoreData()
        }
    }
    
}
extension UICollectionView{
    /// Reload the items in collectionview with section
    /// - Parameter section: Set the integer here
    func reloadItems(inSection section:Int = 0) {
        print("made it to reload")
        for i in 0..<self.numberOfItems(inSection: section){
        self.reloadItems(at: [IndexPath(item: i, section: section)])
        }
    }
}
