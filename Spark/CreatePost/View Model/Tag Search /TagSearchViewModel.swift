//
//  TagSearchViewModel.swift
//  Spark
//
//  Created by adhash on 19/07/21.
//

import Foundation
/** This View model class is used to set the all api calls of tag search model*/
class TagSearchViewModel: NSObject {
    
    private let networkManager = NetworkManager()
    
    let tagSearchModel = LiveData<TagSearchModel, Error>(value: nil)
    
    let bubbleTagList = LiveData<BubbleTagListDetail, Error>(value: nil)
    
    var bubbleLstArray = [BubbleTagListDetail]()
    
    var tagListData = [TagsList]()
    
    /// Get the tag list and append to the array with loader
    func getSearchTagList(postDict:[String:Any],isBool:Bool) {
        
        networkManager.post(port: 1, endpoint: .gettagsForPost, body: postDict) { [weak self] (result: Result<TagSearchModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let closedConnectionListData):
                if (closedConnectionListData.data?.tagsList?.count ?? 0 > 0 && !isBool) {
                    self.tagListData.append(contentsOf: closedConnectionListData.data?.tagsList ?? [TagsList]())
                } else {
                    self.tagListData.removeAll()
                    self.tagListData.append(contentsOf: closedConnectionListData.data?.tagsList ?? [TagsList]())
                }
                self.tagSearchModel.value = closedConnectionListData
                debugPrint("success")
                
            case .failure(let error):
                self.tagSearchModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    /// Get the tag list and append to the array without loader
    func getSearchTagListNoLoading(postDict:[String:Any],isBool:Bool) {
        
        networkManager.postNoLoading(port: 1, endpoint: .gettagsForPost, body: postDict) { [weak self] (result: Result<TagSearchModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let closedConnectionListData):
                if (closedConnectionListData.data?.tagsList?.count ?? 0 > 0 && !isBool) {
                    self.tagListData.append(contentsOf: closedConnectionListData.data?.tagsList ?? [TagsList]())
                } else {
                    self.tagListData.removeAll()
                    self.tagListData.append(contentsOf: closedConnectionListData.data?.tagsList ?? [TagsList]())
                }
                self.tagSearchModel.value = closedConnectionListData
                debugPrint("success")
                
            case .failure(let error):
                self.tagSearchModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    /// Get the Bubble tag list in the array
    func getBubbleTagList() {
        
        networkManager.get(port: 1, endpoint: .bubbleTagList) { [weak self] (result: Result<BubbleTagListDetail, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let tagListData):
                self.bubbleLstArray.append(tagListData)
                self.bubbleTagList.value = tagListData
                debugPrint("success")

            case .failure(let error):
                self.bubbleTagList.error = error
                debugPrint("success")
            }
        }
    }
}
