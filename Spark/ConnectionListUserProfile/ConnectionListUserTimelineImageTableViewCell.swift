//
//  TimelineTableViewCell.swift
//  Spark
//
//  Created by adhash on 21/07/21.
//

import UIKit
import UIView_Shimmer
import CoreLocation

/**
 Connection user list time line delegate with timeline call with post id and thread id and from bubble
 */
protocol ConnectionUserListTimeLineDelegate {
    func getSelectedTimelineData(postId:String,threadId:String,isFromBubble:Bool)
}


/**
 'This cell is used to set the timeline cell with collection view data with the waterfall layout with collection view
 */

class ConnectionListUserTimelineImageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout,ShimmeringViewProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userId = ""
    
    @IBOutlet weak var noDataImgView: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    
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
    
    var locationManager = CLLocationManager()
    var parentVC: UIViewController?
    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 10
    var postType = 1
    //paginator
    var loadingData = false
    var isLoading = false
    
    var viewModel = ConnectionListUserProfileViewModel()
    
    var delegate:ConnectionUserListTimeLineDelegate?
    var timeLineDelegate : connectionTimelineDelegate?
    var sparklinereloadDelegate : sparklinesReloadDelegate?
    var currentLat = 0.0
    var currentLong = 0.0
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2,
            dummyView3
            
        ]
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Attach datasource and delegate
        collectionView.dataSource  = self
        collectionView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        setupCollectionView()
        
        setupTimelineViewModel()
        
        resetBtn()
        globalBtn.tintColor = .white
        globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        globalBtn.setTitleColor(.white, for: .normal)
        globalBtn.layer.borderWidth = 0
        globalBtn.layer.cornerRadius = 3
        getMyTimelineListValues(PageNumber: 1, PageSize: 10, userId: SessionManager.sharedInstance.otherUserId, postType: 1)
        //getMyTimelineListValues(PageNumber: 1, PageSize: 10, userId: userId, postType: 1)
        
    }
    
    func getMyTimelineListValues(PageNumber:Int,PageSize:Int,userId:String,postType:Int) {
        
        let params = [
            "userId" :userId,
            "coordinates":[postType == 2 ?SessionManager.sharedInstance.saveUserCurrentLocationDetails["long"] ?? 0.0:0.0,postType == 2 ?SessionManager.sharedInstance.saveUserCurrentLocationDetails["lat"] ?? 0.0:0.0],
            "postType":postType,
            "paginator":[
                "nextPage": PageNumber,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": 1,
                "totalPages": 1
            ]
        ] as [String : Any]
        
        self.viewModel.getMyTimelineAPICallNoLoading(postDict: params)
    }
    
    
    
    func loadMoreData() {
        DisableBtn()
        if !self.loadingData {
            self.loadingData = true
            self.nextPageKey = viewModel.timelineModel.value?.data?.paginator?.nextPage ?? 0
            self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showDummy(){
        self.dummyView1.isHidden = false
        self.dummyView2.isHidden = false
        self.dummyView3.isHidden = false
        collectionView.isHidden = true
        noDataImgView.isHidden = true
        noDataLbl.isHidden = true
        btnView.isHidden = true
        
        
    }
    
    func hideDummy(){
        self.dummyView1.isHidden = true
        self.dummyView2.isHidden = true
        self.dummyView3.isHidden = true
//        if self.viewModel.feedListData.count > 0 {
        collectionView.isHidden = false
//        }
//        else{
//            collectionView.isHidden = true
//        }
        noDataImgView.isHidden = true
        noDataLbl.isHidden = true
        btnView.isHidden = false
    }
    
    
    //View Model Setup
    func setupTimelineViewModel() {
        
        viewModel.timelineModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //self.timeLineDelegate?.stopLoader()
        }
        viewModel.timelineModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if self.viewModel.feedListData.count > 0 {
                
                self.noDataImgView.isHidden = true
                self.noDataLbl.isHidden = true
                //self.collectionView.isHidden = false
                
                if self.viewModel.timelineModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.feedListData.count > 1 { //Loading
                    DispatchQueue.main.async {
                        self.noDataImgView.isHidden = true
                        self.noDataLbl.isHidden = true
                        self.isLoading = false
                        self.collectionView.isHidden = false
                        self.collectionView.reloadData()
                        self.sparklinereloadDelegate?.reloadTableViewIndex()
                        self.loadingData = false
                        
                        //self.timeLineDelegate?.stopLoader()
                        
                    }
                }else { //No extra data available
                    DispatchQueue.main.async {
                    
                        
                        //self.loadingData = false
                        self.loadingData = true
                       
                    }
                    self.noDataImgView.isHidden = true
                    self.noDataLbl.isHidden = true
                    self.isLoading = false
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    //self.loadingData = false
                    
                    self.sparklinereloadDelegate?.reloadTableViewIndex()
                }
                
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isLoading = false
                    self.noDataImgView.isHidden = false
                    self.noDataLbl.isHidden = false
                    self.collectionView.isHidden = true
                    self.sparklinereloadDelegate?.reloadTableViewIndex()
                })
                    
                
            }
            
            self.enableBtn()
            
        }
    }
    //MARK: - CollectionView UI Setup
    func setupCollectionView(){
        
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        
        // Change individual layout attributes for the spacing between cells
        //        layout.minimumColumnSpacing = 10.0
        //        layout.minimumInteritemSpacing = 10.0
        
        // Collection view attributes
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        collectionView.collectionViewLayout = layout
    }
    
    
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
        getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
    }
    
    func DisableBtn() {
        self.globalBtn.isEnabled = false
        self.localBtn.isEnabled = false
        self.socialBtn.isEnabled = false
        self.closedBtn.isEnabled = false
    }
    
    func enableBtn(){
        self.globalBtn.isEnabled = true
        self.localBtn.isEnabled = true
        self.socialBtn.isEnabled = true
        self.closedBtn.isEnabled = true
    }
    
    
    //MARK: - Button Actions
    
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
        getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
        
    }
    
    @IBAction func localBtnOnPressed(_ sender: Any) {
        resetBtn()
        //
      
        let locationManager = CLLocationManager()
        
        //            if CLLocationManager.locationServicesEnabled() {
        
        if #available(iOS 14.0, *) {
            
            switch locationManager.authorizationStatus {
                
            case .notDetermined, .restricted, .denied:
                print("No access")
                self.global()
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                
                //to change font of title and message.
                let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                
                let titleAttrString = NSMutableAttributedString(string: "Location Permission", attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to Location to get your nearest spark. Go to Settings to grant access.\n", attributes: messageFont)
                
                alert.setValue(titleAttrString, forKey: "attributedTitle")
                alert.setValue(messageAttrString, forKey: "attributedMessage")
                
                if let settings = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settings) {
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                        
                        UIApplication.shared.open(settings)
                    })
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    self.global()
                })
                parentVC?.present(alert, animated: true)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
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
                //setupTimelineViewModel()
                postType = 2
                self.DisableBtn()
                self.nextPageKey = 1
                getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
                
                
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                self.global()
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                
                //to change font of title and message.
                let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                
                let titleAttrString = NSMutableAttributedString(string: "Location Permission", attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to Location to get your nearest spark. Go to Settings to grant access.\n", attributes: messageFont)
                
                alert.setValue(titleAttrString, forKey: "attributedTitle")
                alert.setValue(messageAttrString, forKey: "attributedMessage")
                
                if let settings = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settings) {
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                        
                        UIApplication.shared.open(settings)
                    })
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    self.global()
                })
                parentVC?.present(alert, animated: true)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
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
               // setupTimelineViewModel()
                getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
                
            @unknown default:
                break
            }
            
        }
        
    }
    
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
        getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
    }
    
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
        //setupTimelineViewModel()
        getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
    }
    
    
    //MARK: - CollectionView Delegate Methods
    
    //** Number of Cells in the CollectionView */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading{
            return 4
        }
        else{
            return self.viewModel.feedListData.count
        }
        
    }
    
    
    //** Create a basic CollectionView Cell */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectionListUserProfileImageUICollectionViewCell", for: indexPath) as! ConnectionListUserProfileImageUICollectionViewCell
        if isLoading{
            cell.showDummy()
        }
        else{
            cell.hideDummy()
            let isNft = self.viewModel.feedListData[indexPath.row].nft ?? 0
            
            let isMonetize = self.viewModel.feedListData[indexPath.row].monetize ?? 0
            if isMonetize == 1{
                cell.monetizeLbl.text = self.viewModel.feedListData[indexPath.row].currencySymbol ?? ""
                cell.monetizeView.isHidden = false
            }
            else{
                cell.monetizeView.isHidden = true
            }
            
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
            //
            cell.viewBtn.setTitle("\(formatPoints(num: Double(viewModel.feedListData[indexPath.item].viewCount ?? 0)))", for: .normal)
//            cell.clapBtn.setTitle("\(formatPoints(num: Double(viewModel.feedListData[indexPath.item].clapCount ?? 0)))", for: .normal)
            
            let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.row].mediaUrl ?? "")"
            
            // Add image to cell
            
            if !(fullMediaUrl.isEmpty) {
                cell.image.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: "NoImage"))
                
            } else {
                cell.image.image = UIImage(named: "NoImage")
                
            }
            
            
            switch self.viewModel.feedListData[indexPath.row].mediaType {
                
            case 1: //Text
                
                cell.txtBgView.isHidden = false
                cell.image.isHidden = true
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = true
                
                cell.txtLbl.text = self.viewModel.feedListData[indexPath.row].postContent
                cell.txtBgView.backgroundColor = UIColor.init(hexString: self.viewModel.feedListData[indexPath.row].bgColor ?? "")
                cell.txtLbl.textColor = UIColor.init(hexString: self.viewModel.feedListData[indexPath.row].textColor ?? "")
                cell.txtBgView.layer.cornerRadius = 5.0
                cell.txtBgView.clipsToBounds = true
                cell.connectionProfileNFTimage.isHidden = true
                
                
            case 2: //Image
                
                cell.image.contentMode = .scaleAspectFit
                cell.imageBgImage.isHidden = false
                cell.contentView.backgroundColor = .black
                cell.contentView.layer.cornerRadius = 6.0
                cell.contentView.clipsToBounds = true
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                
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
                
                if isNft == 0{
                    cell.connectionProfileNFTimage.isHidden = true
                }
                else{
                    cell.connectionProfileNFTimage.isHidden = false
                }
                
            case 3 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = false
                cell.image.contentMode = .scaleAspectFit
                
                cell.contentView.backgroundColor = .black
                cell.contentView.layer.cornerRadius = 6.0
                cell.contentView.clipsToBounds = true
                
                let thumpNailUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.viewModel.feedListData[indexPath.row].thumbNail ?? "")"
                
                if !(fullMediaUrl.isEmpty) {
                    cell.image.setImage(
                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    cell.imageBgImage.setImage(
                        url: URL.init(string: thumpNailUrl) ?? URL(fileURLWithPath: ""),
                        placeholder: #imageLiteral(resourceName: "NoImage"))
                    
                } else {
                    cell.image.image = UIImage(named: "NoImage")
                    cell.imageBgImage.image = UIImage(named: "NoImage")
                    
                }
                
                if isNft == 0{
                    cell.connectionProfileNFTimage.isHidden = true
                }
                else{
                    cell.connectionProfileNFTimage.isHidden = false
                }
                
            case 4 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = false
                cell.docImageView.isHidden = true
                cell.imageBgImage.isHidden = false
                cell.image.image = UIImage(named: "Band")
                cell.imageBgImage.image = UIImage(named: "Band")
                cell.imageBgImage.contentMode = .scaleAspectFill
                
                if isNft == 0{
                    cell.connectionProfileNFTimage.isHidden = true
                }
                else{
                    cell.connectionProfileNFTimage.isHidden = false
                }
                
            case 5 :
                
                cell.txtBgView.isHidden = true
                cell.image.isHidden = true
                cell.docImageView.isHidden = false
                cell.imageBgImage.isHidden = true
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
                
                if isNft == 0{
                    cell.connectionProfileNFTimage.isHidden = true
                }
                else{
                    cell.connectionProfileNFTimage.isHidden = false
                }
                
                
            default:
                break
            }
        }
        
        
        
        return cell
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
        //            let randomDouble = Double.random(in: 10...100)
        //            cellSizes.append(CGSize(width: 240, height: 200 + randomDouble))
        //        }
        //
        //        return cellSizes[indexPath.row]
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ConnectionListHeaderCollectionReusableView", for: indexPath) as! ConnectionListHeaderCollectionReusableView
//
//            view.globalButtonAction = { [unowned self] in
//                view.resetBtn()
//                view.globalBtn.tintColor = .white
//                view.globalBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//                view.globalBtn.setTitleColor(.white, for: .normal)
//                view.globalBtn.layer.borderWidth = 0
//                view.globalBtn.layer.cornerRadius = 3
//                self.postType = 1
//                self.collectionView.reloadData()
//                self.isLoading = true
//                viewModel.feedListData = []
//                self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
//            }
//
//            view.localButtonAction = { [unowned self] in
//                view.resetBtn()
//                view.localBtn.tintColor = .white
//                view.localBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//                view.localBtn.setTitleColor(.white, for: .normal)
//                view.localBtn.layer.borderWidth = 0
//                self.postType = 2
//                view.localBtn.layer.cornerRadius = 3
//                self.collectionView.reloadData()
//                self.isLoading = true
//                viewModel.feedListData = []
//                self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
//
//            }
//
//            view.socialButtonAction = { [unowned self] in
//                view.resetBtn()
//                view.socialBtn.tintColor = .white
//                view.socialBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//                view.socialBtn.setTitleColor(.white, for: .normal)
//                view.socialBtn.layer.borderWidth = 0
//                self.postType = 3
//                view.socialBtn.layer.cornerRadius = 3
//                self.collectionView.reloadData()
//                self.isLoading = true
//                viewModel.feedListData = []
//                self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
//            }
//
//            view.closedButtonAction = { [unowned self] in
//                view.resetBtn()
//                view.closedbtn.tintColor = .white
//                view.closedbtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//                view.closedbtn.setTitleColor(.white, for: .normal)
//                view.closedbtn.layer.borderWidth = 0
//                self.postType = 4
//                view.closedbtn.layer.cornerRadius = 3
//                self.collectionView.reloadData()
//                self.isLoading = true
//                viewModel.feedListData = []
//                self.getMyTimelineListValues(PageNumber: self.nextPageKey, PageSize: self.limit, userId: userId, postType: postType)
//            }
//
//            return view
//        }
//        fatalError("Unexpected kind")
//    }
    
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
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.getSelectedTimelineData(postId: self.viewModel.feedListData[indexPath.row].postId ?? "", threadId: self.viewModel.feedListData[indexPath.row].threadId ?? "", isFromBubble: false)
        
    }
    
    
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
    
}


extension ConnectionListUserTimelineImageTableViewCell : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        SessionManager.sharedInstance.saveUserCurrentLocationDetails = ["lat":locValue.latitude,"long":locValue.longitude]
        locationManager.stopUpdatingLocation()
    }
    
}
