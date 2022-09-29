//
//  ClappedTagSparkViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 14/08/21.
//

import UIKit

/**
 This view model is used when we are clicking on existing spark we wil call this api model
 */
class ClappedTagSparkViewModel {
    
    private let networkManager = NetworkManager()

    let threadRequestModel = LiveData<ClappedBaseModel, Error>(value: nil)

    var clapDataModel = [ClapData]()
    
    func setUpSparkFeedDetails(indexPath: IndexPath) -> ClappedTagSparkCellViewModel {
        
        let itemModel = clapDataModel[indexPath.row]
        return ClappedTagSparkCellViewModel(withModel: itemModel)
    }
 
    func sendThreadRequest(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .threadRequest, body: postDict) { [weak self] (result: Result<ClappedBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let homeListData):
            self.threadRequestModel.value = homeListData

          case .failure(let error):
            self.threadRequestModel.error = error

            }
        }
      }
    
}
