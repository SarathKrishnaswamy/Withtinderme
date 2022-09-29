//
//  WaitingViewController.swift
//  Spark me
//
//  Created by adhash on 02/09/21.
//

import UIKit
import Contacts
import Lottie
import RAMAnimatedTabBarController

class WaitingViewController: UIViewController {

    let viewModel = WaitingViewModel()
    
    var contacts = [[String:Any]]()
    
    var telePhoneNumbers = [String]()
    var linkApprovalCode = String()
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var approvalCodeTxtFld:UITextField?
    @IBOutlet var continueBtn:UIButton?
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpFetchContactsViewModel()
        setupContactSyncObserver()
        setupApproveStatusObserver()
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

           switch authorizationStatus {
           case .authorized:
               print("contact access granded")
               
               viewModel.contactSyncAPICall()
             
               //SessionManager.sharedInstance.settingData?.data?.versionInfo.app
               
               self.fetchContacts()

           case .denied, .notDetermined:
               print("contact access denied")
               DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                   let alert = UIAlertController(title: "Contact Permission", message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
                   
                   //to change font of title and message.
                   let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                   let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                   
                   let titleAttrString = NSMutableAttributedString(string: "Contact Permission", attributes: titleFont)
                   let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to Contacts to proceed. Go to Settings to grant access.\n", attributes: messageFont)
                   
                   alert.setValue(titleAttrString, forKey: "attributedTitle")
                   alert.setValue(messageAttrString, forKey: "attributedMessage")
                      
                   if let settings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settings) {
                               alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in

                                   UIApplication.shared.open(settings)
                               })
                       }
                       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in

                       })
                   self.present(alert, animated: true)
               }
               
           default:
               break
           }
        

        // Do any additional setup after loading the view.
        
        
        //doneButtonKeyboard()
        
        continueBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toLeft, for: .normal)
        continueBtn?.layer.cornerRadius = 10.0
        continueBtn?.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        print(SessionManager.sharedInstance.isContactSyncedOrNot)
        print(SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApproval)
        print(self.linkApprovalCode)
        
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    //Setup Login Model
    func setUpFetchContactsViewModel() {
        
        viewModel.waitingModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.waitingModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            SessionManager.sharedInstance.isContactApprovedOrNot = value.data?.isApproved ?? false
            SessionManager.sharedInstance.isContactSyncedOrNot = value.data?.isSyncContact ?? false
            print(SessionManager.sharedInstance.isContactApprovedOrNot)
            print("1")
            print(SessionManager.sharedInstance.isContactSyncedOrNot)
            
            if !(value.data?.isSyncContact ?? false) {
                
                // contact sync
                self.viewModel.contactSync(postDict: ["contactInfo":self.contacts])
                
            } else if value.data?.isApproved ?? false {
                
                // Redirected to home
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
            else if value.data?.isSyncContact ?? false{
                if !SessionManager.sharedInstance.linkApprovalCode.isEmpty{
                    self.approvalCodeTxtFld?.isHidden = true
                    self.continueBtn?.isHidden = true
                    self.titleLbl.text = "Yay! You're Almost There!"
                    self.viewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.linkApprovalCode ])
                }
                else{
                    if SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApproval == 0{
                        self.approvalCodeTxtFld?.isHidden = true
                        self.continueBtn?.isHidden = true
                        self.titleLbl.text = "Yay! You're Almost There!"
                        self.viewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApprovalCode ?? ""])
                    }
                    else {
                        self.approvalCodeTxtFld?.isHidden = false
                        self.continueBtn?.isHidden = false
                        self.titleLbl.text = "Yay! You're Almost There! Please enter Spark code to proceed"
                    }
                }
                
               
            }
                        
        }
    }
    
    func setupContactSyncObserver() {
        
        viewModel.finalWaitingModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.finalWaitingModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            if value.isOk ?? false {
                SessionManager.sharedInstance.isContactApprovedOrNot = value.data?.isApproved ?? false
                SessionManager.sharedInstance.isContactSyncedOrNot = value.data?.isSyncContact ?? false
                print("1")
                print(SessionManager.sharedInstance.isContactSyncedOrNot)

                 if value.data?.isApproved ?? false {
                    
                     SessionManager.sharedInstance.isUserLoggedIn = true
                     SessionManager.sharedInstance.isPostFromLink = false
                     
                     
                    // Redirected to home
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
                
                if value.data?.isSyncContact ?? false{
                    if !SessionManager.sharedInstance.linkApprovalCode.isEmpty{
                        self.approvalCodeTxtFld?.isHidden = true
                        self.continueBtn?.isHidden = true
                        self.titleLbl.text = "Yay! You're Almost There!"
                        self.viewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.linkApprovalCode ])
                    }
                    else{
                        if SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApproval == 0{
                            self.approvalCodeTxtFld?.isHidden = true
                            self.continueBtn?.isHidden = true
                            self.viewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApprovalCode ?? ""])
                            self.titleLbl.text = "Yay! You're Almost There!"
                        }
                        else {
                            self.approvalCodeTxtFld?.isHidden = false
                            self.continueBtn?.isHidden = false
                            self.titleLbl.text = "Yay! You're Almost There! Please enter Spark code to proceed"
                        }
                    }
                }
    
            }
        }
    }
    
    func setupApproveStatusObserver() {
        
        viewModel.approveStatusModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.approveStatusModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                
                if value.data ?? false {
                    self.viewModel.contactSyncAPICall()
                }
    
            }
        }
    }
    
    
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        
                        if !(contact.phoneNumbers.first?.value.stringValue ?? "").isEmpty && !contact.givenName.isEmpty && self.removeSpecialCharsFromString(contact.phoneNumbers.first?.value.stringValue ?? "").count >= 10   {
                            self.contacts.append(["MobileNumber":self.removeSpecialCharsFromString(contact.phoneNumbers.first?.value.stringValue ?? "") ,"Name":contact.givenName])
                        }
                    })
                    debugPrint(self.contacts)
                    
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    ///Removing Special charcters from give mobile number
    func removeSpecialCharsFromString(_ str: String) -> String {
        struct Constants {
            static let validChars = Set("1234567890")
        }
        return String(str.filter { Constants.validChars.contains($0) })
    }
    
    @IBAction func continueButtonTapped(sender:UIButton) {
        if !(approvalCodeTxtFld?.text?.isEmpty ?? false) {
            viewModel.getApproveStatusWithToken(postDict: ["token":approvalCodeTxtFld?.text ?? ""])
        }else{
            self.showErrorAlert(error: "Enter your approval code to continue...")
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
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
        approvalCodeTxtFld?.inputAccessoryView = doneToolbar
    }
    
    
    /**
     It is used to dimiss the current page
     */
    @objc func doneButtonAction(){
        self.view.endEditing(true)
    }
}
