//
//  NftSparkViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/02/22.
//

import Foundation

/**
 This class is used to set the view model for get the details of nft to ger from server and set the model class
 */
class NftSparkViewModel: NSObject {

    private let networkManager = NetworkManager()
    
    let nftDetailModel = LiveData<NftSparkDetailModel, Error>(value: nil)
    let transferNftDetailModel = LiveData<BaseModel, Error>(value: nil)
    
    
    ///  Get the nft details from nft details
    func getNFTDetailApiCall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getNFTDetail, body: params) { [weak self] (result: Result<NftSparkDetailModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let detailData):
                self.nftDetailModel.value = detailData
                
            case .failure(let error):
                self.nftDetailModel.error = error
                
            }
        }
    }

    /// Get the transfer details from api call to transfer the ownership
    func transferNFTDetailApiCall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .transferNFTDetail, body: params) { [weak self] (result: Result<BaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let detailData):
                self.transferNftDetailModel.value = detailData
                
            case .failure(let error):
                self.transferNftDetailModel.error = error
                
            }
        }
    }
    /// Setup the post details in the indexpath 
    func setUpPostDetails(indexPath: IndexPath) -> FeedDetailNftCellViewModel? {
        let itemModel = nftDetailModel.value
        return FeedDetailNftCellViewModel(withModel: itemModel)
    }
}
