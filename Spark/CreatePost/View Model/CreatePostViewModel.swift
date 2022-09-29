//
//  CreatePostViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 10/07/21.
//

import UIKit

/**
 This  view model is used to set the api calls for create post
 */
class CreatePostViewModel: NSObject {
    
    private let networkManager = NetworkManager()
    
    let createPostModel = LiveData<CreatePostModel, Error>(value: nil)
    
    /// Call the create post Api
    func createPostApiCall(postDict:[String:Any]){
        
        networkManager.post(port: 1, endpoint: .createPost, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let timelineData):
                self.createPostModel.value = timelineData
                debugPrint("success")
                
            case .failure(let error):
                self.createPostModel.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    /// Call the monetize post Api
    func monetizeRepostApiCall(postDict:[String:Any]){
        
        networkManager.post(port: 1, endpoint: .monetizeRepost, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let timelineData):
                self.createPostModel.value = timelineData
                debugPrint("success")
                
            case .failure(let error):
                self.createPostModel.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    /// Call the repost monetize post Api
    func repostMonetizeApiCall(postDict:[String:Any]){
        
        networkManager.post(port: 1, endpoint: .saveMediaByPostId, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let timelineData):
                self.createPostModel.value = timelineData
                debugPrint("success")
                
            case .failure(let error):
                self.createPostModel.error = error
                debugPrint(error.localizedDescription)
                debugPrint("failed")
                
            }
        }
    }
}
