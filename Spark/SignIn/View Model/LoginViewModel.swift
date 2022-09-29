//
//  LoginViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 25/06/21.
//

import Foundation
import UIKit
import DTGradientButton
import TransitionButton
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import RSLoadingView

class LoginViewModel {
        
    private let networkManager = NetworkManager()

    let settingModel = LiveData<SettingModel, Error>(value: nil)
    let loginModel = LiveData<LoginModel, Error>(value: nil)
    
    //#MARK: Sign In Button Setup
    func signInUISetup(button:UIButton, mobileTextField:UITextField) {
        
        //SignIn Button
        button.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        
        //Mobile Txt Field
        mobileTextField.useUnderline()
        mobileTextField.attributedPlaceholder = NSAttributedString(string: "Mobile Number",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.TextFieldPlaceholderColor])
    }
    
    
    //#MARK: Facebook Data Request
    
    ///Called to fetch the facebook user data
    func getFbUserData(onCompletion : @escaping (_ success:Bool,_ response:[String:Any])->()) {
        
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,gender,picture.width(480).height(480),first_name,last_name"], httpMethod: .get)
        _ = req.start(completionHandler: { (connection, result, error) in
            
            let dataDict = result as? [String:Any]
            
            onCompletion(true, dataDict ?? [:])
        })
    }
    
    ///Called when facebook login manager finished the data request
    func fbLoginManagerDidComplete(_ result: LoginResult, onCompletion : @escaping (_ result: [String:Any])->()) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            break
        case .success:
            getFbUserData { (isSuccess, response) in
                onCompletion(response)
            }
        }
    }
    
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            
            CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                                   message: error,
                                                   alertType: .oneButton(),
                                                   alertRadius: 30,
                                                   btnRadius: 20)
        }
    }
    
    //#MARK: Firebase Verification Code sending
    func sendFirebaseVerificationCodeToUser(mobileNumber:String, onCompletion: @escaping (_ success: Bool)->()) {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber , uiDelegate:nil) {
            verificationID, error in
            if (verificationID != nil) {
                SessionManager.sharedInstance.verificationID = verificationID ?? ""
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                onCompletion(true)
            }else {
                debugPrint(error?.localizedDescription ?? "")
                self.showErrorAlert(error: error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                onCompletion(false)
            }
        }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


//#MARK: Mobile number formatter
extension LoginViewModel {
    /// mask example: `+X (XXX) XXX-XXXX`
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    
}

//#MARK: Settings API Call
extension LoginViewModel {
    
    func settingAPICall(){
        
        networkManager.get(port: 1, endpoint: .settings) { [weak self] (result: Result<SettingModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let settingData):
                self.settingModel.value = settingData
                SessionManager.sharedInstance.settingData = settingData
                debugPrint("success")

            case .failure(let error):
                self.settingModel.error = error
                debugPrint("success")
            }
        }
    }
    
    func signUpAPICall(params:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .signup, body: params) { [weak self] (result: Result<LoginModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let signInData):
            self.loginModel.value = signInData

          case .failure(let error):
            self.loginModel.error = error
                
            }
        }
      }
}
