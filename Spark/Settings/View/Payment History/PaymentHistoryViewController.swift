//
//  PaymentHistoryViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import UIKit
import SDWebImage

/**
 This class shows particular users monetize Wallet history and monetize payment history
 */

class PaymentHistoryViewController: UIViewController {

    @IBOutlet weak var paidToBtn: UIButton!
    @IBOutlet weak var receivedFromBtn: UIButton!
    @IBOutlet weak var totalEarningsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataFound: UILabel!
    @IBOutlet weak var totalEarningPrice: UILabel!
    @IBOutlet weak var amountReceivedStackView: UIStackView!
    @IBOutlet weak var amountReceivedLbl: UILabel!
    @IBOutlet weak var totalearningsBgView: UIView!
    @IBOutlet weak var amountreceivedBgView: UIView!
   // @IBOutlet weak var Line: UILabel!
    
    
    var selectedButton: UIButton? = nil
    let viewModel = PaymentHistoryViewModel()
    var limit = 10
    var nextPageKey = 1
    var previousPage = 1
    var loadingData = false
    var type = 2
    var totalPages = 1
    var isFromSettings = false
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bgView.backgroundColor = .clear
        self.totalearningsBgView.layer.cornerRadius = 4.0
        self.amountreceivedBgView.layer.cornerRadius = 4.0
        
        //self.bgView.backgroundColor = linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.bgView.frame.width, height: self.bgView.frame.height))
        self.bgView.layer.masksToBounds = true
        self.bgView.layer.cornerRadius = 6.0
        updateButtonSelection(paidToBtn ?? UIButton())
        self.setUpPaymentViewModel()
        self.apiCall(type: type)
        //self.amountReceivedStackView.isHidden = true
        self.totalEarningsViewHeight.constant = 0
    }
    
    
    ///Api call to check the payments list or wallet list
    func apiCall(type:Int) {
        let bubbleDict = [
            "type":type,
            "paginator":[
                "nextPage": nextPageKey,
                "pageNumber": 1,
                "pageSize": limit,
                "previousPage": previousPage,
                "totalPages": totalPages
            ]
            
        ] as [String : Any]
        viewModel.paymentPaidListApiCall(postDict: bubbleDict)
    }
    
    
    
    /// Observe the api values to set the payment list values or wallet list values.
    ///  - List all the values in the table view with the status Pending, Success.
    func setUpPaymentViewModel() {
        viewModel.paymentModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.paymentModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            print(value)
            
            if value.isOk ?? false{
                
                if self.viewModel.paymentListData.count > 0{
                    self.noDataFound.isHidden = true
                    self.noDataImage.isHidden = true
                    self.tableView.isHidden = false
                    
                    if self.viewModel.paymentModel.value?.data?.totalAmount == "0"{
                        self.totalEarningsViewHeight.constant = 0

                    }
                    else{
                        self.totalEarningsViewHeight.constant = 100
                        if SessionManager.sharedInstance.saveCountryCode == "+91"{
                            self.totalEarningPrice.text = "₹\(self.viewModel.paymentModel.value?.data?.totalAmount ?? "")"
                            self.amountReceivedLbl.text = "₹\(self.viewModel.paymentModel.value?.data?.amountTransferred ?? "")"
                            if self.viewModel.paymentModel.value?.data?.amountTransferred ?? "" == "0" || self.viewModel.paymentModel.value?.data?.amountTransferred ?? "" == ""{
                                self.amountreceivedBgView.isHidden = true
                                self.totalearningsBgView.backgroundColor = .clear
                                self.amountreceivedBgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.amountreceivedBgView.frame.width, height: self.amountreceivedBgView.frame.height))
                                self.bgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.bgView.frame.width, height: self.bgView.frame.height))
                                //self.totalearningsBgView.backgroundColor = .clear
                            }
                            else{
                                self.totalearningsBgView.isHidden = false
                                self.amountreceivedBgView.isHidden = false
                                self.totalearningsBgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.totalearningsBgView.frame.width, height: self.totalearningsBgView.frame.height))
                                self.bgView.backgroundColor = .clear
                                self.amountreceivedBgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.amountreceivedBgView.frame.width, height: self.amountreceivedBgView.frame.height))
                                
                            }
                            
                        }
                        else{
                            self.totalEarningPrice.text = "$\(self.viewModel.paymentModel.value?.data?.totalAmount ?? "")"
                            self.amountReceivedLbl.text = "$\(self.viewModel.paymentModel.value?.data?.amountTransferred ?? "")"
                            if self.viewModel.paymentModel.value?.data?.amountTransferred ?? "" == "0" || self.viewModel.paymentModel.value?.data?.amountTransferred ?? "" == ""{
                                self.amountreceivedBgView.isHidden = true
                                self.totalearningsBgView.backgroundColor = .clear
                                self.bgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.bgView.frame.width, height: self.bgView.frame.height))
                                //self.totalearningsBgView.backgroundColor = .clear
                            }
                            else{
                                self.amountreceivedBgView.isHidden = false
                                self.totalearningsBgView.isHidden = false
                                self.totalearningsBgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.totalearningsBgView.frame.width, height: self.totalearningsBgView.frame.height))
                                self.bgView.backgroundColor = .clear
                                self.amountreceivedBgView.backgroundColor = self.linearGradientColor(from: [UIColor.splashStartColor, UIColor.splashEndColor], locations: [0,1], size: CGSize(width: self.amountreceivedBgView.frame.width, height: self.amountreceivedBgView.frame.height))
                            }
                        }
                       
                    }
                    
                    if self.viewModel.paymentModel.value?.data?.paginator?.nextPage ?? 0 > 0{
                        self.loadingData = false
                    }
                    else{
                        self.loadingData = true
                    }
                    self.tableView.reloadData()
                }
                else{
                    self.noDataFound.isHidden = false
                    self.noDataImage.isHidden = false
                    self.tableView.isHidden = true
                }
            }
            
        }
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
    
    @IBAction func backBtnOnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    ///Segment button is to select the button payment or wallet.
    /// - If type 1 it will call the wallet page.
    /// - If type 2  it will call the payements page.
    @IBAction func segmentBtnOnPressed(_ sender: UIButton) {
        
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
        if sender.tag == 0{
            self.totalEarningsViewHeight.constant = 0
            self.type = 2
            self.nextPageKey = 1
            self.apiCall(type: 2)
            self.viewModel.paymentListData = []
            self.tableView.reloadData()
            
            
            
            
        }
        
        else if sender.tag == 1{
            self.totalEarningsViewHeight.constant = 100
            self.type = 1
            self.nextPageKey = 1
            self.viewModel.paymentListData = []
            self.apiCall(type: 1)
            
            
        }
    }
    
    
    
    /// Update the button selection
    func updateButtonSelection(_ sender: UIButton){
        selectedButton = sender
        selectedButton?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        selectedButton?.layer.borderColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
        selectedButton?.layer.borderWidth = 0.5
        selectedButton?.layer.cornerRadius = 6
        selectedButton?.layer.masksToBounds = true
        selectedButton?.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    /// Load more is used for pagination 
    func loadmore(){
        if !self.loadingData  {
            self.loadingData = true
            self.nextPageKey = self.viewModel.paymentModel.value?.data?.paginator?.nextPage ?? 0
            self.apiCall(type: type)
        }
    }

}


extension PaymentHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.paymentListData.count
    }
    
    
    
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaidToTableViewCell", for: indexPath) as! PaidToTableViewCell
        
        if type == 2{
            
            cell.statusView.isHidden = false
            cell.paidToOrReceivedLbl.text = "Paid to"
            if viewModel.paymentListData[indexPath.row].status == 2{
                cell.statusView.backgroundColor = .systemYellow
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .black
            }
            else if viewModel.paymentListData[indexPath.row].status == 3{
                cell.statusView.backgroundColor = .systemGreen
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .white
                
            }
            else if viewModel.paymentListData[indexPath.row].status == 4{
                cell.statusView.backgroundColor = .systemBrown
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .white
                
            }
            else if viewModel.paymentListData[indexPath.row].status == 5{
                cell.statusView.backgroundColor = .systemOrange
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .white
                
            }
            cell.priceLbl.textColor = .black
            cell.priceLbl.text = "\(self.viewModel.paymentListData[indexPath.row].currencySymbol ?? "")\(self.viewModel.paymentListData[indexPath.row].amount ?? 0)"
            let profilePic = viewModel.paymentListData[indexPath.row].userImage ?? ""
            let gender = viewModel.paymentListData[indexPath.row].gender ?? 0
            let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(profilePic)"
            cell.paidTopersonLbl.text = viewModel.paymentListData[indexPath.row].userName ?? ""
            cell.profileImage.setImage(
               url: URL.init(string: url) ?? URL(fileURLWithPath: ""),
               placeholder: #imageLiteral(resourceName: gender == 1 ?  "no_profile_image_male" : gender == 2 ? "no_profile_image_female" : "others"))
            
        }
        else{
            cell.paidToOrReceivedLbl.text = "Received From"
            if viewModel.paymentListData[indexPath.row].status == 2{
                cell.statusView.backgroundColor = .systemYellow
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .black
            }
            else if viewModel.paymentListData[indexPath.row].status == 3{
                cell.statusView.backgroundColor = .systemGreen
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .white
                
            }
            else if viewModel.paymentListData[indexPath.row].status == 6{
                cell.statusView.backgroundColor = .systemGreen
                cell.statusLbl.text = viewModel.paymentListData[indexPath.row].statusDesc ?? ""
                cell.statusLbl.textColor = .white
            }
            
            cell.priceLbl.textColor = .systemGreen
            cell.priceLbl.text = "\(self.viewModel.paymentListData[indexPath.row].currencySymbol ?? "")\(self.viewModel.paymentListData[indexPath.row].amount ?? 0)"
            cell.profileImage.image = UIImage(named: "spark_title_logo")
            cell.paidTopersonLbl.text = "Spark me"
        }
        
        
        let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(viewModel.paymentListData[indexPath.row].createdDate ?? 0)")
        cell.hoursLbl.text = convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
        
        
        return cell
    }
    
    
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == 1{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentBreakupViewController") as! PaymentBreakupViewController
            vc.postId = self.viewModel.paymentListData[indexPath.row].basePostId ?? ""
            vc.userId = self.viewModel.paymentListData[indexPath.row].userId ?? ""
            vc.type = type
            vc.isFromSettings = isFromSettings
            vc.transactionId = self.viewModel.paymentListData[indexPath.row].transactionId ?? ""
            vc.paymentMethod = self.viewModel.paymentListData[indexPath.row].paymentMethod ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "PaymentBreakupViewController") as! PaymentBreakupViewController
            vc.postId = self.viewModel.paymentListData[indexPath.row].basePostId ?? ""
            vc.type = type
            vc.isFromSettings = isFromSettings
            vc.userId = self.viewModel.paymentListData[indexPath.row].userId ?? ""
            vc.transactionId = self.viewModel.paymentListData[indexPath.row].transactionId ?? ""
            vc.paymentMethod = self.viewModel.paymentListData[indexPath.row].paymentMethod ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    /// - Parameters:
    ///   - tableView: The table view informing the delegate of this impending event.
    ///   - cell: A cell that tableView is going to use when drawing the row.
    ///   - indexPath: An index path locating the row in tableView.
    ///   - A table view sends this message to its delegate just before it uses cell to draw a row, thereby permitting the delegate to customize the cell object before it is displayed. This method gives the delegate a chance to override state-based properties set earlier by the table view, such as selection and background color. After the delegate returns, the table view sets only the alpha and frame properties, and then only when animating rows as they slide in or out.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = indexPath.item
        if lastItem == self.viewModel.paymentListData.count - 1 && !loadingData{
            self.loadmore()
        }
        
    }
    
   
    
}
