//
//  HomeViewModel.swift
//  Spark
//
//  Created by adhash on 10/07/21.
//

import Foundation

/**
 This view model is used to get the api call for home page
 */

class HomeViewModel: NSObject {
    
    private let networkManager = NetworkManager()

    let homeBaseModel = LiveData<homeBaseModel, Error>(value: nil)
    
    let homeClapModel = LiveData<ClapModel, Error>(value: nil)
    
    let contactSyncModel = LiveData<DataOkModel, Error>(value: nil)
    
    let checkThreadLimitModel = LiveData<CreatePostModel, Error>(value: nil)
    
    let checkThreadLimitModelForClapAndLoopRequest = LiveData<CreatePostModel, Error>(value: nil)

    let GetPostDetailsModel = LiveData<GetPostDetails, Error>(value: nil)
    
    let eyeShotModel = LiveData<EyeshotCountModel, Error>(value: nil)

    
    var feedListData = [HomeFeeds]()
    
    
    /// call home page api with feeds data
    func homeRefreshApiCall(postDict:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .home, body: postDict) { [weak self] (result: Result<homeBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let homeListData):
            self.feedListData = []
            if homeListData.data?.feeds?.count ?? 0 > 0 {
                self.feedListData.append(contentsOf: homeListData.data?.feeds ?? [HomeFeeds]())
            }
            self.homeBaseModel.value = homeListData
          case .failure(let error):
            //self.showErrorAlert(error: error.localizedDescription)
            self.homeBaseModel.error = error
                
            }
        }
      }
    
    /// call home list api call to set twith collectionview inside home page with loader
    func homeListApiCall(postDict:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .home, body: postDict) { [weak self] (result: Result<homeBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let homeListData):
           // self.feedListData = []
            if homeListData.data?.feeds?.count ?? 0 > 0 {
                self.feedListData.append(contentsOf: homeListData.data?.feeds ?? [HomeFeeds]())
            }
            self.homeBaseModel.value = homeListData
          case .failure(let error):
            //self.showErrorAlert(error: error.localizedDescription)
            self.homeBaseModel.error = error
                
            }
        }
      }
    
    
    
    /// call home list api call to set twith collectionview inside home page without loader
    func homeListApiCallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .home, body: postDict) { [weak self] (result: Result<homeBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let homeListData):
                // self.feedListData = []
                if homeListData.data?.feeds?.count ?? 0 > 0 {
                    self.feedListData.append(contentsOf: homeListData.data?.feeds ?? [HomeFeeds]())
                }
                self.homeBaseModel.value = homeListData
            case .failure(let error):
                //self.showErrorAlert(error: error.localizedDescription)
                self.homeBaseModel.error = error
                
            }
        }
    }
    
    
    ///Viewed api call without loader
    func viewedApiCallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .eyeshotByPostId, body: postDict) { [weak self] (result: Result<EyeshotCountModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let eyeShotData):
                // self.feedListData = []
                
                self.eyeShotModel.value = eyeShotData
            case .failure(let error):
                break
                //self.showErrorAlert(error: error.localizedDescription)
                //self.homeBaseModel.error = error
                
            }
        }
    }
    
    
    /// Show the error alert
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            
            CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                                   message: error,
                                                   alertType: .oneButton(),
                                                   alertRadius: 30,
                                                   btnRadius: 20)
        }
    }
    
    
    /// Show the home clap api
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
    
    /// Check the thread limit api call
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
    
    
    /// Get post detail by id in home page
    func getPostDetailsById(postDict:[String:Any]) {

        networkManager.postNoLoading(port: 1, endpoint: .getPostDetailsById, body: postDict) { [weak self] (result: Result<GetPostDetails, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let getPostDetailsByIdModel):
            self.GetPostDetailsModel.value = getPostDetailsByIdModel

          case .failure(let error):
            self.GetPostDetailsModel.error = error

            }
        }
      }
    
    
    ///  Get the home feeds data with the indexPath to get the news card view model
    func homeFeedsData(indexpath:IndexPath) -> NewsCardViewModel {
        var itemModel : HomeFeeds?
        if feedListData.count > 0 {
            itemModel = feedListData[indexpath.item]
        }
        return NewsCardViewModel(withModel: itemModel, withHomeModel: feedListData)
    }

    
}
