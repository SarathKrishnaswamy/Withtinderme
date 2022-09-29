//
//  MultipleViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import Foundation

/**
 This view model is used to get the multiple media listing in the monetize page.
 */
class MultipleViewModel: NSObject {
    private let networkManager = NetworkManager()
    
    //let settingModel = LiveData<SettingModel, Error>(value: nil)
    let multipleModel = LiveData<MultipleModel, Error>(value: nil)
    
    var multipleFeedListData = [MultipleMediaList]()
    
    
    /**
     Get all the media api with media list detail to get the media list 
     */
    func getMediaAPICall(params:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .getPostMediaList, body: params) { [weak self] (result: Result<MultipleModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let multipleData):
                if multipleData.data?.mediaList?.count ?? 0 > 0{
                    self.multipleFeedListData.append(contentsOf: multipleData.data?.mediaList ?? [MultipleMediaList]())
                }
            self.multipleModel.value = multipleData

          case .failure(let error):
            self.multipleModel.error = error
                
            }
        }
      }
    
    
}
