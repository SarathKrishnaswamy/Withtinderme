//
//  SettingsViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit

/**
 This class is used to call all the settings api here in the view model
 */
class SettingsViewModel {
    
    
    private let networkManager = NetworkManager()
    
    let logOutModel = LiveData<DataOkModel, Error>(value: nil)
    let shareModel = LiveData<ShareModel, Error>(value: nil)
    
    
    
    /// Call the logout api to logout from the app
    func logOutAPICall(){
        
        networkManager.get(port: 1, endpoint: .logOut) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let settingData):
                self.logOutModel.value = settingData
                debugPrint("success")

            case .failure(let error):
                self.logOutModel.error = error
                debugPrint("success")
            }
        }
    }
    
    
    /// Call the share api
    /// - Parameter params: Send the body as dictionary
    func shareApiCall(params:[String:Any]){
        networkManager.post(port: 1, endpoint: .generateToken, body: params) { [weak self] (result: Result<ShareModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let shareData):
                self.shareModel.value = shareData
                
            case .failure(let error):
                self.shareModel.error = error
                
            }
        }
        
    }
    
    
/// Delete the user account using the api "delete"
    func deleteApiCall(){
        let params = ["":""]
        networkManager.delete(port: 1, endpoint: .delete, body: params) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let settingData):
                self.logOutModel.value = settingData
                debugPrint("success")

            case .failure(let error):
                self.logOutModel.error = error
                debugPrint("error")
            }
        }
    }

}
