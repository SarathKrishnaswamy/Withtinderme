//
//  OTPViewController.swift
//  Spark
//
//  Created by Gowthaman P on 24/06/21.
//

import UIKit
import Lottie
import RAMAnimatedTabBarController
import RSLoadingView


/**
 This class is used to get the otp from firebase trigger and set the otp verify the otp.
 */
class OTPViewController: UIViewController, OTPDelegate {
    
    ///Always triggers when the OTP field is valid
    func didChangeValidity(isValid: Bool) {
        if isValid{
            //self.MaininternetRetry()
        }
        
    }
    
    /// check the view model for set the otpview model
    var viewModel = OTPViewModel()
    
    let otpStackView = OTPStackView()
    @IBOutlet var resendNowLbl:UILabel!
    @IBOutlet var resendNowBottomConstraints:NSLayoutConstraint!
    var resendNow = ""
    @IBOutlet var nextBtn:UIButton!
    private var animationView: AnimationView?
    @IBOutlet var animationBgView:UIView!
    @IBOutlet var otpBgView:UIView!
    var mobileNumberStr = ""
    var isFromProfile = false
    var loginMedium = ""
    var countryCode = ""
    var linkCode = String()
    var alertController = UIAlertController()
    
    @IBOutlet weak var otpDescLabl: UILabel!
    
    
    
    
    
    ///Called after the controller's view is loaded into memory.
    /// - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        //navigationSetUp()
        otpStackView.delegate = self
        
        termsAndCondtionSetUp()
        
        otpBgView.addSubview(otpStackView)
        
        //To setup OTP background view height
        otpStackView.heightAnchor.constraint(equalTo: otpBgView.heightAnchor).isActive = true
        otpStackView.centerXAnchor.constraint(equalTo: otpBgView.centerXAnchor).isActive = true
        otpStackView.centerYAnchor.constraint(equalTo: otpBgView.centerYAnchor).isActive = true
        
        viewModel.viewUISetup(button: nextBtn)
        
        viewModel.loadAnimatedImage(view: animationBgView)
        
        let formatNumber = self.viewModel.format(with: "(XXX) XXX-XXXXXXXXX", phone: mobileNumberStr)
        
        otpDescLabl.text = "A message with your verification code was sent to \(self.countryCode) \(formatNumber)"
        
        // otpDescLabl.text = "A message with your verification code was sent to \(self.countryCode) \(self.mobileNumberStr.applyPatternOnNumbers(pattern: "(XXX) XXX-XXXXXXXXX", replacementCharacter: "#"))"
        
        //hideKeyboardWhenTappedAround()
        
        historyButtonSetUp()
        
        setUpOtpVerifyObserver()
        
        NotificationCenter.default.addObserver(self,selector: #selector(statusManager),name: .flagsChanged,object: nil)
        updateUserInterface()
        
    }
    
    
    ///Update the User Interface when there is internet  ot no internet or changed from wifi, mobile data
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            print("unreachable")
            MaininternetRetry()
            
            //view.backgroundColor = .red
        case .wwan:
            print("mobile")
            //self.alertController.dismiss(animated: true)
            //MaininternetRetry()
            //view.backgroundColor = .yellow
        case .wifi:
            print("wifi")
            //self.alertController.dismiss(animated: true)
            // MaininternetRetry()
            //view.backgroundColor = .green
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    
    
    
    /// Satus manager to update the internet userInterface
    /// - Parameter notification: It receives the notified to update the internet checking
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    
    
    
    ///Internet can be check whether the internet is connected or not
    func MaininternetRetry(){
        if Connection.isConnectedToNetwork(){
            print("Connected")
            if isFromProfile {
                if !(otpStackView.getOTP().isEmpty) {
                    DispatchQueue.main.async {
                        RSLoadingView().showOnKeyWindow()
                    }
                    
                    viewModel.firebaseOtpVerification(verificationCode: otpStackView.getOTP()) { success in
                        if success{
                            self.viewModel.updateOTPVerifyForSocialMediaLogin()
                        }else{
                            self.showErrorAlert(error: "Please enter the valid OTP")
                            DispatchQueue.main.async {
                                RSLoadingView.hideFromKeyWindow()
                            }
                        }
                    }
                }
                else{
                    //                    DispatchQueue.main.async {
                    //                        RSLoadingView.hideFromKeyWindow()
                    //                    }
                    //                    self.showErrorAlert(error: "Please enter the valid OTP")
                }
            } else {
                
                if !(otpStackView.getOTP().isEmpty) {
                    
                    DispatchQueue.main.async {
                        RSLoadingView().showOnKeyWindow()
                    }
                    
                    viewModel.firebaseOtpVerification(verificationCode: otpStackView.getOTP()) { success in
                        if success{
                            
                            SessionManager.sharedInstance.isMobileNumberVerified = true
                            
                            SessionManager.sharedInstance.saveLoginMedium = "mobile"
                            
                            //                        DispatchQueue.main.async {
                            //                            RSLoadingView.hideFromKeyWindow()
                            //                        }
                            let params = [ "profilepic": "",
                                           "isVerified":1,
                                           "devicetoken":SessionManager.sharedInstance.saveDeviceToken,
                                           "lname":""
                                           ,"manufacturer":"Apple",
                                           "appversion":Bundle.main.releaseVersionNumberPretty,
                                           "fcmtoken": SessionManager.sharedInstance.saveDeviceToken,
                                           "mobilenumber": self.removeSpecialCharsFromString(self.mobileNumberStr),
                                           "app_version_with_build":Bundle.main.appVersionWithBuildNumber ?? 0,
                                           "email":"",
                                           "fname":"",
                                           "osversion":SoftwareAndHardwareDetails.sharedInstance.getOSVersion(),
                                           "devicetype":1,
                                           "providerName":"mobile",
                                           "uniqueId":self.removeSpecialCharsFromString(self.mobileNumberStr),
                                           "username": self.removeSpecialCharsFromString(self.mobileNumberStr),
                                           "accessToken":"",
                                           "refreshtoken":"",
                                           "countryCode":self.countryCode ] as [String : Any]
                            
                            self.viewModel.signUpAPICall(params: params)
                            
                        }else{
                            DispatchQueue.main.async {
                                RSLoadingView.hideFromKeyWindow()
                            }
                            
                            self.showErrorAlert(error: "Please enter the valid OTP")
                        }
                    }
                }else{
                    //                    DispatchQueue.main.async {
                    //                        RSLoadingView.hideFromKeyWindow()
                    //                    }
                    //                    self.showErrorAlert(error: "Please enter the OTP")
                }
            }
            
        }
        else{
            alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)
            
            
            
            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
                // ... Do something
                //self.navigationController?.popViewController(animated: true)
                self.MaininternetRetry()
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ... Do something
            }
            
        }
    }
    
    
    
    /// this  method is used to set the back button with the back image
    func historyButtonSetUp() {
        
        // create the button
        let suggestImage  = UIImage(named: "app_back")//#imageLiteral(resourceName: "profileBack").withRenderingMode(.alwaysOriginal)
        let suggestButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        suggestButton.setBackgroundImage(suggestImage, for: .normal)
        
        // here where the magic happens, you can shift it where you like
        suggestButton.transform = CGAffineTransform(translationX: -25, y: -2)
        suggestButton.addTarget(self, action: #selector(historyButtonPressed), for: .touchUpInside)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: suggestButton.frame)
        suggestButtonContainer.addSubview(suggestButton)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
        
    }
    
    
    /// Its used to back the page 
    @objc func historyButtonPressed() {
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpSignInViewModel()
        
    }
    
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    ///this method is for calling login api and navigate to required screen based on session value - SessionManager.sharedInstance.isContactApprovedOrNot
    //Setup Login Model
    func setUpSignInViewModel() {
        
        viewModel.loginModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showError(message: error.localizedDescription)
        }
        viewModel.loginModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            
            SessionManager.sharedInstance.getUserId = value.data?.userId ?? ""
            SessionManager.sharedInstance.getAccessToken = value.data?.accessToken ?? ""
            SessionManager.sharedInstance.isContactApprovedOrNot = value.data?.IsApproved ?? false
            SessionManager.sharedInstance.isProfileUpdatedOrNot = value.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.loopsPageisProfileUpdatedOrNot = value.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.createPageisProfileUpdatedOrNot = value.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.attachementPageisProfileUpdatedOrNot = value.data?.isProfileUpdated ?? false
            SessionManager.sharedInstance.getRefreshToken = value.data?.refreshToken ?? ""
            SessionManager.sharedInstance.saveCountryCode = value.data?.countryCode ?? ""
            SessionManager.sharedInstance.saveMobileNumber = value.data?.mobilenumber ?? ""
            SessionManager.sharedInstance.saveEmail = value.data?.email ?? ""
            //To verify OTP from profile page
            if self.isFromProfile {
                
                
                self.dismiss(animated: true, completion: nil)
                SessionManager.sharedInstance.isMobileNumberVerified = value.data?.isVerified == 1 ? true : false
                NotificationCenter.default.post(name: Notification.Name("OTPVerifiedSuccessfully"), object: nil)
                return
            }
            
            
            if SessionManager.sharedInstance.isContactApprovedOrNot {
                //                DispatchQueue.main.async {
                //                    RSLoadingView.hideFromKeyWindow()
                //                }
                if value.data?.isProfileUpdated ?? false {
                    SessionManager.sharedInstance.isUserLoggedIn = true
                    SessionManager.sharedInstance.isPostFromLink = false
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }else{
                    SessionManager.sharedInstance.isUserLoggedIn = false
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let editVC = storyBoard.instantiateViewController(identifier: EDIT_BIO_STORYBOARD) as! EditProfileTableViewController
                    editVC.isFromProfile = false
                    editVC.loginDetails = value.data
                    self.navigationController?.pushViewController(editVC, animated: true)
                }
                
            } else {
                
                if !(value.data?.isProfileUpdated ?? false)  {
                    SessionManager.sharedInstance.isUserLoggedIn = false
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let editVC = storyBoard.instantiateViewController(identifier: EDIT_BIO_STORYBOARD) as! EditProfileTableViewController
                    editVC.isFromProfile = false
                    editVC.loginDetails = value.data
                    self.navigationController?.pushViewController(editVC, animated: true)
                }else{
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let waitingVC = storyBoard.instantiateViewController(identifier: WAITING_VIEW_CONTROLLER) as! WaitingViewController
                    self.navigationController?.pushViewController(waitingVC, animated: true)
                }
            }
        }
    }
    
    
    
    ///Check whether the otp is verified successfully or not if verified it notifies and post to the observer
    //Setup Login Model
    func setUpOtpVerifyObserver() {
        
        viewModel.otpVerifyModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showError(message: error.localizedDescription)
        }
        viewModel.otpVerifyModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            //To verify OTP from profile page
            if self.isFromProfile {
                
                self.dismiss(animated: true, completion: nil)
                SessionManager.sharedInstance.isMobileNumberVerified = true
                NotificationCenter.default.post(name: Notification.Name("OTPVerifiedSuccessfully"), object: nil)
                return
            }
        }
    }
    
    
    /// Customised the Alert error message for popup the alert
    func showError(message: String){
        AlertBuilder(title: "\(message)")
            .addButton(title: "Ok")
            .present(context: self)
    }
    
    /// navigation bar setup
    func navigationSetUp() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
    }
    
   
    ///
    @IBAction func backButtonTapped(sender:UIButton) {
        
        if isFromProfile{
            self.dismiss(animated: true)
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    ///Removing Special charcters from give mobile number
    func removeSpecialCharsFromString(_ str: String) -> String {
        struct Constants {
            static let validChars = Set("1234567890")
        }
        return String(str.filter { Constants.validChars.contains($0) })
    }
    
    
    /// Next button is tapped to check firebase otp check and verify the user and redirected.
    @IBAction func nextButtonTapped(sender:UIButton) {
        if Connection.isConnectedToNetwork(){
            if isFromProfile {
                if !(otpStackView.getOTP().isEmpty) {
                    DispatchQueue.main.async {
                        RSLoadingView().showOnKeyWindow()
                    }
                    
                    viewModel.firebaseOtpVerification(verificationCode: otpStackView.getOTP()) { success in
                        if success{
                            self.viewModel.updateOTPVerifyForSocialMediaLogin()
                        }else{
                            self.showErrorAlert(error: "Please enter the valid OTP")
                            DispatchQueue.main.async {
                                RSLoadingView.hideFromKeyWindow()
                            }
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    self.showErrorAlert(error: "Please enter the valid OTP")
                }
            } else {
                
                if !(otpStackView.getOTP().isEmpty) {
                    
                    DispatchQueue.main.async {
                        RSLoadingView().showOnKeyWindow()
                    }
                    
                    viewModel.firebaseOtpVerification(verificationCode: otpStackView.getOTP()) { success in
                        if success{
                            
                            SessionManager.sharedInstance.isMobileNumberVerified = true
                            
                            SessionManager.sharedInstance.saveLoginMedium = "mobile"
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {

                                appDelegate.updateFirestorePushTokenIfNeeded()
                            }
                            
                            DispatchQueue.main.async {
                                RSLoadingView.hideFromKeyWindow()
                            }
                            let params = [ "profilepic": "",
                                           "isVerified":1,
                                           "devicetoken":SessionManager.sharedInstance.saveDeviceToken,
                                           "lname":""
                                           ,"manufacturer":"Apple",
                                           "appversion":Bundle.main.releaseVersionNumberPretty,
                                           "fcmtoken": SessionManager.sharedInstance.saveDeviceToken,
                                           "mobilenumber": self.mobileNumberStr,
                                           "app_version_with_build":Bundle.main.appVersionWithBuildNumber ?? 0,
                                           "email":"",
                                           "fname":"",
                                           "osversion":SoftwareAndHardwareDetails.sharedInstance.getOSVersion(),
                                           "devicetype":1,
                                           "providerName":"mobile",
                                           "uniqueId":self.removeSpecialCharsFromString(self.mobileNumberStr),
                                           "username": self.removeSpecialCharsFromString(self.mobileNumberStr),
                                           "accessToken":"",
                                           "refreshtoken":"",
                                           "countryCode":self.countryCode ] as [String : Any]
                            
                            self.viewModel.signUpAPICall(params: params)
                            
                        }else{
                            DispatchQueue.main.async {
                                RSLoadingView.hideFromKeyWindow()
                            }
                            
                            self.showErrorAlert(error: "Please enter the valid OTP")
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    self.showErrorAlert(error: "Please enter the OTP")
                }
            }
        }
        else{
            self.updateUserInterface()
        }
    }
}


extension OTPViewController {
    
    ///Set the resend label method here
    func termsAndCondtionSetUp()  {
        resendNowLbl.text = "Didn't receive the code yet? Resend now"
        let text = (resendNowLbl.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let ResendnowRange = (text as NSString).range(of: "Resend now")
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: ResendnowRange)
        resendNowLbl.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        resendNowLbl.isUserInteractionEnabled = true
        resendNowLbl.addGestureRecognizer(tapAction)
    }
    
    
    /// Tap the resend to get otp fired again
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        
        if gesture.didTapAttributedTextInLabelForLogin(label: resendNowLbl, targetText: " Resend now") {
            viewModel.sendFirebaseVerificationCodeToUser(mobileNumber: "\(countryCode)\(self.removeSpecialCharsFromString(self.mobileNumberStr))") { success in
                if success {
                    self.otpStackView.delegate = self
                    self.otpBgView.addSubview(self.otpStackView)
                    //To setup OTP background view height
                    self.otpStackView.heightAnchor.constraint(equalTo: self.otpBgView.heightAnchor).isActive = true
                    self.otpStackView.centerXAnchor.constraint(equalTo: self.otpBgView.centerXAnchor).isActive = true
                    self.otpStackView.centerYAnchor.constraint(equalTo: self.otpBgView.centerYAnchor).isActive = true
                    self.showAlert(string: "OTP has been sent successfully")
                }
            }
        }  else {
            print("Tapped none")
        }
    }
    
    ///Customised alert to show in the otp page
    func showAlert(string: String){
        CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                               message: string,
                                               alertType: .oneButton(),
                                               alertRadius: 30,
                                               btnRadius: 20)
    }
}

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
