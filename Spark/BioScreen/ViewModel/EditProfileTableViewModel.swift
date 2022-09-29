//
//  EditProfileTableViewModel.swift
//  Spark
//
//  Created by adhash on 03/07/21.
//

import Foundation
import Firebase
import RSLoadingView

class EditProfileTableViewModel: NSObject {
    
    private let networkManager = NetworkManager()

    let saveModel = LiveData<SaveProfileModel, Error>(value: nil)
    
    func saveProfileApiCall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .updateProfile, body: params) { [weak self] (result: Result<SaveProfileModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
                self.saveModel.value = saveData
                
            case .failure(let error):
                self.saveModel.error = error
                
            }
        }
    }
    
    //#MARK: Firebase Verification Code sending
        func sendFirebaseVerificationCodeToUser(mobileNumber:String, onCompletion: @escaping (_ success: Bool)->()) {
            Auth.auth().settings?.isAppVerificationDisabledForTesting = false
            PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber , uiDelegate:nil) {
                verificationID, error in
                if (verificationID != nil) {
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    
                    SessionManager.sharedInstance.verificationID = verificationID ?? ""
                    onCompletion(true)
                }else {
                    DispatchQueue.main.async {
                        RSLoadingView.hideFromKeyWindow()
                    }
                    
                    onCompletion(false)
                }
            }
        }
}

//#MARK: Mobile number formatter
extension EditProfileTableViewModel {
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
