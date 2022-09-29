//
//  SettingsViewController.swift
//  Spark
//
//  Created by adhash on 29/06/21.
//

import UIKit
import MessageUI
import FirebaseDynamicLinks
import RSLoadingView


/**
 This class list out multiple feature to user like Refer and earn, Wallet and history, Support Inbox, Terms of service & Privacy policy, Report a problem, Spark tutorial ,Block user option, Delete account, Log out
 */
class SettingsViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView?
    
    /// Set all the settings menu in the title array
    var titleArray = ["Refer & Earn","Wallet & History","Support Inbox","Terms of Service ","Privacy Policy","Report a Problem","Spark Tutorial","Block User","Delete Account","Logout"]
    
    
    
    /// Set all the image for settings menu in the image array
    var imageArray = ["refer-earn-2","rs","support_inbox","t&c","privacyPolicy","report_problem","tutorial","block_user","trash","logout"]
    
    
    ///Set the view Model to get all the datas
    var viewModel = SettingsViewModel()
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        logOutAPICallObserver()
    }
    
    
    
    
    
    ///Observe the logout api call  here if the status code is 400 it will show the pop up to contact admin
    /// - Logout is success move to spalsh screen and call login page.
    //View Model Setup
    func logOutAPICallObserver() {
        
        viewModel.logOutModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            //self.showErrorAlert(error: error.localizedDescription)
            print(statusHttpCode.statusCode)
            if statusHttpCode.statusCode == 400{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Please contact us at  \(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Contact admin", style: .default) { action in
                        if MFMailComposeViewController.canSendMail() {
                            let mail = MFMailComposeViewController()
                            mail.mailComposeDelegate = self
                            mail.setToRecipients(["\(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")"])
                            mail.setMessageBody("", isHTML: false)
                            self.present(mail, animated: true)
                        } else {
                            // email is not added in app
                        }
                        
                    })
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                       
                    })
                    self.present(alert, animated: true)
                }
       
            }
      
        }
        viewModel.logOutModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if !SessionManager.sharedInstance.getUserId.isEmpty {
                    SocketIOManager.sharedSocketInstance.disconnectSocket()
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    //                    SessionManager.sharedInstance.getUserId = ""
                    //                    SessionManager.sharedInstance.isUserLoggedIn = false
                    //                    SessionManager.sharedInstance.isMobileNumberVerified = false
                    //                    SessionManager.sharedInstance.saveUserDetails = [:]
                    //                    SessionManager.sharedInstance.getTagNameFromFeedDetails = [:]
                    
                    self.resetDefaults()
                    SessionManager.sharedInstance.isUserLoggedIn = false
                    SessionManager.sharedInstance.isContactApprovedOrNot = false
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {

                        appDelegate.updateFirestorePushTokenIfNeeded()
                    }
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let loginVC = storyBoard.instantiateViewController(identifier: "SplashViewController") as! SplashViewController
                    self.navigationController?.pushViewController(loginVC, animated: false)
                    
                })
                
                
               
                
            }
        }
    }
    
  
    ///Removing all values from Userdefaults after user logout
    func resetDefaults() {
        
        //Clear Apple
        //KeychainItem.deleteUserIdentifierFromKeychain()
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }
        
        print(SessionManager.sharedInstance.getUserId)
    }
    
    
    
    /// Using this method we can call the refer and earn method and create a url to share
    func callShareApi(){
        RSLoadingView().showOnKeyWindow()
        let session = URLSession.shared
        let url = Endpoints.user_base.rawValue + Endpoints.generateToken.rawValue
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var params :[String: Any]?
        params = ["username" : SessionManager.sharedInstance.getUserId]
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let statusCode = nsHTTPResponse.statusCode
                    print ("status code = \(statusCode)")
                }
                if let error = error {
                    print ("\(error)")
                }
                if let data = data {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        print ("data = \(jsonResponse)")
                        let decoder = JSONDecoder()
                        
                        let model = try decoder.decode(ShareModel.self, from: data)
                        let token = model.data ?? ""
                        SessionManager.sharedInstance.getApprovalCode = token
                        let url = "https://sparkme.synctag.com/Post/referral/\(token)"
                        DispatchQueue.main.async {
                            RSLoadingView.hideFromKeyWindow()
                            self.createShortUrl(urlString: url)
                        }
                        
                        
                    }catch _ {
                        print ("OOps not good JSON formatted response")
                    }
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
    
    
    
    /// Create a short url and UIActivityViewController is help to share
    func createShortUrl(urlString:String){
        guard let link = URL(string: urlString) else { return }
        let components = DynamicLinkComponents(link: link, domainURIPrefix: "https://sparkme.synctag.com/Post")
        components?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.adhash.spark")
        components?.iOSParameters?.appStoreID = "1578660405"
        components?.iOSParameters?.minimumAppVersion = "1.1.4"
        components?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.adhash.sparkme")
        components?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        components?.socialMetaTagParameters?.title = "Sparkme"
        //components?.socialMetaTagParameters?.descriptionText = FeedDetailsViewModel.instance.feedDetails.value?.data?.postDetails?.postContent
        
        
        

        let options = DynamicLinkComponentsOptions()
        options.pathLength = .short
        components?.options = options
        components?.shorten(completion: { (url, warnings, error) in

            //print(url)
            if let error = error {
                print(error.localizedDescription)
            }
            print(url?.absoluteString)
            //let sharedObjects = [objectsToShare]
                    //self.share_url = url
            let objectstoshare = [url?.absoluteString]
            RSLoadingView.hideFromKeyWindow()
            let activityVC = UIActivityViewController(activityItems: objectstoshare as [Any], applicationActivities: nil)
            activityVC.setValue("Reg: Sparkme Referral", forKey: "Subject")
            activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
            self.present(activityVC, animated: true, completion: nil)
        
        })
        //  print(self.self.share_url)

    }
    
    /// Delete is used delete a user account and after deleted it will logged out.
    func deleteMethod() {
        RSLoadingView().showOnKeyWindow()
        let session = URLSession.shared
        let url = Endpoints.user_base.rawValue + Endpoints.delete.rawValue
        print(url)
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       // var params :[String: Any]?
        //params = ["username" : SessionManager.sharedInstance.getUserId]
        do{
           // request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            let task = session.dataTask(with: request as URLRequest as URLRequest, completionHandler: {(data, response, error) in
                if let response = response {
                    let nsHTTPResponse = response as! HTTPURLResponse
                    let statusCode = nsHTTPResponse.statusCode
                    print ("status code = \(statusCode)")
                }
                if let error = error {
                    print ("\(error)")
                }
                if let data = data {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                        print ("data = \(jsonResponse)")
                        let decoder = JSONDecoder()
                        
                        let model = try decoder.decode(ShareModel.self, from: data)
                        print(model)
//                        let token = model.data ?? ""
//                        SessionManager.sharedInstance.getApprovalCode = token
//                        let url = "https://sparkme.synctag.com/Post/referral/\(token)"
                        DispatchQueue.main.async {
                            RSLoadingView.hideFromKeyWindow()
                           // self.createShortUrl(urlString: url)
                        }
                        
                        
                    }catch _ {
                        print ("OOps not good JSON formatted response")
                    }
                }
            })
            task.resume()
        }catch _ {
            print ("Oops something happened buddy")
        }
    }
    

    
    
   
    
}

extension SettingsViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titleArray.count
    }
    
    
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SettingsTableViewCell
        else { preconditionFailure("Failed to load collection view cell") }
        
        cell.titlelbl.text = titleArray[indexPath.row]
        if indexPath.row == 1{
            if SessionManager.sharedInstance.saveCountryCode == "+91"{
                cell.imgView.image = UIImage(named: "rs")
                cell.imgView.alpha = 0.7
            }
            else{
                cell.imgView.image = UIImage(named: "dollar")
                cell.imgView.alpha = 0.7
            }
            
        }
        else if indexPath.row == 8{
            cell.imgView.image = UIImage(systemName: "trash")
            cell.imgView.tintColor = UIColor(hexString: "#3B426D")
        }
        else{
            cell.imgView.image = UIImage.init(named: imageArray[indexPath.row])
        }
        
        
        return cell
    }
    
    
    
    
    
    /// Asks the delegate for the height to use for a row in a specified location.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - indexPath: An index path that locates a row in tableView.
    /// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
    ///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 8{
            if SessionManager.sharedInstance.settingData?.data?.versionInfo?.isDelete == 1{
                return 65
            }
            else{
                return 0
            }
        }
        else{
            return 65
        }
       
    }
    
    
    
    
    ///It will show the alert as action sheet to logoout confirmation
    fileprivate func logoutAPICall() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            
            self.viewModel.logOutAPICall()
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    
    
    /// It will show the alert as action sheet to Delete Api confirmation
    fileprivate func DeleteAPICall() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your spark account?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            //let params = ["token":SessionManager.sharedInstance.getAccessToken]
            self.logOutAPICallObserver()
            self.viewModel.deleteApiCall()
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    
    /// It will show the alert as action sheet to sparkTutorial confirmation
    fileprivate func sparkTutorialCall() {
        let alert = UIAlertController(title: "Spark Tutorial", message: "Are you sure you want to start the spark tutorial?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            
            SessionManager.sharedInstance.isProfileUpdatedOrNot = false
            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = false
            SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = false
            SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = false
            
            self.tabBarController?.selectedIndex = 0
            SessionManager.sharedInstance.selectedIndexTabbar = 0
            NotificationCenter.default.post(name: Notification.Name("fromSettings"), object: ["index":0])
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    
    
    
    
    /// Tells the delegate a row is selected.
    /// - Parameters:
    ///   - tableView: A table view informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    ///   The delegate handles selections in this method. For instance, you can use this method to assign a checkmark (UITableViewCell.AccessoryType.checkmark) to one row in a section in order to create a radio-list style. The system doesn’t call this method if the rows in the table aren’t selectable. See Handling row selection in a table view for more information on controlling table row selection behavior.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if SessionManager.sharedInstance.getApprovalCode.isEmpty == true{
                callShareApi()
            }
            else{
                let url = "https://sparkme.synctag.com/Post/referral/\(SessionManager.sharedInstance.getApprovalCode)"
                createShortUrl(urlString: url)
            }
           
//            self.shareApiCallObserver()
//            viewModel.shareApiCall(params: ["username":SessionManager.sharedInstance.getUserId])
            
        }
        else if indexPath.row == 1{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Thread", bundle: nil)
            let paymentVC = storyBoard.instantiateViewController(identifier: "PaymentHistoryViewController") as! PaymentHistoryViewController
            paymentVC.isFromSettings = true
            self.navigationController?.pushViewController(paymentVC, animated: true)
        }
        
       
        else if indexPath.row == 2 {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.ChatURL ?? ""
            webViewVC.titleStr = "Support Inbox"
            self.navigationController?.pushViewController(webViewVC, animated: true)
        }
        else if indexPath.row == 3 {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.TermsURL ?? ""
            webViewVC.titleStr = "Terms of Service "
            self.navigationController?.pushViewController(webViewVC, animated: true)
        }
        else if indexPath.row == 4 {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.PrivacyURL ?? ""
            webViewVC.titleStr = "Privacy Policy"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        }else if indexPath.row == 5 {
            sendEmail(mailId: SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "", message: "Dear Sparkme Team")
        }
        else if indexPath.row == 6{
            sparkTutorialCall()
        }
        else if indexPath.row == 7 {
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let blockedListVC = storyBoard.instantiateViewController(identifier: "BlockedUserListViewController") as! BlockedUserListViewController
            self.navigationController?.pushViewController(blockedListVC, animated: true)
        }
        else if indexPath.row == 8{
            
            self.DeleteAPICall()
        }
        else {
            
            logoutAPICall()
        }
        
    }
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
   
    
    /// Send the email using this method
    /// - Parameters:
    ///   - mailId: Pass the email id here
    ///   - message: Pass the message what ever required here
    func sendEmail(mailId:String,message:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([mailId])
            mail.setSubject("Reg: Sparkme Application Support")
            mail.setMessageBody("<p>\(message)</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    
    
    /// Dimiss the mail composer
    /// - Parameters:
    ///   - controller: Current vc
    ///   - result: dismiss the controller
    ///   - error: If any error throws it will shown in error
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
