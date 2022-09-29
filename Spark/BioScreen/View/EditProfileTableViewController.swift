//
//  EditProfileTableViewController.swift
//  Spark
//
//  Created by adhash on 02/07/21.
//

import UIKit
import RAMAnimatedTabBarController
import CropViewController
import SKCountryPicker
import RSLoadingView
import CoreLocation
import AVFoundation
import SwiftyJSON
import MessageUI

/**
 This class performs particular user edit his own Information like first name,last name,profile picture,DOB,Gender,Location,mobile number,email Id and account details
 */


class EditProfileTableViewController: UITableViewController, GetSelectedAddress, UINavigationControllerDelegate {
    
    
    
    
    /// Fetch the address to set  location of the user
    /// - Parameters:
    ///   - address: User select a location.
    ///   - lat: latitude to of the user
    ///   - long: longitude  of the user
    ///   - city: user city has been selected
    ///   - state: user state has been mentioned
    func fetchTheAddress(address: String, lat: Double, long: Double, city: String, state: String) {
        locationTxtFld.text = address
        self.city = city
    }
    
    var isMobileNumberEdited = false
    var mobileBtn:UIButton!
    var loginMedium = ""
    
    var city = ""
    let waitingViewModel = WaitingViewModel()
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var firstNameTxtFld: UITextField!
    @IBOutlet weak var lastNameTxtFld: UITextField!
    @IBOutlet weak var ageTxtFld: UITextField!
    @IBOutlet weak var locationTxtFld: UITextField!
    @IBOutlet weak var phoneTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var genderTxtFld: UITextField!
    @IBOutlet weak var aboubtMeTxtView: UITextView!
    @IBOutlet weak var profileBgView: UIView!
    @IBOutlet weak var basicInfoBtn: UIButton!
    @IBOutlet weak var kycInfoBtn: UIButton!
    @IBOutlet weak var basicInfoSelectedView: UIView!
    @IBOutlet weak var KycInfoSelectedView: UIView!
    @IBOutlet weak var bankaccTxtFld: UITextField!
    @IBOutlet weak var ifscTxtFld: UITextField!
    @IBOutlet weak var upiTxtFld: UITextField!
    @IBOutlet weak var aadharTxtFld: UITextField!
    @IBOutlet weak var panTxtFld: UITextField!
    
    @IBOutlet weak var checkBoxbtn: UIButton!
    @IBOutlet weak var termsandConditionLbl: UILabel!
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    
    //@IBOutlet var tableView: UITableView!
    
    var selectedImageUrl = ""
    
    var presentingAlert: UIAlertController?
    var isNewLoading = false
    
    let viewModel = EditProfileTableViewModel()
    var loginDetails:LoginData?
    
    //Cropper
    private var croppingStyle = CropViewCroppingStyle.default
    private var imageFrame = TOCropViewControllerAspectRatioPreset.presetSquare
    
    var isFromProfile = false
    var profileDetails:GetProfileData?
    
    let profileViewModel = ProfileViewModel()
    
    var countryCodeBtn:UIButton!
    var countryCode = ""
    var selectedRow = 1
    
    var accountNumber = ""
    var ifscCode = ""
    var upiNumber = ""
    var aadharNumber = ""
    var panNumber = ""
    var isKyc = false
    var isFromCreatePost = false
    var backFromProfileDelegate : backFromProfileDelegate?
    var isSkipped = false
    var isAgree = 0
    var isSkip = false
    var isAgreed = false
    var isSkipping = false
    var fromEditProfile : FromProfileDelegate?
    
    
    
    /// Called after the controller's view is loaded into memory.
    /// - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //userImageView.makeRounded()
        navigationSetUp()
        textFieldPadding()
        editButtonSetUp()
        textfieldDelegates()
        addDoneButtonOnKeyboard()
//        skipBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//        skipBtn.layer.cornerRadius = 6.0
//        skipBtn.layer.masksToBounds = true
        
//        continueBtn.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
//        continueBtn.layer.cornerRadius = 6.0
//        continueBtn.layer.masksToBounds = true
//        aboubtMeTxtView.textContainer.maximumNumberOfLines = 3
//        aboubtMeTxtView.textContainer.lineBreakMode = .byWordWrapping
        //aboubtMeTxtView.layoutManager.textContainerChangedGeometry(aboubtMeTxtView.textContainer)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setUpProfileViewModel()
        setupApproveStatusObserver()
        
     
        
        
        //historyButtonSetUp()
        
        //Mobile Number Textfield
        countryCodeBtn = UIButton.init(frame: CGRect(x: CGFloat(0), y: CGFloat(5), width: CGFloat(60), height: CGFloat(25)))
        countryCodeBtn.titleLabel?.font = UIFont.MontserratMedium(.normal)
        countryCodeBtn.setTitleColor(#colorLiteral(red: 0.2235294118, green: 0.3882352941, blue: 0.4745098039, alpha: 1), for: .normal)
        countryCodeBtn.addTarget(self, action: #selector(countryCodeButtonTapped(sender:)), for: .touchUpInside)
        countryCodeBtn.titleLabel?.textAlignment = .left
        countryCodeBtn.backgroundColor = UIColor.clear
        phoneTxtFld.leftView = countryCodeBtn
        phoneTxtFld.leftViewMode = .always
        
        if isFromProfile {
            
            if profileDetails?.email != "" && SessionManager.sharedInstance.saveLoginMedium == "facebook" || SessionManager.sharedInstance.saveLoginMedium == "gmail" || SessionManager.sharedInstance.saveLoginMedium == "APPLE"
            {
                emailTxtFld.isEnabled = false
                emailTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                emailTxtFld.layer.borderColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                emailTxtFld.layer.borderWidth = 1
                phoneTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderWidth = 1
                countryCodeBtn.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                emailTxtFld.isUserInteractionEnabled = false
            }
            else if profileDetails?.mobilenumber != "" && SessionManager.sharedInstance.saveLoginMedium == "mobile"
            {
                countryCodeBtn.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                countryCodeBtn.isUserInteractionEnabled = false
                phoneTxtFld.isEnabled = false
                phoneTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderWidth = 1
                phoneTxtFld.isUserInteractionEnabled = false
            }
            
            setupViewModel()
            profileViewModel.getProfileAPICall()
            
        }
        
        else if isSkipped{
            setupViewModel()
            profileViewModel.getProfileAPICall()
        }
        
        else{
            
            if loginDetails?.email != "" {
                emailTxtFld.isEnabled = false
                emailTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                emailTxtFld.layer.borderColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                emailTxtFld.layer.borderWidth = 1
                emailTxtFld.isUserInteractionEnabled = false
            }else if loginDetails?.mobilenumber != "" {
                countryCodeBtn.setTitleColor(#colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1), for: .normal)
                countryCodeBtn.isUserInteractionEnabled = false
                phoneTxtFld.isEnabled = false
                phoneTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                phoneTxtFld.layer.borderWidth = 1
                phoneTxtFld.isUserInteractionEnabled = false
            }
            
            firstNameTxtFld.text = loginDetails?.fname
            lastNameTxtFld.text = loginDetails?.lname
            phoneTxtFld.text = loginDetails?.mobilenumber
            self.phoneTxtFld.text = self.viewModel.format(with: "(XXX) XXX-XXXXXXXXX", phone: loginDetails?.mobilenumber ?? "")
            emailTxtFld.text = loginDetails?.email
            self.countryCodeBtn.setTitle(loginDetails?.countryCode ?? "", for: .normal)
            self.countryCode = loginDetails?.countryCode ?? ""
            
            let url = URL(string: loginDetails?.profilepic ?? "") ?? NSURL.init() as URL
            
            if (loginDetails?.profilepic?.isEmpty ?? false) {
                userImageView?.image = #imageLiteral(resourceName: "no_profile_image_male")
            }
            else {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    AzureManager.shared.uploadDataFromAws(folderName: "profilepic", image: UIImage(data: data) ?? UIImage()) { isSuccess, error, url in
                        if isSuccess {
                            self.selectedImageUrl = url
                            SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = url
                            debugPrint("Profile picture uploaded successfully")
                        }
                    }
                    // Create Image and Update Image View
                    
                    userImageView?.image = UIImage(data: data)
                }
            }
            
        }
        
        if aboubtMeTxtView.text == "" {
            aboubtMeTxtView.text = "Write something about you."
            self.aboubtMeTxtView.textColor = UIColor.init(hexString: "C5D0D6")
        }
        
        
    }
    
    //View Model Setup
    /// Load the api calls here to set the datas for skip and save the datas
    func setupViewModel() {
        
        profileViewModel.profileModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        profileViewModel.profileModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                self.isSkip = value.data?.isSkip ?? false
                self.isAgree = value.data?.isAgree ?? 0
                
                if self.isAgree == 0{
                    self.isAgreed = false
                }
                else{
                    self.isAgreed = true
                }
                
                if self.isSkip == false{
                    self.firstNameTxtFld.text = value.data?.fname
                    self.lastNameTxtFld.text = value.data?.lname
                    if value.data?.dob ?? 0 == 0  {
                        self.ageTxtFld.text = ""
                    }
                    else{
                        self.ageTxtFld.text = self.convertTimeStampToDOB(timeStamp: "\(value.data?.dob ?? 0)")
                    }
                    
                    if self.isFromProfile {
                        self.genderTxtFld.text =  value.data?.gender == 1 ?  "Male" : value.data?.gender == 2 ? "Female" : "Others"
                    }
                    else{
                        self.genderTxtFld.placeholder = "Select your gender"
                    }
                    //
                    
                }
                else{
                    self.firstNameTxtFld.text = ""
                    self.lastNameTxtFld.text = ""
                }
                
                
                
                if self.isAgree == 1 || self.isAgree == 2{
                    self.bankaccTxtFld.isUserInteractionEnabled = false
                    self.ifscTxtFld.isUserInteractionEnabled = false
                    self.upiTxtFld.isUserInteractionEnabled = false
                    self.aadharTxtFld.isUserInteractionEnabled = false
                    self.panTxtFld.isUserInteractionEnabled = false
                    self.checkBoxbtn.isEnabled = false
                    self.bankaccTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                    self.ifscTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                    self.upiTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                    self.checkBoxbtn.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    if self.isAgree == 1{
                       
                        self.accountVerificationSetUp()
                    }
                    else{
            
                        self.mailSetUp()
                    }
                }
                else{
                    self.checkBoxbtn.isEnabled = true
                    self.checkBoxbtn.setImage(UIImage(systemName: "square"), for: .normal)
                    self.termsAndCondtionSetUp()
                    self.bankaccTxtFld.isUserInteractionEnabled = true
                    self.ifscTxtFld.isUserInteractionEnabled = true
                    self.upiTxtFld.isUserInteractionEnabled = true
                    self.aadharTxtFld.isUserInteractionEnabled = true
                    self.panTxtFld.isUserInteractionEnabled = true
//                    self.bankaccTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
//                    self.ifscTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
//                    self.upiTxtFld.textColor = #colorLiteral(red: 0.537254902, green: 0.5294117647, blue: 0.5450980392, alpha: 1)
                }
                
                self.locationTxtFld.text = value.data?.location
                
                self.phoneTxtFld.text = value.data?.mobilenumber
                self.emailTxtFld.text = value.data?.email
                self.aboubtMeTxtView.text = value.data?.aboutme
                
                if value.data?.mobilenumber ?? "" == ""{
                    self.phoneTxtFld.isUserInteractionEnabled = true
                }
                else{
                    self.phoneTxtFld.isUserInteractionEnabled = false
                }
                
                
                self.phoneTxtFld.text = self.viewModel.format(with: "(XXX) XXX-XXXXXXXXX", phone: value.data?.mobilenumber ?? "")
                //self.appleUniqeId = value.data?.userId ?? ""
                
                self.countryCodeBtn.setTitle(value.data?.countryCode, for: .normal)
                self.countryCode = value.data?.countryCode ?? ""
                
                self.aboubtMeTxtView.textColor = UIColor.init(hexString: "396379")

                
                SessionManager.sharedInstance.isMobileNumberVerified = value.data?.isVerified == 0 ? false : true
                SessionManager.sharedInstance.saveMobileNumber = value.data?.mobilenumber ?? ""
                SessionManager.sharedInstance.isKYC = value.data?.isKYC ?? false
                
                if SessionManager.sharedInstance.isProfileUpdatedOrNot{
                    self.skipBtn.isHidden = true
                }
                else{
                    self.skipBtn.isHidden = false
                }
                
                
                //Mobile Number Textfield
                self.mobileBtn = UIButton(type: .custom)
                self.mobileBtn.setImage(UIImage(named: !SessionManager.sharedInstance.isMobileNumberVerified ? "mobile_notverified" : "mobile_verified"), for: .normal)
                self.mobileBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
                self.mobileBtn.addTarget(self, action: #selector(self.mobileNumberVerificationButtonTapped(sender:)), for: .touchUpInside)
                self.mobileBtn.frame = CGRect(x: CGFloat(self.phoneTxtFld.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
                self.mobileBtn.backgroundColor = UIColor.clear
                self.phoneTxtFld.rightView = self.mobileBtn
                self.phoneTxtFld.rightViewMode = .always
                
                let url = URL(string: value.data?.profilepic ?? "") ?? NSURL.init() as URL
                let fullMediaUrl = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(url)"
                self.selectedImageUrl = "\(url)"
                self.userImageView?.setImage(
                    url: URL.init(string: fullMediaUrl) ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: value.data?.gender == 1 ?  "no_profile_image_male" : value.data?.gender == 2 ? "no_profile_image_female" : "others"))
                
                if self.aboubtMeTxtView.text == "" {
                    self.aboubtMeTxtView.text = "Write something about you"
                    self.aboubtMeTxtView.textColor = UIColor.init(hexString: "C5D0D6")
                }
                
                let str = value.data?.accountDetails ?? ""
                //print(str)
                let data = Data("\(str)".utf8)
                //print(data)
                let decryptedResponse = CryptoHelper.decrypt(input: "\(String(data: data, encoding: .utf8) ?? "")")
               // print(decryptedResponse)
                let decryptedData = decryptedResponse?.data(using: .utf8)!
//
//
//                let data = NSData(base64Encoded: str, options: NSData.Base64DecodingOptions(rawValue: 0))

                do {
                  
                    
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(PayoutModel.self, from: decryptedData ?? Data.init())
                    print(model)
                    //print(result)
                    self.aadharTxtFld.text = model.aadhar_number ?? ""
                    self.bankaccTxtFld.text = model.acc_number ?? ""
                    self.ifscTxtFld.text = model.ifsc_code ?? ""
                    self.upiTxtFld.text = model.upi_number ?? ""
                    self.panTxtFld.text = model.pan_number ?? ""
                    
                } catch let error {
                    print(error)
                }
            }
            
            
        }
        
    }
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isOTPVerified(notification:)), name: Notification.Name("OTPVerifiedSuccessfully"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2349898517, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        var frame = tableView.bounds
        
        frame.origin.y = -frame.size.height
        
        let backgroundView = UIView(frame: frame)
        
        backgroundView.autoresizingMask = .flexibleWidth
        
        backgroundView.backgroundColor = #colorLiteral(red: 0.2349898517, green: 0.2676123083, blue: 0.435595423, alpha: 1)
        
        if !isNewLoading{
            if isFromCreatePost{
                SessionManager.sharedInstance.isProfileUpdatedOrNot = true
                self.resetBtn()
                self.kycInfoBtn.setTitleColor(UIColor(hexString: "#396379"), for: .normal)
                self.KycInfoSelectedView.backgroundColor = UIColor(hexString: "#396379")
                setupViewModel()
                profileViewModel.getProfileAPICall()
                self.selectedRow = 2
                self.tableView.reloadData()
            }
            else{
                self.resetBtn()
                self.basicInfoBtn.setTitleColor(UIColor(hexString: "#396379"), for: .normal)
                self.basicInfoSelectedView.backgroundColor = UIColor(hexString: "#396379")
                setupViewModel()
                profileViewModel.getProfileAPICall()
                self.selectedRow = 1
                self.tableView.reloadData()
            }
        }
        
       
        // Adding the view below the refresh control
        tableView.insertSubview(backgroundView, at: 0)
        
//        let gradient = CAGradientLayer()
//        gradient.frame = profileBgView.bounds
//        gradient.colors = [UIColor.profileStartColor.cgColor, UIColor.profileEndColor.cgColor]
//        profileBgView.layer.insertSublayer(gradient, at: 0)
        
        profileBgView.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0,1],
            size: CGSize(width: 400, height:300))
        
        //Mobile Number Textfield
        self.mobileBtn = UIButton(type: .custom)
        self.mobileBtn.setImage(UIImage(named: !SessionManager.sharedInstance.isMobileNumberVerified ? "mobile_notverified" : "mobile_verified"), for: .normal)
        self.mobileBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.mobileBtn.addTarget(self, action: #selector(self.mobileNumberVerificationButtonTapped(sender:)), for: .touchUpInside)
        self.mobileBtn.frame = CGRect(x: CGFloat(self.phoneTxtFld.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        self.mobileBtn.backgroundColor = UIColor.clear
        self.phoneTxtFld.rightView = self.mobileBtn
        self.phoneTxtFld.rightViewMode = .always
        
        
        
    }
    
    // approve get code
    /// If Status got approved it will navigate to home page by invitation code matches
    func setupApproveStatusObserver() {
        
        waitingViewModel.approveStatusModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        waitingViewModel.approveStatusModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                self.navigationController?.pushViewController(homeVC, animated: true)
                
                
            }
        }
    }
    
    /// Country code button tapped
    /// - Parameter sender: set the tag in the country code button
    @objc func countryCodeButtonTapped(sender:UIButton) {
        
        presentCountryPickerScene(withSelectionControlEnabled: false)
    }
    
    /// Check the otp is verified for mobile number
    /// - Parameter notification: Notification give the data of mobile number is verified or not.
    @objc func isOTPVerified(notification:NSNotification) {
        //Mobile Number Textfield
        isMobileNumberEdited = false
        mobileBtn.setImage(UIImage(named: !SessionManager.sharedInstance.isMobileNumberVerified ? "mobile_notverified" : "mobile_verified"), for: .normal)
    }
    
    /// This method will call when user try to verify their mobile number
    /// - Parameter sender: set the tag in the mobile number verification button
    @objc func mobileNumberVerificationButtonTapped(sender:UIButton) {
        //Return when mobile number alreay registered
        if (!isMobileNumberEdited) && SessionManager.sharedInstance.isMobileNumberVerified == true {
            return
        }
        
        if !(phoneTxtFld.text?.isEmpty ?? false) {
            self.alertForVerifyMobileNumber()
        }else{
            guard let mobileNumberValue = phoneTxtFld.text, !mobileNumberValue.isEmpty else {
                self.showErrorAlert(error: "Kindly Enter the Phone number")
                return
            }
            
            guard let mobileNumberCount = phoneTxtFld.text, mobileNumberCount.count > 11 && mobileNumberCount.count < 21  else {
                self.showErrorAlert(error: "Kindly Enter the Valid Phone number")
                return
            }
        }
        
    }
    
    /// Alert to show mobile number verification
    func alertForVerifyMobileNumber() {
        let alert = UIAlertController(title: "Verify Mobile Number", message: "Please verify your mobile number to proceed", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            
            self.sendFirebaseOTP()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    ///Send Firebase OTP to verify the given mobile number
    func sendFirebaseOTP(){
        
        guard let mobileNumberValue = phoneTxtFld.text, !mobileNumberValue.isEmpty else {
            self.showErrorAlert(error: "Kindly Enter the Phone number")
            return
        }
        
        guard let mobileNumberCount = phoneTxtFld.text, mobileNumberCount.count > 11 && mobileNumberCount.count < 21  else {
            self.showErrorAlert(error: "Kindly Enter the Valid Phone number")
            return
        }
        
        if (!SessionManager.sharedInstance.isMobileNumberVerified) {
            
            DispatchQueue.main.async {
                RSLoadingView().showOnKeyWindow()
            }
            SessionManager.sharedInstance.saveMobileNumber = self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? "")
            viewModel.sendFirebaseVerificationCodeToUser(mobileNumber: "\(countryCode)\(self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? ""))") { success in
                if success {
                   
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                    let otpVC = storyBoard.instantiateViewController(identifier: OTP_STORYBOARD) as! OTPViewController
                    otpVC.mobileNumberStr = self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? "")
                    otpVC.isFromProfile = true
                    otpVC.countryCode = self.countryCode
                    otpVC.modalPresentationStyle = .pageSheet
                    self.present(otpVC, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                }
            }
        }else {
            DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
        }
    }
    
    
    /// Back button tapped
    /// - Parameter sender: Its used to set the each tag
    @IBAction func backButtonTapped(sender:UIButton) {
        
        if isFromProfile {
            for controller in (self.navigationController?.viewControllers ?? [UIViewController]()) as Array {
                if controller.isKind(of: ProfileViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        else if isFromCreatePost{
            navigationController?.popViewController(animated: true)
        }
        
        else if isSkipped{
            self.fromEditProfile?.fromMonetize()
            navigationController?.popViewController(animated: true)
        }
        
        else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// Reset button is used to reset the segement button
    func resetBtn(){
        self.basicInfoBtn.setTitleColor(UIColor.black, for: .normal)
        self.kycInfoBtn.setTitleColor(UIColor.black, for: .normal)
        self.basicInfoSelectedView.backgroundColor = .lightGray
        self.KycInfoSelectedView.backgroundColor = .lightGray
    }
    
    
    /// Segment button is used to change whether basic Information or payout Information
    /// - Parameter sender: Using sender can select the segment button
    @IBAction func segmentBtnONPressed(_ sender: UIButton) {
        if sender.tag == 0{
            self.resetBtn() //396379
            self.basicInfoBtn.setTitleColor(UIColor(hexString: "#396379"), for: .normal)
            self.basicInfoSelectedView.backgroundColor = UIColor(hexString: "#396379")
            self.selectedRow = 1
            self.tableView.reloadData()
        }
        else if sender.tag == 1{
            self.resetBtn()
            self.kycInfoBtn.setTitleColor(UIColor(hexString: "#396379"), for: .normal)
            self.KycInfoSelectedView.backgroundColor = UIColor(hexString: "#396379")
            self.selectedRow = 2
            self.tableView.reloadData()
            
        }
    }
    
    
    /// Check box to agree the terms and conditions and privacy policy
    @IBAction func checkBoxOnPressed(_ sender: Any) {
        if isAgreed == false{
            self.isAgreed = true
            isAgree = 2
            self.checkBoxbtn.setImage(UIImage(named: "check_box_filled"), for: .normal)
        }
        else{
            self.isAgreed = false
            isAgree = 0
            self.checkBoxbtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    /// Skip button is used to skip without entering the profile details.
    @IBAction func skipBtnOnPressed(_ sender: Any) {
        
        guard let mobileNumberValue = phoneTxtFld.text, !mobileNumberValue.isEmpty else {
            self.showErrorAlert(error: "Enter your phone number")
            return
        }
        
//        guard let mobileNumberCount = phoneTxtFld.text, mobileNumberCount.count > 11 && mobileNumberCount.count < 21  else {
//            self.showErrorAlert(error: "Enter the valid phone number")
//            return
//        }
        
        print(phoneTxtFld.text?.count ?? 0)
        
        if phoneTxtFld.text?.count ?? 0 < 14 || phoneTxtFld.text?.count ?? 0 > 14 {
            self.showErrorAlert(error: "Enter the valid phone number")
        }
        else{
            if isMobileNumberEdited && SessionManager.sharedInstance.isMobileNumberVerified == false {
                self.alertForVerifyMobileNumber()
                return
            }
            
            let fname = "Guest"
            let lnme = removeSpecialCharsFromString(self.phoneTxtFld.text ?? "")
            let mob = lnme.suffix(4)
            let alert = UIAlertController(title: "", message: "Are you proceeding as a guest user? \(fname) \(mob)", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.isSkipping = true
                self.skipApiCall()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
               
            })
            self.present(alert, animated: true)
        }
       
        
       
        
        
        
        
    }
    
    
    
    /// Continue button is used to submit all the details to the api
    @IBAction func continueBtnOnPressed(_ sender: Any) {
        self.submitApi()
    }
    
    /// Adding a done button to dismiss the keyboard.
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        firstNameTxtFld.inputAccessoryView = doneToolbar
        lastNameTxtFld.inputAccessoryView = doneToolbar
        ageTxtFld.inputAccessoryView = doneToolbar
        genderTxtFld.inputAccessoryView = doneToolbar
        locationTxtFld.inputAccessoryView = doneToolbar
        phoneTxtFld.inputAccessoryView = doneToolbar
        emailTxtFld.inputAccessoryView = doneToolbar
        aboubtMeTxtView.inputAccessoryView = doneToolbar
        
    }
    
    /// Clicking done button to dismiss the keyboard.
    @objc func doneButtonAction(){
        firstNameTxtFld.resignFirstResponder()
        lastNameTxtFld.resignFirstResponder()
        ageTxtFld.resignFirstResponder()
        genderTxtFld.resignFirstResponder()
        locationTxtFld.resignFirstResponder()
        phoneTxtFld.resignFirstResponder()
        emailTxtFld.resignFirstResponder()
        aboubtMeTxtView.resignFirstResponder()
    }
    
    /// Age button tapped to select the date of birth
    @IBAction func ageButtonTapped(sender: UIButton) {
        
        self.view.endEditing(true)
        
        let slideVC = DateViewController()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        slideVC.delegate = self
        slideVC.selectedSetDate = ageTxtFld.text ?? ""
        self.present(slideVC, animated: true, completion: nil)
        
    }
    
    /// Gender button tapped to select male, female or others
    @IBAction func genderButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Gender", message: "Please select your gender", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Male", style: .default, handler: { (_) in
            self.genderTxtFld.text = "Male"
        }))
        
        alert.addAction(UIAlertAction(title: "Female", style: .default, handler: { (_) in
            self.genderTxtFld.text = "Female"
        }))
        
        alert.addAction(UIAlertAction(title: "Others", style: .default, handler: { (_) in
            self.genderTxtFld.text = "Others"
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
        
    }
    
    /// Location button tapped to select an address
    ///  - Latitude and longtitude has been used to take the current coordinates of the user
    @IBAction func locationButtonTapped(sender: UIButton) {
        doneButtonAction()
        self.view.endEditing(true)
        
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
                            
                            UIApplication.shared.open(settings)
                        })
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                        
                    })
                    self.present(alert, animated: true)
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)        //Configure the presentation controller
                    let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
                    mapVC?.delegate = self
                    self.present(mapVC ?? UIViewController(), animated: true, completion: nil)
                    
                    
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
                                
                                UIApplication.shared.open(settings)
                            })
                        }
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                            
                        })
                        self.present(alert, animated: true)
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                       
                    print("Access")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)        //Configure the presentation controller
                        let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
                        mapVC?.delegate = self
                        self.present(mapVC ?? UIViewController(), animated: true, completion: nil)
                        
                      
                    @unknown default:
                        break
                    }
              
            }
        
        
        
      
    }
    
    /// Top navigation bar setup
    func navigationSetUp() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
    }
    
    
    
    /// Padding for all textfields
    func textFieldPadding() {
        firstNameTxtFld.addPadding(.both(8))
        lastNameTxtFld.addPadding(.both(8))
        ageTxtFld.addPadding(.both(8))
        genderTxtFld.addPadding(.both(8))
        locationTxtFld.addPadding(.both(8))
        phoneTxtFld.addPadding(.both(8))
        emailTxtFld.addPadding(.both(8))
        bankaccTxtFld.addPadding(.both(8))
        ifscTxtFld.addPadding(.both(8))
        upiTxtFld.addPadding(.both(8))
        aadharTxtFld.addPadding(.both(8))
        panTxtFld.addPadding(.both(8))
        
        ageTxtFld.withImage(direction: .Right, image: #imageLiteral(resourceName: "calendarIcon"))
        genderTxtFld.withImage(direction: .Right, image: #imageLiteral(resourceName: "downArrow"))
        locationTxtFld.withImage(direction: .Right, image: #imageLiteral(resourceName: "currentLocation"))
        
        aboubtMeTxtView.leftSpace()
        
        self.bankaccTxtFld.delegate = self
        self.ifscTxtFld.delegate = self
        self.upiTxtFld.delegate = self
        self.aadharTxtFld.delegate = self
        self.panTxtFld.delegate = self
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
    
    // textfield delegates
    /// All the textfield delegates are intialised here
    func textfieldDelegates() {
        firstNameTxtFld.delegate = self
        lastNameTxtFld.delegate = self
        ageTxtFld.delegate = self
        genderTxtFld.delegate = self
        locationTxtFld.delegate = self
        phoneTxtFld.delegate = self
        emailTxtFld.delegate = self
        aboubtMeTxtView.delegate = self
    }
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //Setup save Model
    /// Observe the value  from api to set the profile image, name, date of birth, gender amd payout information
    ///  - When its a new user and all values are submitted page will be redirected to home page.
    ///  - When its a old user is updating it will be back to the profileviewcontroller class
    func setUpProfileViewModel() {
        
        viewModel.saveModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.saveModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            SessionManager.sharedInstance.isUserLoggedIn = true
            SessionManager.sharedInstance.isPostFromLink = false
            SessionManager.sharedInstance.isContactApprovedOrNot = value.data?.isApproved ?? false
            SessionManager.sharedInstance.saveGender = value.data?.gender == "Male" ? 1 : value.data?.gender == "Female" ? 2 : 0
            SessionManager.sharedInstance.saveCountryCode = value.data?.countryCode ?? ""
            
            if SessionManager.sharedInstance.isContactApprovedOrNot {
                
                if self.isFromProfile {
                    for controller in (self.navigationController?.viewControllers ?? [UIViewController]()) as Array {
                        if controller.isKind(of: ProfileViewController.self) {
                            self.showErrorAlert(error: "Profile information updated successfully")
                            self.backFromProfileDelegate?.backandReload()
                            NotificationCenter.default.post(name: Notification.Name("isProfileDetailUpdated"), object: nil)
                            self.navigationController?.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
                else if self.isFromCreatePost{
                    self.showErrorAlert(error: "Profile information saved successfully")
                    self.navigationController?.popViewController(animated: true)
                }
                
                else if self.isSkipped{
                    SessionManager.sharedInstance.isSkip = false
                    self.showErrorAlert(error: "Profile information saved successfully")
                    self.navigationController?.popViewController(animated: true)
                }
                
                else{
                    self.showErrorAlert(error: "Profile information saved successfully")
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let homeVC = storyBoard.instantiateViewController(identifier: "RAMAnimatedTabBarController") as! RAMAnimatedTabBarController
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
                
            } else {
                if !SessionManager.sharedInstance.linkApprovalCode.isEmpty{
                    self.waitingViewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.linkApprovalCode])
                }
                else{
                    self.waitingViewModel.getApproveStatusWithToken(postDict: ["token":SessionManager.sharedInstance.settingData?.data?.versionInfo?.autoApprovalCode ?? ""])
                }
//                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
//                let waitingVC = storyBoard.instantiateViewController(identifier: WAITING_VIEW_CONTROLLER) as! WaitingViewController
//                self.navigationController?.pushViewController(waitingVC, animated: true)
            }
            
            
        }
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    ///Asks the data source to return the number of sections in the table view.
    /// - Parameters:
    ///   - tableView: An object representing the table view requesting this information.
    /// - Returns:The number of sections in tableView.
    /// - If you don’t implement this method, the table configures the table with one section.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section:  An index number identifying a section in tableView.
    /// - Returns: The number of rows in section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedRow == 1{
            return 15
        }
        else{
            return 15
        }
    }
    
    
/// Asks the delegate for the height to use for a row in a specified location.
/// - Parameters:
///   - tableView: The table view requesting this information.
///   - indexPath: An index path that locates a row in tableView.
/// - Returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
///  - Override this method when the rows of your table are not all the same height. If your rows are the same height, do not override this method; assign a value to the rowHeight property of UITableView instead. The value returned by this method takes precedence over the value in the rowHeight property.
///  - Before it appears onscreen, the table view calls this method for the items in the visible portion of the table. As the user scrolls, the table view calls the method for items only when they move onscreen. It calls the method each time the item appears onscreen, regardless of whether it appeared onscreen previously.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedRow == 1{

            if indexPath.row == 0{
                return 205
            }
            else if indexPath.row == 1{
                return 75
            }
            else if indexPath.row == 8{
                return 154
            }
            else if indexPath.row == 9{
               return 0
            }
            else if indexPath.row == 10{
                return 0
            }
            else if indexPath.row == 11{
                return 0
            }
            else if indexPath.row == 12{
                return 0
            }
            else if indexPath.row == 13{
                return 0
            }
            else if indexPath.row == 14{
                return 0
            }
            
            else{
                return 92
            }
            //return UITableView.automaticDimension
        }
        else{
            if indexPath.row == 0{
                return 205
            }
            else if indexPath.row == 1{
                return 75
            }
            else if indexPath.row == 9{
               return 92
            }
            else if indexPath.row == 10{
                return 92
            }
            else if indexPath.row == 11{
                return 92
            }
            else if indexPath.row == 14{
                //if isAgree == 0{
                    return 92
                //}
                
            }
            
           
           
            else{
                return 0
            }

        }

    }






/// Asks the delegate for the estimated height of a row in a specified location.
/// - Parameters:
///   - tableView: The table view requesting this information.
///   - indexPath: An index path that locates a row in tableView.
/// - Returns: A nonnegative floating-point value that estimates the height (in points) that row should be. Return automaticDimension if you have no estimate.
///  - Providing an estimate the height of rows can improve the user experience when loading the table view. If the table contains variable height rows, it might be expensive to calculate all their heights and so lead to a longer load time. Using estimation allows you to defer some of the cost of geometry calculation from load time to scrolling time.
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    



///Removing Special charcters from give mobile number
/// - Parameters:
///      - str: String to remove the special characters has been passed
    func removeSpecialCharsFromString(_ str: String) -> String {
        struct Constants {
            static let validChars = Set("1234567890")
        }
        return String(str.filter { Constants.validChars.contains($0) })
    }
    
}
extension UITextView {
    /// Left space inside the tableview row
    func leftSpace() {
        self.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

extension EditProfileTableViewController {
    
    /// Edit button has been intialized here
    func editButtonSetUp() {
        // right button setup
        //        let historyBtn = UIButton(type: .custom)
        //        historyBtn.setImage(#imageLiteral(resourceName: "profileTick"), for: .normal)
        //        historyBtn.contentMode = .scaleAspectFit
        //        historyBtn.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        //        historyBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //        let historybarButton = UIBarButtonItem(customView: historyBtn)
        //        self.navigationItem.rightBarButtonItem = historybarButton
        
        aboubtMeTxtView.textColor = UIColor.init(hexString: "C5D0D6")
    }
    
    /// Submit to api
    @IBAction func submitButtonTapped(sender: UIButton) {
        
        self.submitApi()
    }
    
    
    /// Submit to the api call and check all the fields are filled
    func submitApi(){
        
        
        guard let firstName = firstNameTxtFld.text, !firstName.isEmpty else {
            self.showErrorAlert(error: "Enter the first name")
            return
        }
        
        guard let lastName = lastNameTxtFld.text, !lastName.isEmpty else {
            self.showErrorAlert(error: "Enter the last name")
            return
        }
        
        guard let ageValue = ageTxtFld.text, !ageValue.isEmpty else {
            self.showErrorAlert(error: "Select your birthday")
            return
        }
        
        guard let genderValue = genderTxtFld.text, !genderValue.isEmpty else {
            self.showErrorAlert(error: "Select your gender")
            return
        }
        
        guard let locationValue = locationTxtFld.text, !locationValue.isEmpty else {
            self.showErrorAlert(error: "Select your location")
            return
        }
        
        guard let mobileNumberValue = phoneTxtFld.text, !mobileNumberValue.isEmpty else {
            self.showErrorAlert(error: "Enter your phone number")
            return
        }
        
        guard let mobileNumberCount = phoneTxtFld.text, mobileNumberCount.count > 11 && mobileNumberCount.count < 21  else {
            self.showErrorAlert(error: "Enter the valid phone number")
            return
        }
        
//        guard let mobileNumberValue = phoneTxtFld.text, mobileNumberValue.count == 10 else {
//            self.showErrorAlert(error: "Kindly Enter the Valid Phone number")
//            return
//        }
        
        guard let emailValue = emailTxtFld.text, !emailValue.isEmpty else {
            self.showErrorAlert(error: "Enter your email id")
            return
        }
        
        if !(emailTxtFld.text?.isEmpty ?? false) {
            guard let emailText = emailTxtFld.text, emailText.isValidEmail else {
                self.showErrorAlert(error: "Enter valid email Id")
                return
            }
        }
        
        if isMobileNumberEdited && SessionManager.sharedInstance.isMobileNumberVerified == false {
            self.alertForVerifyMobileNumber()
            return
        }
        
        if aboubtMeTxtView.text == "Write something about you" {
            aboubtMeTxtView.text = ""
        }
        
        
        
        
        if bankaccTxtFld.text?.count ?? 0 > 0{
           
            guard let bankaccText = bankaccTxtFld.text, bankaccText.count > 4 else {
                self.showErrorAlert(error: "Enter valid bank account number")
                return
            }
            
            if (ifscTxtFld.text?.isEmpty ?? false) {
                guard let bankaccValue = bankaccTxtFld.text, bankaccValue.isEmpty else {
                    self.showErrorAlert(error: "Enter valid IFS/SWIFT code")
                    return
                }
                
            }
        }
        
        
        if ifscTxtFld.text?.count ?? 0 > 0{
            guard let ifscText = ifscTxtFld.text, ifscText.count > 7 else {
                self.showErrorAlert(error: "Enter valid IFS/SWIFT code")
                return
            }
            if (bankaccTxtFld.text?.isEmpty ?? false){
                guard let bankaccValue = ifscTxtFld.text, bankaccValue.isEmpty else {
                    self.showErrorAlert(error: "Enter valid bank account number")
                    return
                }
                
            }
        }
        
       
       
        
        
        
        
        if upiTxtFld.text?.count ?? 0 > 0{
            
            guard let upiText = upiTxtFld.text, upiText.count > 13 else {
                self.showErrorAlert(error: "Enter valid UPI Id")
                return
            }
            guard let upiText = upiTxtFld.text, upiText.isValidUPI else {
                self.showErrorAlert(error: "Enter valid UPI Id")
                return
            }
           
           
        }
        
        
        
        
        if bankaccTxtFld.text?.isEmpty == true && ifscTxtFld.text?.isEmpty == true && upiTxtFld.text?.isEmpty == true{
            
           
            if isAgreed == true{
                if bankaccTxtFld.text?.isEmpty == true && ifscTxtFld.text?.isEmpty == true && upiTxtFld.text?.isEmpty == true{
                    self.showErrorAlert(error: "Kindly enter payout information")
                }
                else{
                    SessionManager.sharedInstance.isKYC = false
                    self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
                }
            }
            else{
                SessionManager.sharedInstance.isKYC = false
                self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
            }
            
            
            
        }
        
        else if bankaccTxtFld.text?.isEmpty == false && ifscTxtFld.text?.isEmpty == false && upiTxtFld.text?.isEmpty == false{
            
            
            if isAgreed == true{
                SessionManager.sharedInstance.isKYC = true
                self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
            }
            else{
                self.showErrorAlert(error: "Kindly accept terms of service and privacy policy, before you proceed")
                
            }
            
           
        }
        
        else if upiTxtFld.text?.isEmpty == false{
            
            
            if isAgreed == true{
                SessionManager.sharedInstance.isKYC = true
                self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
            }
            else{
                self.showErrorAlert(error: "Kindly accept terms of service and privacy policy, before you proceed")
                
            }
            
            
        }
        else if bankaccTxtFld.text?.isEmpty == false && ifscTxtFld.text?.isEmpty == false{
            //SessionManager.sharedInstance.isKYC = true
            
            if isAgreed == true{
                SessionManager.sharedInstance.isKYC = true
                self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
            }
            else{
                self.showErrorAlert(error: "Kindly accept terms of service and privacy policy, before you proceed")
                
            }
            
            
        }
        
        
        
        else{
            
            
            if isAgreed == true{
                SessionManager.sharedInstance.isKYC = true
                self.callApi(firstName: firstName, lastName: lastName, ageValue: ageValue, genderValue: genderValue, locationValue: locationValue)
            }
            else{
                self.showErrorAlert(error: "Kindly accept terms of service and privacy policy, before you proceed")
                
            }
//
            
//
           
            //SessionManager.sharedInstance.isKYC = true
        }
        
        self.isSkipping = false
        
       
    }
    
    
    /// Call the update profile api here to send all the values to backend
    /// - Parameters:
    ///   - firstName:
    ///   - lastName:
    ///   - ageValue:
    ///   - genderValue:
    ///   - locationValue:
    func callApi(firstName:String, lastName:String, ageValue:String, genderValue:String, locationValue:String){
        let accountDetails = [
            "acc_number": bankaccTxtFld.text,
            "ifsc_code": ifscTxtFld.text,
            "upi_number":upiTxtFld.text,
            "aadhar_number": aadharTxtFld.text,
            "pan_number": panTxtFld.text
        ]
        //let data = try! JSONSerialization.data(withJSONObject: accountDetails)
        //let base64Representation = data.base64EncodedString()
        let jsonParamsData = try! JSONSerialization.data(withJSONObject: accountDetails, options: [])
        let paramJsonString = String(decoding: jsonParamsData, as: UTF8.self)
        debugPrint(paramJsonString)
        let base64Representation = CryptoHelper.encrypt(input: paramJsonString)
        print(base64Representation)
       
        
        let editParamDict = ["fname":firstName,
                             "lname":lastName,
                             "dob":convertDOBtoTimeStamp(dateStr: ageValue),
                             "gender":genderValue,
                             "location":locationValue,
                             "mobilenumber":self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? ""),
                             "email":emailTxtFld.text ?? "",
                             "aboutme":aboubtMeTxtView.text ?? "",
                             "userId":SessionManager.sharedInstance.getUserId,
                             "profilepic":self.selectedImageUrl,
                             "countryCode":self.countryCode,
                             "accountDetails":base64Representation ?? String(),
                             "isKYC" : SessionManager.sharedInstance.isKYC,
                             "isSkip":isSkipping,
                             "isAgree":isAgree
                             
        ] as [String : Any]
        
        debugPrint("Edit profile params--->",editParamDict)
        
        viewModel.saveProfileApiCall(params: editParamDict)
    }
    
    
    
    /// For guset user we can use the skip option mandotry is mobile number
    func skipApiCall(){
        let accountDetails = [
            "acc_number": "",
            "ifsc_code": "",
            "upi_number":"",
            "aadhar_number": "",
            "pan_number": ""
        ]
        let data = try! JSONSerialization.data(withJSONObject: accountDetails)
        let base64Representation = data.base64EncodedString()
        let mob = self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? "")
        let last4 = String(mob.suffix(4))
        
        let editParamDict = ["fname":"Guest",
                             "lname":"\(last4)",
                             "dob":"",
                             "gender":"",
                             "location":"",
                             "mobilenumber":self.removeSpecialCharsFromString(self.phoneTxtFld.text ?? ""),
                             "email":self.emailTxtFld.text ?? "",
                             "aboutme":"",
                             "userId":SessionManager.sharedInstance.getUserId,
                             "profilepic":self.selectedImageUrl,
                             "countryCode":self.countryCode,
                             "accountDetails":base64Representation,
                             "isKYC" : SessionManager.sharedInstance.isKYC,
                             "isSkip":isSkipping,
                             "isAgree":isAgree
                             
        ] as [String : Any]
        
        debugPrint("Edit profile params--->",editParamDict)
        
        viewModel.saveProfileApiCall(params: editParamDict)
    }
    
    
}

// MARK: - Table Field Delegate
extension EditProfileTableViewController : UITextFieldDelegate {
    
    /// Asks the delegate whether to change the specified text.
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range. During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text. When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: true if the specified text range should be replaced; otherwise, false to keep the old text.
    /// - The text field calls this method whenever user actions cause its text to change. Use this method to validate text as it is typed by the user. For example, you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if textField == firstNameTxtFld {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 25 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        } else if textField == lastNameTxtFld {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 25 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        } else if textField == phoneTxtFld {
            
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            
            //If mobile number chaged then need to update the mobile verify status
            if self.removeSpecialCharsFromString(newString) == SessionManager.sharedInstance.saveMobileNumber {
                if SessionManager.sharedInstance.isMobileNumberVerified == true {
                    isMobileNumberEdited = false
                    SessionManager.sharedInstance.isMobileNumberVerified = true
                    mobileBtn.setImage(UIImage(named: "mobile_verified"), for: .normal)
                }else {
                    isMobileNumberEdited = true
                    SessionManager.sharedInstance.isMobileNumberVerified = false
                    mobileBtn.setImage(UIImage(named: "mobile_notverified"), for: .normal)
                }
            }else {
                //if SessionManager.sharedInstance.isMobileNumberVerified == false {
                isMobileNumberEdited = true
                SessionManager.sharedInstance.isMobileNumberVerified = false
                mobileBtn.setImage(UIImage(named: "mobile_notverified"), for: .normal)
                // }
            }
            
            phoneTxtFld.text = self.viewModel.format(with: "(XXX) XXX-XXXXXXXXX", phone: newString)

            
            return false
            
        } else if textField == emailTxtFld {
            guard let text = textField.text else { return false }
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            return newString.count < 60 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else if textField == bankaccTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 21 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else if textField == ifscTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 12 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else if textField == upiTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "1234567890abcdefghijklmnopqrstuvwxyz@_"
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 26 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else if textField == aadharTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "1234567890"
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 13 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else if textField == panTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (string == filtered) && newString.count < 11 && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        
        else {
            return true
        }
    }
}

// MARK: - Table view Delegate
extension EditProfileTableViewController : UITextViewDelegate {
    
    /// Set the text Limit count
    /// - Parameters:
    ///   - existingText: Already existing text
    ///   - newText: The new text added
    ///   - limit: Limit count to be set
    /// - Returns: Whether it returns true or false
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    
    
    
    
    /// Tells the delegate when the user changes the text or attributes in the specified text view.
    /// - Parameter textView:The text view containing the changes.
    /// - The text view calls this method in response to user-initiated changes to the text. This method is not called in response to programmatically initiated changes.
    func textViewDidChange(_ textView: UITextView) {
        // Avoid new lines also at the beginning
        aboubtMeTxtView.text = textView.text.replacingOccurrences(of: "^\n", with: "", options: .regularExpression)
        // Avoids 4 or more new lines after some text
        aboubtMeTxtView.text = textView.text.replacingOccurrences(of: "\n{4,}", with: "\n\n\n", options: .regularExpression)
    }
    
    
    
    
    
    
    
    /// Asks the delegate whether to replace the specified text in the text view.
    /// - Parameters:
    ///   - textView: The text view containing the changes.
    ///   - range: The current selection range. If the length of the range is 0, range reflects the current insertion point. If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character.

    ///   - text: The text to insert.
    /// - Returns: true if the old text should be replaced by the new text; false if the replacement operation should be aborted.
    ///  - The text view calls this method whenever the user types a new character or deletes an existing character. Implementation of this method is optional. You can use this method to replace text before it is committed to the text view storage. For example, a spell checker might use this method to replace a misspelled word with the correct spelling.

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let new_String = (textView.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        aboubtMeTxtView.textColor = UIColor.init(hexString: "396379")
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        if(text == "\n") {
            return linesAfterChange <= textView.textContainer.maximumNumberOfLines
        }
        
        return self.textLimit(existingText: textView.text, newText: text, limit: 150) && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    

    
    /// Tells the delegate when editing of the specified text view begins
    /// - Parameter textView: The text view in which editing began.
    /// Implementation of this method is optional. A text view sends this message to its delegate immediately after the user initiates editing in a text view and before any changes are actually made. You can use this method to set up any editing-related data structures and generally prepare your delegate to receive future editing messages.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  aboubtMeTxtView.text == "Write something about you" {
            aboubtMeTxtView.text = ""
            aboubtMeTxtView.textColor = UIColor.init(hexString: "396379")
        }
    }
    
    
    
    
    
    
    
    /// Tells the delegate when editing of the specified text view ends.
    /// - Parameter textView: The text view in which editing ended.
    /// - Implementation of this method is optional. A text view sends this message to its delegate after it closes out any pending edits and resigns its first responder status. You can use this method to tear down any data structures or change any state information that you set when editing began.
    func textViewDidEndEditing(_ textView: UITextView) {
        if  aboubtMeTxtView.text.isEmpty {
            aboubtMeTxtView.text = "Write something about you"
            aboubtMeTxtView.textColor = UIColor.init(hexString: "C5D0D6")
        }
    }
}

extension EditProfileTableViewController : UIImagePickerControllerDelegate {
    ///This method is used access the gallary images from iphone
    /// - Camera button tapped to open the camera to capture the profile image
    @IBAction func cameraButtonTapped(sender:UIButton) {
        
        let alertController = UIAlertController(title: "Profile Image", message: "Please select your profile image", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.croppingStyle = .default
            self.imageFrame = .presetSquare
            
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let profileAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.croppingStyle = .default
            self.imageFrame = .presetSquare
            self.cameraSelected()
            
//            let imagePicker = UIImagePickerController()
//            imagePicker.modalPresentationStyle = .popover
//            imagePicker.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
//            imagePicker.sourceType = .camera
//            imagePicker.allowsEditing = false
//            imagePicker.delegate = self
//            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cencelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(defaultAction)
        alertController.addAction(profileAction)
        alertController.addAction(cencelAction)
        
        // let presentationController = alertController.popoverPresentationController
        present(alertController, animated: true, completion: nil)
        
    }
    
    /// Using Camera selected we can authorise the camera permission
    func cameraSelected() {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        if UIImagePickerController.isSourceTypeAvailable(.camera) != nil {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
                case .authorized:
                    showCameraPicker()
                case .denied:
                    alertPromptToAllowCameraAccessViaSettings()
                case .notDetermined:
                    permissionPrimeCameraAccess()
                default:
                    permissionPrimeCameraAccess()
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                //Analytics.track(event: .permissionsPrimeCameraNoCamera)
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    
    /// Alert to open the camera settings.
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "\"Spark Me\" Would Like To Access the Camera", message: "Please grant permission to use the Camera so that you can upload images.", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
            //Analytics.track(event: .permissionsPrimeCameraOpenSettings)
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(appSettingsURL as URL)
            }
        })
        present(alert, animated: true, completion: nil)
    }

    
    /// Alert to open the camera permission.
    func permissionPrimeCameraAccess() {
        let alert = UIAlertController( title: "\"Spark Me\" Would Like To Access the Camera", message: "Please allow to access your Camera so that you can upload images.", preferredStyle: .alert )
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            //Analytics.track(event: .permissionsPrimeCameraAccepted)
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                    DispatchQueue.main.async {
                        self?.cameraSelected() // try again
                    }
                })
            }
        })
        alert.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
           // Analytics.track(event: .permissionsPrimeCameraCancelled)
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }

    
    /// Showing the camera picker to set the cropping.
    func showCameraPicker() {
        self.croppingStyle = .default
        self.imageFrame = .presetSquare
        
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .popover
        imagePicker.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

//#MARK: Crop Viewcontroller
extension EditProfileTableViewController : CropViewControllerDelegate {
   
    
    /// Tells the delegate that the user picked a still image or movie.
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - info: A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in UIImagePickerController.InfoKey.
    ///   - Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
    ///   - When editing is enabled, the image picker view presents the user with a preview of the currently selected image or movie along with controls for modifying it. (This behavior is managed by the picker view prior to calling this method.) If the - - - user modifies the image or movie, the editing information is available in the info parameter. The original image is also returned in the info parameter.
    ///   - If you set the image picker’s showsCameraControls property to false and provide your own custom controls, you can take multiple pictures before dismissing the image picker interface. However, if you set that property to true, your - delegate must dismiss the image picker interface after the user takes one picture or cancels the operation.
    ///   - Implementation of this method is optional, but expected.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        //cropController.modalPresentationStyle = .fullScreen
        
        cropController.delegate = self
        
        picker.dismiss(animated: true, completion: {
            self.present(cropController, animated: true, completion: nil)
        })
    }
    
   
    /// Called when the user has committed the crop action, and provides both the original image with crop co-ordinates.
    
    /// - Parameters:
    /// - image: The newly cropped image.
    /// - cropRect: A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
    /// - angle The angle of the image when it was cropped
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    
   
     /// If the cropping style is set to circular, implementing this delegate will return a circle-cropped version of the selected image, as well as it's cropping co-ordinates
     
     /// - Parameters:
    ///    - image: The newly cropped image, clipped to a circle shape
    ///    - cropRect:  A rectangle indicating the crop region of the image the user chose (In the original image's local co-ordinate space)
    ///    - angle: The angle of the image when it was cropped
     
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    /// Update imageview with uploading image to aws
    /// - Parameters:
    ///   - image: Set the uiimage
    ///   - cropViewController: After cropping trhe image we can set here
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        DispatchQueue.main.async {
            //RSLoadingView().showOnKeyWindow()
            self.userImageView.image = image
        }
        
        if selectedImageUrl.isEmpty {
            AzureManager.shared.uploadDataFromAws(folderName: "profilepic", image: image) { isSuccess, error, url in
                if isSuccess {
                    self.selectedImageUrl = url
                    SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = url
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    debugPrint("Profile picture uploaded successfully")
                }
            }
            return
        }

        AzureManager.shared.deleteDataFromAws(key: selectedImageUrl) { success, error, url in
            debugPrint(success)
            if success {
                AzureManager.shared.uploadDataFromAws(folderName: "profilepic", image: image) { isSuccess, error, url in
                    if isSuccess {
                        self.selectedImageUrl = url
                        SessionManager.sharedInstance.saveUserDetails["currentProfilePic"] = url
                        debugPrint("Profile picture uploaded successfully")
                        DispatchQueue.main.async {
                            RSLoadingView.hideFromKeyWindow()
                        }
                    }
                }
            }
        }
        
       
        self.isNewLoading = true
        
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
}


private extension EditProfileTableViewController {
    
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
                
                self.countryCode = country.dialingCode ?? ""
                self.countryCodeBtn.frame = CGRect(x: CGFloat(0), y: CGFloat(5), width: CGFloat(60), height: CGFloat(25))
                self.countryCodeBtn.setTitle("\(country.dialingCode ?? "")  ", for: .normal)
                
            }
            
            countryController.flagStyle = .corner
            countryController.isCountryFlagHidden = false
            countryController.isCountryDialHidden = false
            countryController.favoriteCountriesLocaleIdentifiers = ["IN", "US"]
        }
    }
}

extension EditProfileTableViewController: UIViewControllerTransitioningDelegate {
    
    /// The presentation controller that’s managing the current view controller.
    /// - Parameters:
    ///   - presented: A vc that presents already
    ///   - presenting: A vc thats going to present now
    ///   - source: From the present vc it will shown
    /// - Returns: It will returns the currently opened vc
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension EditProfileTableViewController : DatePickerValueDelegate {
    /// Select the date from the date picker
    /// - Parameter dateStr: It is date will converted as string to show in textfield
    func DatePickerSelectedDate(dateStr: String) {
        ageTxtFld.text = dateStr
    }
}


//extension String {
//    //Base64 decode
//    /// <#Description#>
//    /// - Returns: <#description#>
//    func fromBase64() -> String? {
//            guard let data = Data(base64Encoded: self) else {
//                    return nil
//            }
//            return String(data: data, encoding: .utf8)
//    }
//
//    //Base64 encode
//    /// <#Description#>
//    /// - Returns: <#description#>
//    func toBase64() -> String {
//            return Data(self.utf8).base64EncodedString()
//    }
// }


extension EditProfileTableViewController {
    /// Terms and conditions Label has been setup here
    func termsAndCondtionSetUp()  {
        termsandConditionLbl.text = "You agree to our Terms of Service and Privacy Policy"
        let text = (termsandConditionLbl.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: termsRange)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: privacyRange)
        termsandConditionLbl.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        termsandConditionLbl.isUserInteractionEnabled = true
        termsandConditionLbl.addGestureRecognizer(tapAction)
    }
    
    /// Tap a label of terms and conditions & Privacy policy has been open.
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabelForLogin(label: termsandConditionLbl, targetText: "Terms of Service") {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.TermsURL ?? ""
            webViewVC.titleStr = "Terms of Service"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        } else if gesture.didTapAttributedTextInLabelForLogin(label: termsandConditionLbl, targetText: "Privacy Policy") {
            
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let webViewVC = storyBoard.instantiateViewController(identifier: "WebViewController") as! WebViewController
            webViewVC.urlStr = SessionManager.sharedInstance.settingData?.data?.PrivacyURL ?? ""
            webViewVC.titleStr = "Privacy Policy"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        } else {
            print("Tapped none")
        }
    }
    
    
    
    /// Account verification is in progress setup
    func accountVerificationSetUp()  {
        termsandConditionLbl.text = "Your account verification is in progress, please wait for admin approval"
    }
    
    
    /// Email setup has been set to send the email
    func mailSetUp()  {
        termsandConditionLbl.text = "If you want to edit your payout details, please contact the admin \(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")"
        let text = (termsandConditionLbl.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let termsRange = (text as NSString).range(of: "\(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")")
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.termsAndCondtionColor, range: termsRange)
        termsandConditionLbl.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapEmailLabel(gesture:)))
        termsandConditionLbl.isUserInteractionEnabled = true
        termsandConditionLbl.addGestureRecognizer(tapAction)
    }
    
    /// Tap the Email to open the email composer
    @IBAction func tapEmailLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabelForLogin(label: termsandConditionLbl, targetText: "\(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")") {
            self.sendEmail(mailId: "\(SessionManager.sharedInstance.settingData?.data?.ContactMail ?? "")", message: "")
            
        } else {
            print("Tapped none")
        }
    }
    
    
}


extension EditProfileTableViewController : MFMailComposeViewControllerDelegate {
    
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
