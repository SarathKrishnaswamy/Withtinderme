//
//  BubbleTagListViewController.swift
//  Spark me
//
//  Created by Gowthaman P on 18/08/21.
//

import UIKit

protocol selectedBubbleTagDelegate : AnyObject {
    
    func selectedTagDetails(tagId:String,tagName:String)
   
}

class BubbleTagListViewController: UIViewController,TagListViewDelegate {
    
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var doneBtn:UIButton?
    @IBOutlet weak var searchBar:UISearchBar?
    
    @IBOutlet weak var dimmedView:UIView!
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var dismissBtn:UIButton!
    
    weak var delegate:selectedBubbleTagDelegate?
    
    var tagName : String?
    var tagID : String?
    var isFromAttachment = Bool()
    
    let maxDimmedAlpha: CGFloat = 0.6
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    // Constants
    let defaultHeight: CGFloat = 200
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = 548//UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 200
    
    let viewModel = BubbleTagListViewModel()
    var tagView:TagView?
    
    var selectedIndex = -1

    var nextPageKey = 1
    var previousPageKey = 1
    let limit = 35
    
    //paginator
    var loadingData = false
    
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissBtn.setTitle("", for: .normal)
//        dismissBtn.setImage(UIImage.init(named: "close"), for: .normal)
        
        searchBar?.backgroundImage = UIImage() //To clear border line from search bar
        
        tagListView.delegate = self
        tagListView.isHidden = true
        
        doneBtn?.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toRight, for: .normal)
        doneBtn?.layer.cornerRadius = 8.0
        doneBtn?.clipsToBounds = true
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        collectionView?.allowsMultipleSelection = true
        collectionView?.isMultipleTouchEnabled = true
        
        //setupPanGesture()
        
        setUpSearchtagListViewModel()
        
        apiCallForBubbleTagList(text: "", PageNumber: 1, PageSize: self.limit, isBoolForHandlingLoadMoreData: false)
      
        doneButtonKeyboard()
        
        
    }
    
    func apiCallForBubbleTagList(text:String,PageNumber:Int,PageSize:Int,isBoolForHandlingLoadMoreData:Bool ) {
        
        let param = [
                        "text" : text,
                        "paginator":[
                            "nextPage": nextPageKey,
                        "pageSize": limit,
                        "pageNumber": 1,
                        "totalPages" : 1,
                        "previousPage" : 1]
            
        ] as [String : Any]
        viewModel.getSearchTagList(postDict: param, isBool: isBoolForHandlingLoadMoreData)
        
    }
    
    func loadMoreData() {
        if !self.loadingData {
            self.loadingData = true
            self.nextPageKey = viewModel.tagSearchModel.value?.data?.paginator?.nextPage ?? 0
            self.apiCallForBubbleTagList(text: "", PageNumber: self.nextPageKey, PageSize: self.limit, isBoolForHandlingLoadMoreData: false)
        }
    }
    func setUpSearchtagListViewModel() {
        
        viewModel.tagSearchModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.tagSearchModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if self.viewModel.tagListData.count > 0 {
                
                
                self.collectionView?.isHidden = false
                self.noDataView.isHidden = true
                self.doneBtn?.isHidden = false

                if self.viewModel.tagSearchModel.value?.data?.paginator?.nextPage ?? 0 > 0 && self.viewModel.tagListData.count > 1 { //Loading
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.loadingData = false

                    }
                }else { //No extra data available
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.loadingData = true
                    }
                }
                
            }else{
                self.noDataView.isHidden = false
                self.collectionView?.isHidden = true
                self.doneBtn?.isHidden = true
            }
        }
    }
  
    
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
    
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
    
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
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
                containerViewHeightConstraint?.constant = newHeight
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
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
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
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        tagListView.isHidden = true
        searchBar?.isUserInteractionEnabled = true
        searchBar?.placeholder = "Search here"
        selectedIndex = -1
        viewModel.tagListData = []
        tagID = ""
        tagName = ""
        apiCallForBubbleTagList(text: "", PageNumber: 1, PageSize: self.limit, isBoolForHandlingLoadMoreData: false)
        collectionView?.reloadData()
        
    }
    
    @IBAction func doneButtonTapped(sender:UIButton){
        
        
        
        
        guard let text = tagID, !text.isEmpty else {
            showErrorAlert(error: "Please select tag.")
            return
        }
        delegate?.selectedTagDetails(tagId: self.tagID ?? "", tagName: self.tagName ?? "")
        dismiss(animated: true) {
        }
    }
    
    @IBAction func dismissButtonTapped(sender:UIButton){
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension BubbleTagListViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.viewModel.tagListData.count
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? bubbleTagListCell
        
        cell?.tagLbl.text = (self.viewModel.tagListData[indexPath.row].tagName)
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
        cell?.bgView.cornerRadius = 6
        cell?.bgView.clipsToBounds = true
        
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

        tagListView.isHidden = false
        tagListView.removeAllTags()
        searchBar?.text = ""
        searchBar?.placeholder = ""
        searchBar?.isUserInteractionEnabled = false
        tagListView.addTag((self.viewModel.tagListData[indexPath.row].tagName ?? "").uppercased())

        tagName = self.viewModel.tagListData[indexPath.row].tagName ?? ""
        tagID = self.viewModel.tagListData[indexPath.row].tagId ?? ""

        selectedIndex = indexPath.row
        self.collectionView?.reloadData()

    }
    
    
    /// cells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == self.viewModel.tagListData.count  - 1 && !loadingData {
            self.loadMoreData()
        }
    }
    
    
    
    /// Asks the delegate for the size of the specified item???s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell???s content.
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 20 , height: 35)
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

        return UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
    }
    
}

extension BubbleTagListViewController : UISearchBarDelegate {
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.nextPageKey = 1
        if searchText.count > 2 {
            searchBar.placeholder = ""
            tagName = searchText
            tagID = ""
            apiCallForBubbleTagList(text: searchText, PageNumber: 1, PageSize: limit, isBoolForHandlingLoadMoreData: true)
        }else if searchText.count == 0 {
            searchBar.placeholder = "Search here"
            apiCallForBubbleTagList(text: searchText, PageNumber: 1, PageSize: limit, isBoolForHandlingLoadMoreData: true)
        }
    }
    
    
    
    /// Ask the delegate if text in a specified range should be replaced with given text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - range: The range of the text to be changed.
    ///   - text: The text to replace existing text in range.
    /// - Returns: true if text in range should be replaced by text, otherwise, false.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`~!@#%^*+={}:;'<>.,?0123456789 "
        
        let newString = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)

        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = newString.components(separatedBy: cs).joined(separator: "")
        
        if newString.count >= 30 {
            showErrorAlert(error: "Please enter less than 30 characters.")
            return false
        }
        return (newString == filtered)
    }
    
    
}

//#MARK: Collectionview Cell Class - Tag Cell
/**
 This class is used to set the search tag for bubble tag set the bubble tag search page
 */
class bubbleTagListCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLbl: UILabel!
    
    @IBOutlet weak var bgView: UIView!

}

