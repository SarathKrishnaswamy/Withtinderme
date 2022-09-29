//
//  ConnectionListUserProfileViewModel.swift
//  Spark me
//
//  Created by adhash on 31/08/21.
//

import Foundation

/**
This viewmodel is used to set save model of profile api call and set the loader call with time line image set
 */

class ConnectionListUserProfileViewModel: NSObject {
    
    private let networkManager = NetworkManager()

    let profileModel = LiveData<GetProfile, Error>(value: nil)
    let timelineModel = LiveData<ProfileTimelineBaseModel, Error>(value: nil)
    var feedListData = [ProfileTimelineFeeds]()

    let saveModel = LiveData<SaveProfileModel, Error>(value: nil)
    
    func getProfileAPICall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getProfileById, body: postDict) { [weak self] (result: Result<GetProfile, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let profileData):
                self.profileModel.value = profileData
                debugPrint("success")

            case .failure(let error):
                self.profileModel.error = error
                debugPrint("failed")

                
            }
        }
    }
    
    //NoLoader
    func getProfileAPICallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getProfileById, body: postDict) { [weak self] (result: Result<GetProfile, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let profileData):
                self.profileModel.value = profileData
                debugPrint("success")

            case .failure(let error):
                self.profileModel.error = error
                debugPrint("failed")

                
            }
        }
    }
    
    func getMyTimelineAPICall(postDict:[String:Any]){
        
        networkManager.post(port: 1, endpoint: .timelineById, body: postDict) { [weak self] (result: Result<ProfileTimelineBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let timelineData):
                if timelineData.data?.feeds?.count ?? 0 > 0 {
                    self.feedListData.append(contentsOf: timelineData.data?.feeds ?? [ProfileTimelineFeeds]())
                }
                self.timelineModel.value = timelineData

                debugPrint("success")

            case .failure(let error):
                self.timelineModel.error = error
                debugPrint("failed")

                
            }
        }
    }
    
    //NOloading
    func getMyTimelineAPICallNoLoading(postDict:[String:Any]){
        
        networkManager.postNoLoading(port: 1, endpoint: .timelineById, body: postDict) { [weak self] (result: Result<ProfileTimelineBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let timelineData):
                if timelineData.data?.feeds?.count ?? 0 > 0 {
                    self.feedListData.append(contentsOf: timelineData.data?.feeds ?? [ProfileTimelineFeeds]())
                }
                self.timelineModel.value = timelineData

                debugPrint("success")

            case .failure(let error):
                self.timelineModel.error = error
                debugPrint("failed")

                
            }
        }
    }
}
