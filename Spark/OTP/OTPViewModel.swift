//
//  OTPViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 25/06/21.
//

import UIKit
import Lottie
import DTGradientButton
import Firebase


class OTPViewModel: NSObject {

    private var animationView: AnimationView?
    var resendNowLbl:UILabel!
    
    private let networkManager = NetworkManager()

    let loginModel = LiveData<LoginModel, Error>(value: nil)
    
    let otpVerifyModel = LiveData<DataOkModel, Error>(value: nil)
    
    //#MARK: Sign In Button Setup
    func viewUISetup(button:UIButton) {
        
        button.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        
    }
    
    func loadAnimatedImage(view:UIView) {
        animationView = .init(name: "otp_animation")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
      //  animationView!.animationSpeed = 0.3
        view.addSubview(animationView!)
        animationView!.play()
    }
    

    
    //#MARK: Firebase Verification Code sending
        func sendFirebaseVerificationCodeToUser(mobileNumber:String, onCompletion: @escaping (_ success: Bool)->()) {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = false
            PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber , uiDelegate:nil) {
                verificationID, error in
                if (verificationID != nil) {
                    SessionManager.sharedInstance.verificationID = verificationID ?? ""
                    onCompletion(true)
                }else {
                    onCompletion(false)
                }
            }
        }
    /**
     This method is used to verify the received otp is correct or not
     - Parameter verificationCode: This is passing the verification code that we received in mobile phone
     - Parameter success: This is called when completion success
     - Parameter onCompletion: This is an closure variable
     */
    func firebaseOtpVerification(verificationCode:String, onCompletion: @escaping (_ success:Bool) -> ()) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: SessionManager.sharedInstance.verificationID ,verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authData, error) in
            if authData != nil {
                onCompletion(true)
                
            }else {
                debugPrint(error?.localizedDescription ?? "")
                onCompletion(false)
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
    
    func updateOTPVerifyForSocialMediaLogin(){
        
        networkManager.get(port: 1, endpoint: .otpVerifyForSocialMediaLogin) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let settingData):
                self.otpVerifyModel.value = settingData
                debugPrint("success")

            case .failure(let error):
                self.otpVerifyModel.error = error
                debugPrint("success")
            }
        }
    }
}


extension OTPViewModel {
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

