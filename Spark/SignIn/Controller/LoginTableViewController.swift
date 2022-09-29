//
//  ViewController.swift
//  Spark
//
//  Created by Gowthaman P on 24/06/21.
//

import UIKit
import DTGradientButton
import TransitionButton
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import RAMAnimatedTabBarController
import GoogleMaps
import GooglePlaces
import SKCountryPicker
import AuthenticationServices
import RSLoadingView
import Contacts

/**
 This class is user for authenticate particular users to login using any medium like phone number, apple, google & facebook sigin in has been integrated
 */

class LoginTableViewController: UITableViewController,GIDSignInDelegate {
    
    /**
     Using loginviewmodel observe all the values and set in the UI
     */
    var viewModel = LoginViewModel()
    
    /**
     Signin button to sign in through any medium.
     */
    @IBOutlet var signInBtn:TransitionButton!
    
    ///Mobile number textfield 
    @IBOutlet var mobileNumberTxtFld:UITextField!
    
    ///Terms and condition label
    @IBOutlet var termsAndConditionsLbl:UILabel!
    //@IBOutlet var fbBtn:FBLoginButton!
    
    ///Google sign in button
    @IBOutlet var googleBtn:GIDSignInButton!
    
    ///Facebook sign in button
    @IBOutlet weak var facebookBtn: UIButton!
    
    ///Empty string to set the privacy policy
    var privacyPolicyStr = ""
    
    ///String to set the terms and conditions
    var tAndcStr = ""
    
    ///Using login medium variable we can check the login using which medium
    var loginMedium = ""
    
    ///Default country code has been set here
    var countryCode = "+91"
    
    ///Set the country code button as variable here
    var mobileBtn = UIButton(type: .custom)
    
    ///Using the link approval code we can set the invite code to approve the users
    var linkApprovalCode = String()
    
    
    //@IBOutlet weak var loginProviderStackView: UIStackView!
    
    
    
    ///Called after the controller's view is loaded into memory.
    /// - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
    /// - Setup the terms and conditions  and privacy policy  links
    /// - Initialise the country code button
    /// - Observe the notification approval code link
    /// - Observer the notification to open the profile page
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        termsAndCondtionSetUp()
        //Hide Keyboard when click outside view
        hideKeyboardWhenTappedAround()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //Mobile Number Textfield
        mobileBtn = UIButton.init(frame: CGRect(x: CGFloat(0), y: CGFloat(5), width: CGFloat(60), height: CGFloat(25)))
        mobileBtn.setTitle("+91", for: .normal)
        mobileBtn.titleLabel?.font = UIFont.MontserratRegular(.normal)
        mobileBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        mobileBtn.addTarget(self, action: #selector(countryCodeButtonTapped(sender:)), for: .touchUpInside)
        mobileBtn.titleLabel?.textAlignment = .left
        mobileBtn.backgroundColor = UIColor.clear
        mobileNumberTxtFld.leftView = mobileBtn
        mobileNumberTxtFld.leftViewMode = .always
        NotificationCenter.default.addObserver(self, selector: #selector(openApprovalCode), name: Notification.Name("approvalCode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openProfile), name: Notification.Name("listenProfiletLink"), object: nil)
        
       
    }
    
    
    /// Open the profile page
    /// - Parameters:
    ///     - notification: This will give the userId to open the profile page.
    @objc func openProfile(notification:NSNotification){
        let userId = "\((notification.object as? [String:Any])?["userId"] ?? "")"
        print(userId)
       // self.shareProfileUserId = userId
    }
    
    
    
    ///Set the approval code from setings Api
    /// - Parameters:
    ///   - notification: Approval code is used for new user to invite and approve
    @objc func openApprovalCode(notification:NSNotification){
        let approvalCode = "\((notification.object as? [String:Any])?["approvalCode"] as? String ?? "")"
        self.linkApprovalCode = approvalCode
        print(approvalCode)
    }
    
    /**

     Open the country picker page to select the country
     - Parameters:
         - Sender: Set tag for button to open the country picker
     
     */
    
    @objc func countryCodeButtonTapped(sender:UIButton) {
        
        presentCountryPickerScene(withSelectionControlEnabled: false)
    }
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        viewModel.signInUISetup(button: signInBtn, mobileTextField: mobileNumberTxtFld)
        if !(mobileNumberTxtFld.text?.isEmpty ?? false) {
            mobileNumberTxtFld.becomeFirstResponder()
        } else{
            mobileNumberTxtFld.resignFirstResponder()
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
       

        setUpSignInViewModel()
        let isFb = SessionManager.sharedInstance.settingData?.data?.versionInfo?.isFb ?? 0
        if isFb == 0{
            self.facebookBtn.isHidden = true
        }
        else{
            self.facebookBtn.isHidden = false
        }
        

    }
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        //self.signInBtn.stopAnimation()
        viewModel.signInUISetup(button: signInBtn, mobileTextField: mobileNumberTxtFld)
        //Clear Apple
        //KeychainItem.deleteUserIdentifierFromKeychain()
    }
    
    
    
    
    
    
    /// Get api call
    /// - login api call to validate user from server end
    /// - profile updated and user approved means navigate to home screen
    /// - profile updated false means move to edit profile screen
    func setUpSignInViewModel() {
        
        viewModel.loginModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.loginModel.observeValue = { [weak self] valu in
            guard let self = self else { return }
            
            SessionManager.sharedInstance.getUserId = valu.data?.userId ?? ""
            SessionManager.sharedInstance.getAccessToken = valu.data?.accessToken ?? ""
            SessionManager.sharedInstance.getRefreshToken = valu.data?.refreshToken ?? ""
            SessionManager.sharedInstance.isContactApprovedOrNot = valu.data?.IsApproved ?? false
            SessionManager.sharedInstance.isProfileUpdatedOrNot = valu.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = valu.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = valu.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = valu.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.saveCountryCode = valu.data?.countryCode ?? ""
            //SessionManager.sharedInstance.settingData?.data?.BubbleDestroyTime = valu.data?.
            //SessionManager.sharedInstance.saveAppleSocilaID = value.data?.socialId ?? ""
            
            
            if valu.data?.isProfileUpdated ?? false {
                
                if valu.data?.IsApproved ?? false {
                    
                    SessionManager.sharedInstance.isUserLoggedIn = true
                    SessionManager.sharedInstance.isPostFromLink = false
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                    
                } else {
                    
                    SessionManager.sharedInstance.isUserLoggedIn = false
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let waitingVC = storyBoard.instantiateViewController(identifier: WAITING_VIEW_CONTROLLER) as! WaitingViewController
                    self.navigationController?.pushViewController(waitingVC, animated: true)
                }
                
            } else {
                SessionManager.sharedInstance.isUserLoggedIn = false
                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let editProfileVC = storyBoard.instantiateViewController(identifier: EDIT_BIO_STORYBOARD) as! EditProfileTableViewController
                editProfileVC.isFromProfile = false
                editProfileVC.loginDetails = valu.data
                editProfileVC.loginMedium = self.loginMedium
                self.navigationController?.pushViewController(editProfileVC, animated: true)
            }
            
        }
        
    }
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    
    ///A control that executes your custom code in response to user interactions.
    /// - Sign in with Apple gives your users a fast and safe way to sign in to your apps and websites using their Apple ID. Incorporating Sign in with Apple eliminates the need for additional sign-up steps, allowing users to engage and focus on your app
    @IBAction func appleSignInButtonTapped(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    
    ///A control that executes your custom code in response to user interactions.
    /// - When we tap the signin button it will ask for mobile number validation, once we enetered the mobile number it will trigger to thr otp page.
    @IBAction func signInButtonTapped(_ button: UIButton) {
        
        guard let mobileNumberValue = mobileNumberTxtFld.text, !mobileNumberValue.isEmpty else {
            self.showErrorAlert(error: "Please enter the mobile number")
            return
        }
        
        guard let mobileNumberCount = mobileNumberTxtFld.text, mobileNumberCount.count > 11 && mobileNumberCount.count < 21  else {
            self.showErrorAlert(error: "Please enter the valid mobile number")
            return
        }
        
        DispatchQueue.main.async {
            RSLoadingView().showOnKeyWindow()
        }
        
        viewModel.sendFirebaseVerificationCodeToUser(mobileNumber: "\(countryCode)\(self.removeSpecialCharsFromString(mobileNumberTxtFld.text ?? ""))") { success in
            if success {
                DispatchQueue.main.async {
                    RSLoadingView.hideFromKeyWindow()
                }
                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let otpVC = storyBoard.instantiateViewController(identifier: OTP_STORYBOARD) as! OTPViewController
                otpVC.isFromProfile = false
                otpVC.countryCode = self.countryCode
                otpVC.mobileNumberStr = self.mobileNumberTxtFld.text ?? ""//self.removeSpecialCharsFromString(self.mobileNumberTxtFld.text ?? "")
                otpVC.linkCode = self.linkApprovalCode
                self.navigationController?.pushViewController(otpVC, animated: true)
            }else{
                DispatchQueue.main.async {
                    RSLoadingView.hideFromKeyWindow()
                }
            }
        }
        
    }
    
    
    ///Removing Special charcters from give mobile number
    /// - Parameters:
    ///       - str: String to remove the special characters has been passed
    func removeSpecialCharsFromString(_ str: String) -> String {
        struct Constants {
            static let validChars = Set("1234567890")
        }
        return String(str.filter { Constants.validChars.contains($0) })
    }
    
    
    
    ///A control that executes your custom code in response to user interactions.
    /// - Signin using the facebook button to login with facebook.
    @IBAction func fbsignInButtonTapped(_ button: UIButton) {
        
       facebookDataRequest()
    }
    
    
    ///A control that executes your custom code in response to user interactions.
    /// - Signin Using google button to login with google
    @IBAction func googleSignInButtonTapped(sender:UIButton) {
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().clientID = "654931077657-31siiqp7fmlbida9udbatusfeuen3cep.apps.googleusercontent.com"//APIContstant.googleSigninClientKey
        GIDSignIn.sharedInstance().delegate = self
    }
    
    
    //#MARK: Facebook login Request making
    
    
    
    
    ///Handle facebook access token
    /// -  Facebook sign in authentication
    /// - success or Failure handled
    /// -  After getting success
    /// - Login api called
    func facebookDataRequest()  {
        
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: [.userGender, .publicProfile, .userFriends,.email],
            viewController: self
        ) { result in
            self.viewModel.fbLoginManagerDidComplete(result) { response in
                
                self.loginMedium = "facebook"
                
                SessionManager.sharedInstance.saveLoginMedium = self.loginMedium
                
                let data = ((response["picture"] as? [String:Any])?["data"])
                
                let params = ["profilepic":((data as? [String:Any])?["url"] ?? "") ,
                              "isVerified":0,
                              "devicetoken":SessionManager.sharedInstance.saveDeviceToken,
                              "lname":response["last_name"] ?? "",
                              "manufacturer":"Apple",
                              "appversion":Bundle.main.releaseVersionNumberPretty,
                              "fcmtoken": SessionManager.sharedInstance.saveDeviceToken,
                              "mobilenumber": "",
                              "app_version_with_build":Bundle.main.appVersionWithBuildNumber ?? 0,
                              "email":response["email"] ?? "",
                              "fname":response["first_name"] ?? "",
                              "osversion":SoftwareAndHardwareDetails.sharedInstance.getOSVersion(),
                              "devicetype":1,
                              "username":response["email"] ?? "",
                              "providerName":self.loginMedium,
                              "uniqueId":response["id"] ?? "",
                              "accessToken":AccessToken.current?.tokenString ?? "",
                              "refreshtoken":"",
                              "countryCode":self.countryCode] as [String : Any]
                
                self.viewModel.signUpAPICall(params: params)
            }
        }
    }
    
    
    
    
      ///Handle Google sign in result
      /// - get google id and other user information
      /// - After getting success - Login api called
     
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Perform any operations on signed in user here.
        let givenName = user.profile.givenName ?? ""
        let familyName = user.profile.familyName ?? ""
        let email = user.profile.email ?? ""
        let dimension = round(200 * UIScreen.main.scale)
        let pic = user.profile.imageURL(withDimension: UInt(dimension))
        let userID = user.userID ?? ""
        let accessToken = user.authentication.accessToken ?? ""
        let refreshToken = user.authentication.refreshToken ?? ""
        
        loginMedium = "gmail"
        
        SessionManager.sharedInstance.saveLoginMedium = self.loginMedium
        
        //FIXME:
        let params = ["profilepic":"\(pic!)",
                      "isVerified":0,
                      "devicetoken":SessionManager.sharedInstance.saveDeviceToken,
                      "lname":familyName,
                      "manufacturer":"Apple",
                      "appversion":"\(Bundle.main.releaseVersionNumberPretty)",
                      "fcmtoken": SessionManager.sharedInstance.saveDeviceToken,
                      "mobilenumber": "",
                      "app_version_with_build":"\(Bundle.main.appVersionWithBuildNumber ?? "")",
                      "email":email,
                      "fname":givenName,
                      "osversion":"\(SoftwareAndHardwareDetails.sharedInstance.getOSVersion())",
                      "devicetype":1,
                      "username":email,
                      "providerName":loginMedium,
                      "uniqueId":userID,
                      "accessToken":accessToken,
                      "refreshtoken":refreshToken,
                      "countryCode":self.countryCode] as [String : Any]
        
        self.viewModel.signUpAPICall(params: params)
        
    }
    
}

//#MARK : UITextField Delegate

extension LoginTableViewController: UITextFieldDelegate {
    
    
    /// Asks the delegate whether to change the specified text.
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range. During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text. When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: true if the specified text range should be replaced; otherwise, false to keep the old text.
    /// - The text field calls this method whenever user actions cause its text to change. Use this method to validate text as it is typed by the user. For example, you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        mobileNumberTxtFld.text = self.viewModel.format(with: "(XXX) XXX-XXXXXXXXX", phone: newString)
        
        if newString.count == 20 {
            textField.resignFirstResponder()
        }
        return false
        //"+X (XXX) XXX-XXXX"
    }
}


extension LoginTableViewController {
    
    /// Set the terms and conditions setup using the terms and condition label
    ///  - Set this UILabel as attributed string with different colour
    func termsAndCondtionSetUp()  {
        termsAndConditionsLbl.text = "By proceeding you agree to our Terms of Service and Privacy Policy"
        let text = (termsAndConditionsLbl.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: termsRange)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: privacyRange)
        termsAndConditionsLbl.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        termsAndConditionsLbl.isUserInteractionEnabled = true
        termsAndConditionsLbl.addGestureRecognizer(tapAction)
    }
    
    
    /// While clicking on label with "Terms and conditions" & "Privacy Policy" it open up the terms and conditions & privacy policy  web page.
    /// - Check whether its a Temrs and Conditions or Privacy policy link has been attached.

    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabelForLogin(label: termsAndConditionsLbl, targetText: "Terms of Service") {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.TermsURL ?? ""
            webViewVC.titleStr = "Terms of Service"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        } else if gesture.didTapAttributedTextInLabelForLogin(label: termsAndConditionsLbl, targetText: "Privacy Policy") {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.PrivacyURL ?? ""
            webViewVC.titleStr = "Privacy Policy"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        } else {
            print("Tapped none")
        }
    }
}

private extension LoginTableViewController {
    
    /// Dynamically presents country picker scene with an option of including `Selection Control`.
    ///
    /// By default, invoking this function without defining `selectionControlEnabled` parameter. Its set to `True`
    /// unless otherwise and the `Selection Control` will be included into the list view.
    ///
    /// - Parameter selectionControlEnabled: Section Control State. By default its set to `True` unless otherwise.
    
    func presentCountryPickerScene(withSelectionControlEnabled selectionControlEnabled: Bool = true) {
        switch selectionControlEnabled {
        case true:
            
            break
        case false:
            
            // Present country picker without `Section Control` enabled
            let countryController = CountryPickerController.presentController(on: self) { [weak self] (country: Country) in
                
                guard let self = self else { return }
                
                self.countryCode = country.dialingCode ?? "91"
                self.mobileBtn.frame = CGRect(x: CGFloat(0), y: CGFloat(5), width: CGFloat(60), height: CGFloat(25))
                self.mobileBtn.setTitle("\(country.dialingCode ?? "")  ", for: .normal)
                
            }
            
            countryController.flagStyle = .corner
            countryController.isCountryFlagHidden = false
            countryController.isCountryDialHidden = false
            countryController.favoriteCountriesLocaleIdentifiers = ["IN", "US"]
        }
    }
}

extension LoginTableViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)

    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print(appleIDCredential.identityToken)
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            //self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            break
        
        default:
            break
        }
    }
    
//    private func saveUserInKeychain(_ userIdentifier: String) {
//        do {
//            try KeychainItem(service: "com.adhash.spark", account: "userIdentifier").saveItem(userIdentifier)
//        } catch {
//            print("Unable to save userIdentifier to keychain.")
//        }
//    }
    
    
    ///Handle Apple sign in result
    /// - get Apple id and other user information
    /// - After getting success - Login api called
   
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        
        
        self.loginMedium = "APPLE"
        
        SessionManager.sharedInstance.saveLoginMedium = self.loginMedium
        
        let params = ["profilepic":"",
                      "isVerified":0,
                      "devicetoken":SessionManager.sharedInstance.saveDeviceToken,
                      "lname":fullName?.familyName ?? "",
                      "manufacturer":"Apple",
                      "appversion":"\(Bundle.main.releaseVersionNumberPretty)",
                      "fcmtoken": SessionManager.sharedInstance.saveDeviceToken,
                      "mobilenumber": "",
                      "app_version_with_build":"\(Bundle.main.appVersionWithBuildNumber ?? "")",
                      "email":email ?? "",
                      "fname":fullName?.givenName ?? "",
                      "osversion":"\(SoftwareAndHardwareDetails.sharedInstance.getOSVersion())",
                      "devicetype":1,
                      "username":email ?? "",
                      "providerName":loginMedium,
                      "uniqueId":userIdentifier,
                      "accessToken":"",
                      "refreshtoken":"",
                      "countryCode":self.countryCode] as [String : Any]
        
        self.viewModel.signUpAPICall(params: params)
        
        
        
    }
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // print(error.localizedDescription)
    }
}


extension LoginTableViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
