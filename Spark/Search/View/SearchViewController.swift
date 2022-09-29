//
//  SearchViewController.swift
//  Spark
//
//  Created by adhash on 29/06/21.
//

import UIKit

protocol selectedTagDelegate : AnyObject {
    
    func selectedTagDetails(tagId:String,tagName:String,postType:Int, monetize:Int, NFT:Int)
   
}

/**
 This class is used to search the tags, set the post type and set mnetize or NFT to searxh the posts and set in the feed search page
 */
class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var searchBar:UISearchBar?
    @IBOutlet weak var NoSearchImage: UIImageView!
    @IBOutlet weak var noResultsLbl: UILabel!
    
    let viewModel = TagSearchViewModel()
    var selectedIndex = -1
    var tagId = ""
    var isFromSearch = Bool()
    
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
        apiCallForSearchTagList(text: "", nextPageKey: 1, limit: 1000)
        
        doneButtonKeyboard()
        
    }

    /// Call api to observe and set the tag list 
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
    
    
    /// Setup the search view list with the observer and set the values in collectionview
    func setUpSearchtagListViewModel() {
        
        viewModel.tagSearchModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        
        viewModel.tagSearchModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.data?.tagsList?.count ?? 0 == 0{
                self.NoSearchImage.isHidden = false
                self.noResultsLbl.isHidden = false
                self.collectionView?.isHidden = true
            }
            else{
                self.NoSearchImage.isHidden = true
                self.noResultsLbl.isHidden = true
                self.collectionView?.isHidden = false
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
    
    ///Called when done button tapped and send to the delegate to call the feed search selected tag details method
    @IBAction func doneButtonTapped(sender:UIButton) {
        self.searchBar?.resignFirstResponder()
        if isFromSearch{
            if !(searchBar?.text?.isEmpty ?? false) && selectedIndex >= 0 {
                self.dismiss(animated: true) { [self] in
                    delegate?.selectedTagDetails(tagId: tagId, tagName:searchBar?.text ?? "", postType: 0 , monetize: 0, NFT:0)
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                showErrorAlert(error: "Please choose SparkTag")
            }
            //}
        }
        else{
            if !(searchBar?.text?.isEmpty ?? false) && selectedIndex >= 0 {
                delegate?.selectedTagDetails(tagId: tagId, tagName:searchBar?.text ?? "", postType: 0, monetize: 0, NFT:0 )
                self.navigationController?.popViewController(animated: true)
            } else {
                showErrorAlert(error: "Please choose SparkTag")
            }
        }
        
        
    }
}

extension SearchViewController :
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

        tagId = viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].tagId ?? ""
        searchBar?.text = viewModel.tagSearchModel.value?.data?.tagsList?[indexPath.row].name ?? ""
        
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
/**
 This cell is used set the tags in the search tag page
 */
class trendingTagForSearchFeedCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tagLbl: UILabel!

}

extension SearchViewController : UISearchBarDelegate {
    
    /// Tells the delegate that the user changed the search text.
    /// - Parameters:
    ///   - searchBar: The search bar that is being edited.
    ///   - searchText: The current text in the search text field.
    ///   - This method is also invoked when text is cleared from the search text field.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        selectedIndex = -1
        if searchText.count > 2 {
            apiCallForSearchTagList(text: searchText, nextPageKey: 1, limit: 1000)
        }else if searchText.count == 0 {
            selectedIndex = -1
            self.tagId = ""
            self.searchBar?.text = ""
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
