//
//  SearchTagFeedViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 23/06/22.
//

import UIKit
import LabelSwitch
import CoreLocation



/**
This class helps to listing post but post listed based on user selection user have multiple selection option like global, closed, social, local, nft, monetize and tag
 */
class SearchTagFeedViewController: UIViewController,LabelSwitchDelegate {
    
    
    /// This switch state is used to set the switch
    /// - Parameter sender: Sender is used to set the multiple label switch
    func switchChangToState(sender: LabelSwitch) {
        if sender == monetizeSwitch{
            switch sender.curState {
            case .L:
                print("left")
                monetize = 0
                print(monetize)
            case .R:
                print("right")
                monetize = 1
                print(monetize)
            }
        }
        else{
            switch sender.curState {
            case .L:
                print("left")
                nft = 0
                print(nft)
            case .R:
                print("right")
                nft = 1
                print(nft)
            }
        }
            
    }
    
    
    
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var NoSearchImage: UIImageView!
    @IBOutlet weak var noResultsLbl: UILabel!
    
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var localBtn: UIButton!
    @IBOutlet weak var socialBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var monetizeSwitch: LabelSwitch!
    @IBOutlet weak var nftSwitch: LabelSwitch!
    
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var closedView: UIView!
    
    @IBOutlet weak var globalIcon: UIImageView!
    @IBOutlet weak var localIcon: UIImageView!
    @IBOutlet weak var socialIcon: UIImageView!
    @IBOutlet weak var closedIcon: UIImageView!
    
    @IBOutlet weak var globalLbl: UILabel!
    @IBOutlet weak var localLbl: UILabel!
    @IBOutlet weak var socialLbl: UILabel!
    @IBOutlet weak var closedLbl: UILabel!
    
    @IBOutlet weak var trndingSparkLbl: UILabel!
    
    let viewModel = TagSearchViewModel()
    var selectedIndex = -1
    var tagId = ""
    var SearchTag = ""
    var isFromSearch = Bool()
    var postType = 0
    var monetize = 0
    var nft = 0
    var selectTag = false
    var selectedTag = ""
    var postSelected = false
    
    
    
    weak var delegate:selectedTagDelegate?


    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        //searchBar?.searchTextField.clearButtonMode = .never
        self.NoSearchImage.isHidden = true
        self.noResultsLbl.isHidden = true

        searchBar?.backgroundImage = UIImage() //To clear border line from search bar
        searchBar?.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font : UIFont.getMontserratBlack(.small)], for: .normal)
        setUpSearchtagListViewModel()
        self.searchBar?.text = SearchTag
        
        if SearchTag == ""{
            self.selectTag = false
            apiCallForSearchTagList(text: "", nextPageKey: 1, limit: 1000)
        }
        else{
            self.selectTag = true
            apiCallForSearchTagList(text: SearchTag, nextPageKey: 1, limit: 1000)
            
        }
        
        
        doneButtonKeyboard()
        monetizeSwitch.delegate = self
        monetizeSwitch.circleShadow = false
        monetizeSwitch.fullSizeTapEnabled = true
        
        if SessionManager.sharedInstance.saveCountryCode == "+91"{
            let ls = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
            let rs = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray )
            monetizeSwitch.setConfig(left: ls, right: rs)
            
        }
        else if SessionManager.sharedInstance.saveCountryCode == ""{
            let ls = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
            let rs = LabelSwitchConfig(text: "₹", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray)
            monetizeSwitch.setConfig(left: ls, right: rs)
            
        }
        else{
            let ls = LabelSwitchConfig(text: "$", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: UIColor(hexString: "#368082"))
            let rs = LabelSwitchConfig(text: "$", textColor: .white, font: .systemFont(ofSize: 15), backgroundColor: .lightGray)
            monetizeSwitch.setConfig(left: ls, right: rs)
           
        }
        
        if monetize == 1{
            monetizeSwitch.curState = .R
        }
        else{
            monetizeSwitch.curState = .L
        }
        
       
        nftSwitch.delegate = self
        nftSwitch.circleShadow = false
        nftSwitch.fullSizeTapEnabled = true
        
        if nft == 1{
            nftSwitch.curState = .R
        }
        else{
            nftSwitch.curState = .L
        }
        
        
        
        
        
        self.resetBtn()
        if postType == 1{
            globalSelected()
            postSelected = true
        }
        else if postType == 2{
            localSelected()
            postSelected = true
        }
        else if postType == 3{
            socialSelected()
            postSelected = true
        }
        else if postType == 4{
            closedSelected()
            postSelected = true
        }
        
        
    }

    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        self.selectTag = false
    }
    
    
    
    /**
     Get the api call for searh list tag
     - Parameters:
     - text: Pass the text from search bar
     - nextPageKey: set the next page key as Int
     - limit: set the limit to set in the cvurrent page
     */
    func apiCallForSearchTagList(text:String,nextPageKey:Int, limit:Int ) {
        
        let closedConnectionDict = [
                        "text" : text,
                        "paginator":[
                            "nextPage": nextPageKey,
                        "pageSize": limit,
                        "pageNumber": 1,
                        "totalPages" : 1,
                        "previousPage" : 1]
            
        ] as [String : Any]
        
        viewModel.getSearchTagListNoLoading(postDict: closedConnectionDict, isBool: false)
        
    }
    
    
    /// Select the global button
    func globalSelected(){
        self.globalView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        self.globalLbl.textColor = .white
        self.globalIcon.image = UIImage(named: "global")
        self.globalView.layer.borderWidth = 0.0
        self.postType = 1
    }
    
    
    /// Select the local button with location manager with permission and determined, denied and restricted.
    func localSelected(){
        
        let locationManager = CLLocationManager()
        
        //            if CLLocationManager.locationServicesEnabled() {
        
        if #available(iOS 14.0, *) {
            
            switch locationManager.authorizationStatus {
                
            case .notDetermined, .restricted, .denied:
                print("No access")
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
                        //self.globalSelected()
                        self.postSelected = false
                        UIApplication.shared.open(settings)
                    })
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                   // self.globalSelected()
                    self.postSelected = false
                })
                self.present(alert, animated: true)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                self.localView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.localView.frame.width, height: self.localView.frame.height))
                self.localLbl.textColor = .white
                self.localIcon.image = UIImage(named: "local")
                self.localView.layer.borderWidth = 0.0
                self.postType = 2
                
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                
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
                       // self.globalSelected()
                        self.postSelected = false
                        UIApplication.shared.open(settings)
                    })
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    //self.globalSelected()
                    self.postSelected = false
                })
                self.present(alert, animated: true)
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                
                self.localView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.localView.frame.width, height: self.localView.frame.height))
                self.localLbl.textColor = .white
                self.localIcon.image = UIImage(named: "local")
                self.localView.layer.borderWidth = 0.0
                self.postType = 2
                
            @unknown default:
                break
            }
            
        }
        
        
        
       
    }
    
    
    
    /// Select the social button selected
    func socialSelected(){
        self.socialView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.socialView.frame.width, height: self.socialView.frame.height))
        self.socialLbl.textColor = .white
        self.socialIcon.image = UIImage(named: "social")
        self.socialView.layer.borderWidth = 0.0
        self.postType = 3
    }
    
    /// Select the closed button selected
    func closedSelected(){
        self.closedView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.closedView.frame.width, height: self.closedView.frame.height))
        self.closedLbl.textColor = .white
        self.closedIcon.image = UIImage(named: "closed")
        self.closedView.layer.borderWidth = 0.0
        self.postType = 4
    }
    
    
    /// Reset all button to old state without highlighted
    func resetBtn(){
        
        globalView.backgroundColor = linearGradientColor(from: [.white,.white], locations: [0,0], size: CGSize(width: self.globalView.frame.width, height: self.globalView.frame.height))
        localView.backgroundColor = linearGradientColor(from: [.white,.white], locations: [0,0], size: CGSize(width: self.localView.frame.width, height: self.globalView.frame.height))
        socialView.backgroundColor = linearGradientColor(from: [.white,.white], locations: [0,0], size: CGSize(width: self.socialView.frame.width, height: self.socialView.frame.height))
        closedView.backgroundColor = linearGradientColor(from: [.white,.white], locations: [0,0], size: CGSize(width: self.closedView.frame.width, height: self.closedView.frame.height))
        
        globalView.layer.masksToBounds = true
        localView.layer.masksToBounds = true
        socialView.layer.masksToBounds = true
        closedView.layer.masksToBounds = true
        
        globalView.layer.borderColor = UIColor.lightGray.cgColor
        localView.layer.borderColor = UIColor.lightGray.cgColor
        socialView.layer.borderColor = UIColor.lightGray.cgColor
        closedView.layer.borderColor = UIColor.lightGray.cgColor
        
        globalView.layer.borderWidth = 1.0
        localView.layer.borderWidth = 1.0
        socialView.layer.borderWidth = 1.0
        closedView.layer.borderWidth = 1.0
        
        globalView.layer.cornerRadius = 3.0
        localView.layer.cornerRadius = 3.0
        socialView.layer.cornerRadius = 3.0
        closedView.layer.cornerRadius = 3.0
        
        globalLbl.textColor = .lightGray
        localLbl.textColor = .lightGray
        socialLbl.textColor = .lightGray
        closedLbl.textColor = .lightGray
        
        
        globalIcon.image = UIImage(named: "globalGray")
        localIcon.image = UIImage(named: "localGray")
        socialIcon.image = UIImage(named: "SocialGray")
        closedIcon.image = UIImage(named: "closedGray")
        
        
        
        globalView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        localView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        socialView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        closedView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
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
    
    
    /**
    
     Setup the search tag with observe value from tag search model api to set in the collectionview
     */
    func setUpSearchtagListViewModel() {
        
        viewModel.tagSearchModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        viewModel.tagSearchModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.data?.tagsList?.count ?? 0 == 0 || self.viewModel.tagSearchModel.value?.data?.tagsList?.count ?? 0 == 0{
                self.NoSearchImage.isHidden = false
                self.noResultsLbl.isHidden = false
                self.collectionView?.isHidden = true
                self.trndingSparkLbl.isHidden = true
            }
            else{
                self.NoSearchImage.isHidden = true
                self.noResultsLbl.isHidden = true
                self.collectionView?.isHidden = false
                self.trndingSparkLbl.isHidden = false
                if let values = value.isOk, values {
                    
                    DispatchQueue.main.async {
                        
                        self.collectionView?.reloadData()
                    }
                }
            }
            
        }
    }
    
    ///Called when back button tapped
    @IBAction func backButtonTapped(sender:UIButton) {
        //tabBarController?.selectedIndex = 0
        if isFromSearch{
            self.dismiss(animated: true)
        }
        else{
        self.navigationController?.popViewController(animated: true)
        }
    }
    
    ///Called when done button tapped
    @IBAction func doneButtonTapped(sender:UIButton) {
        self.searchBar?.resignFirstResponder()
        if isFromSearch{
           //if selectedIndex >= 0 {
            if self.postSelected{
                self.dismiss(animated: true) { [self] in
                    delegate?.selectedTagDetails(tagId: tagId, tagName:self.selectedTag, postType: postType, monetize: monetize, NFT:nft )
                }
                self.navigationController?.popViewController(animated: true)
                
            } else {
                showErrorAlert(error: "Please choose Spark type")
            }
            //}
        }
        else{
            //if !(searchBar?.text?.isEmpty ?? false) && selectedIndex >= 0 {
                delegate?.selectedTagDetails(tagId: tagId, tagName:searchBar?.text ?? "", postType: postType, monetize: monetize, NFT:nft  )
                self.navigationController?.popViewController(animated: true)
//            } else {
//                showErrorAlert(error: "Please choose SparkTag")
//            }
        }
        
        
    }
    
    
    
    /// On Clicking on global button select global and reset all other button
    @IBAction func globalBtnOnPressed(_ sender: Any) {
        resetBtn()
        globalSelected()
        postSelected = true
        
    
    }
    
   
    /// On clicking on local button select local and reset all other button
    @IBAction func localBtnOnPressed(_ sender: Any) {
        resetBtn()
        localSelected()
        postSelected = true
    }
    
    
    /// On clicking on social button select local and reset all other button
    @IBAction func socialBtnOnPressed(_ sender: Any) {
        resetBtn()
        socialSelected()
        postSelected = true
    }
    
    
    /// On clicking on closed button select local and reset all other button
    @IBAction func closedBtnOnPressed(_ sender: Any) {
        resetBtn()
        closedSelected()
        postSelected = true
    }
    
    
}

extension SearchTagFeedViewController :
    UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.tagSearchModel.value?.data?.tagsList?.count ?? 0
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingTagForSearchFeedCell", for: indexPath as IndexPath) as? trendingTagForSearchFeedCell
        
        if viewModel.tagSearchModel.value?.data?.tagsList?.count ?? 0 > 0{
            cell?.tagLbl.text = (viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].name)
            cell?.contentView.layer.cornerRadius = 5.0
            cell?.contentView.clipsToBounds = true
            
            let gradient = CAGradientLayer()
            if selectedIndex == indexPath.item
            {
                cell?.bgView.backgroundColor = linearGradientColor(
                    from: [.splashStartColor, .splashEndColor],
                    locations: [0.0, 1.0],
                    size: CGSize(width: 60, height:60)
                )
                
               
    //            cell?.bgView.backgroundColor = UIColor.splashStartColor
                cell?.tagLbl.textColor = UIColor.white
            }
            else
            {
                gradient.removeFromSuperlayer()
                cell?.bgView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
                cell?.tagLbl.textColor = #colorLiteral(red: 0.5019607843, green: 0.5333333333, blue: 0.568627451, alpha: 1)
            }
            
    //        if selectTag{
                if tagId == viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].tagId ?? ""{
                    cell?.bgView.backgroundColor = linearGradientColor(
                        from: [.splashStartColor, .splashEndColor],
                        locations: [0.0, 1.0],
                        size: CGSize(width: 60, height:60)
                    )
                    self.selectedTag = (viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].name ?? "")


        //            cell?.bgView.backgroundColor = UIColor.splashStartColor
                    cell?.tagLbl.textColor = UIColor.white
                }
            //}
    //        else{
    //            gradient.removeFromSuperlayer()
    //            cell?.bgView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
    //            cell?.tagLbl.textColor = #colorLiteral(red: 0.5019607843, green: 0.5333333333, blue: 0.568627451, alpha: 1)
    //        }
            
            cell?.bgView.cornerRadius = 6
            cell?.bgView.clipsToBounds = true
        }
       
        
       
        
        return cell ?? UICollectionViewCell()
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
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        tagId = viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].tagId ?? ""
        searchBar?.text = viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].name ?? ""
        self.selectedTag = viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].name ?? ""
        selectedIndex = indexPath.row
        self.collectionView?.reloadData()

    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 10 , height: 35)
    }

    
    /// Asks the delegate for the spacing between successive rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose line spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive lines in a section.
    ///  - If you do not implement this method, the flow layout uses the value in its minimumLineSpacing property to set the space between lines instead. Your implementation of this method can return a fixed value or return different spacing values for each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    
    
    
    /// Asks the delegate for the spacing between successive items in the rows or columns of a section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose inter-item spacing is needed.
    /// - Returns: The minimum space (measured in points) to apply between successive items in the lines of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    
    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        return UIEdgeInsets(top: 5,left: 2,bottom: 5,right: 2)
    }
}

//#MARK: Collectionview Cell Class - Tag Cell
//class trendingTagForSearchFeedCell: UICollectionViewCell {
//
//    @IBOutlet weak var bgView: UIView!
//    @IBOutlet weak var tagLbl: UILabel!
//
//}

extension SearchTagFeedViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        selectedIndex = -1
        if searchText.count > 2 {
            self.setUpSearchtagListViewModel()
            apiCallForSearchTagList(text: searchText, nextPageKey: 1, limit: 1000)
        }else if searchText.count == 0 {
            self.selectTag = false
            self.tagId = ""
            self.setUpSearchtagListViewModel()
            apiCallForSearchTagList(text: searchText, nextPageKey: 1, limit: 1000)

        }
    }
    
    
    
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newString = (searchBar.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`~!@#$%^&*_+={}:;'<>.,?/0123456789 "
        
        let new_String = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)

        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = new_String.components(separatedBy: cs).joined(separator: "")
        
        if filtered.count >= 12 {
            showErrorAlert(error: "Please enter less than 12 characters.")
            return false
        }
        return (new_String == filtered) && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0

    }
}
