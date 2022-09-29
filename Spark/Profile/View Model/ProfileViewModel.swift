//
//  ProfileViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 07/07/21.
//

import UIKit

class ProfileViewModel: NSObject {

    private let networkManager = NetworkManager()

    let profileModel = LiveData<GetProfile, Error>(value: nil)
    let timelineModel = LiveData<ProfileTimelineBaseModel, Error>(value: nil)
    var feedListData = [ProfileTimelineFeeds]()

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
    
    func getProfileAPICall(){
        
        networkManager.getnoLoading(port: 1, endpoint: .getProfile) { [weak self] (result: Result<GetProfile, Error>) in
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
        
        networkManager.postNoLoading(port: 1, endpoint: .getMyPostedTimeline, body: postDict) { [weak self] (result: Result<ProfileTimelineBaseModel, Error>) in
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
    
    
    func getNFTListAPICall(postDict:[String:Any]){
        
        networkManager.post(port: 1, endpoint: .getNFTList, body: postDict) { [weak self] (result: Result<ProfileTimelineBaseModel, Error>) in
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
