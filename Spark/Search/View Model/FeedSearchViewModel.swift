//
//  SearchViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 04/08/21.
//

import UIKit

/**
 This view model is used to get the search feed list api call inside the feed search page
 */
class FeedSearchViewModel: NSObject {
   
    private let networkManager = NetworkManager()

    let homeBaseModel = LiveData<homeBaseModel, Error>(value: nil)
    
    let homeClapModel = LiveData<ClapModel, Error>(value: nil)
    
    var feedListData = [HomeFeeds]()
    
    let checkThreadLimitModel = LiveData<CreatePostModel, Error>(value: nil)
    
    let checkThreadLimitModelForClapAndLoopRequest = LiveData<CreatePostModel, Error>(value: nil)
    
    let GetPostDetailsModel = LiveData<GetPostDetails, Error>(value: nil)
    
    let eyeShotModel = LiveData<EyeshotCountModel, Error>(value: nil)
    
    /// This method is used to set the api call for search feed list with home base model
    func searchFeedListApiCall(postDict:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .feedSearch, body: postDict) { [weak self] (result: Result<homeBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let homeListData):
            if homeListData.data?.feeds?.count ?? 0 > 0 {
            self.feedListData.append(contentsOf: homeListData.data?.feeds ?? [HomeFeeds]())
            }
            self.homeBaseModel.value = homeListData
          case .failure(let error):
            self.homeBaseModel.error = error
                
            }
        }
      }
    
    /// Search feed list with api call with no loader
    func searchFeedListApiCallNoLoading(postDict:[String:Any]) {
    
        networkManager.postNoLoading(port: 1, endpoint: .feedSearch, body: postDict) { [weak self] (result: Result<homeBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let homeListData):
            if homeListData.data?.feeds?.count ?? 0 > 0 {
            self.feedListData.append(contentsOf: homeListData.data?.feeds ?? [HomeFeeds]())
            }
            self.homeBaseModel.value = homeListData
          case .failure(let error):
            self.homeBaseModel.error = error
                
            }
        }
      }
   
    /// Home clap api call for right side swipe in the collection view cell
    func homeClapApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .homeClap, body: postDict) { [weak self] (result: Result<ClapModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let homeListData):
            self.homeClapModel.value = homeListData

          case .failure(let error):
            self.homeClapModel.error = error

            }
        }
      }
    
    /// Check the thread limit api call in the left side swipe action
    func checkThreadLimitAPICall(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .checkThreadLimit, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let checkThreadModel):
            self.checkThreadLimitModel.value = checkThreadModel

          case .failure(let error):
            self.checkThreadLimitModel.error = error

            }
        }
      }
    
    /// Check the thread limit api call for clap and loop request
    func checkThreadLimitAPICallForClapAndLoopRequest(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .checkThreadLimit, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let checkThreadModel):
            self.checkThreadLimitModelForClapAndLoopRequest.value = checkThreadModel

          case .failure(let error):
            self.checkThreadLimitModelForClapAndLoopRequest.error = error

            }
        }
      }
    
    // get detail page details in home page
    func getPostDetailsById(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .getPostDetailsById, body: postDict) { [weak self] (result: Result<GetPostDetails, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let getPostDetailsByIdModel):
            self.GetPostDetailsModel.value = getPostDetailsByIdModel

          case .failure(let error):
            self.GetPostDetailsModel.error = error

            }
        }
      }
    
    ///View count api call
    func viewedApiCallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .eyeshotByPostId, body: postDict) { [weak self] (result: Result<EyeshotCountModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let homeListData):
                // self.feedListData = []
                
                self.eyeShotModel.value = homeListData
            case .failure(let error):
                break
                //self.showErrorAlert(error: error.localizedDescription)
                //self.homeBaseModel.error = error
                
            }
        }
    }
}
