//
//  WalletViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 07/02/22.
//

import Foundation

class WalletViewModel: NSObject {

    private let networkManager = NetworkManager()
    
    let walletModel = LiveData<WalletModel, Error>(value: nil)
    var feedList = [WalletFeeds]()
    
    func getNFTListApiCall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getNFTList, body: params) { [weak self] (result: Result<WalletModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let walletData):
                self.walletModel.value = walletData
                
            case .failure(let error):
                self.walletModel.error = error
                
            }
        }
    }
    
    //NoLoader
    func getNFTListApiCallNoLoading(params:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getNFTList, body: params) { [weak self] (result: Result<WalletModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let walletData):
                if walletData.data?.feeds?.count ?? 0 > 0 {
                    self.feedList.append(contentsOf: walletData.data?.feeds ?? [WalletFeeds]())
                }
                
                self.walletModel.value = walletData
                
            case .failure(let error):
                self.walletModel.error = error
                
            }
        }
    }
    
   
    
    
    

}
