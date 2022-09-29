//
//  MemberListDetailViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 22/08/21.
//

import UIKit

/**
 This view model is used to set the member list type and member list api calls
 */
class MemberListDetailViewModel {
    
    private let networkManager = NetworkManager()
    
    let memberListBaseModel = LiveData<MemberListBaseModel, Error>(value: nil)
    var memberListdata = [MembersListDetail]()
    
    func getMemberList(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .threadMemberList, body: postDict) { [weak self] (result: Result<MemberListBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let memberListData):
               // self.memberListdata = []
                if memberListData.data?.membersList?.count ?? 0 > 0{
                    self.memberListdata.append(contentsOf: memberListData.data?.membersList ?? [MembersListDetail]())
                }
//
//                if timelineData.data?.feeds?.count ?? 0 > 0 {
//                    self.feedListData.append(contentsOf: timelineData.data?.feeds ?? [ProfileTimelineFeeds]())
//                }
                self.memberListBaseModel.value = memberListData
                debugPrint("success")
                
            case .failure(let error):
                self.memberListBaseModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    func getMemberListRemoveDuplicates(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .threadMemberList, body: postDict) { [weak self] (result: Result<MemberListBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let memberListData):
                self.memberListdata = []
                if memberListData.data?.membersList?.count ?? 0 > 0{
                    self.memberListdata.append(contentsOf: memberListData.data?.membersList ?? [MembersListDetail]())
                }
//
//                if timelineData.data?.feeds?.count ?? 0 > 0 {
//                    self.feedListData.append(contentsOf: timelineData.data?.feeds ?? [ProfileTimelineFeeds]())
//                }
                self.memberListBaseModel.value = memberListData
                debugPrint("success")
                
            case .failure(let error):
                self.memberListBaseModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    func reportThreadUser(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .reportThreadUser, body: postDict) { [weak self] (result: Result<MemberListBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let memberListData):
                self.memberListdata = []
                if memberListData.data?.membersList?.count ?? 0 > 0{
                    self.memberListdata.append(contentsOf: memberListData.data?.membersList ?? [MembersListDetail]())
                }
//
//                if timelineData.data?.feeds?.count ?? 0 > 0 {
//                    self.feedListData.append(contentsOf: timelineData.data?.feeds ?? [ProfileTimelineFeeds]())
//                }
                self.memberListBaseModel.value = memberListData
                debugPrint("success")
                
            case .failure(let error):
                self.memberListBaseModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
}
