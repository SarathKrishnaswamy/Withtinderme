//
//  BubbleTagListViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 18/08/21.
//

import UIKit

/**
 The bubble tag list view model used get the api call of bubble tag list
 */
class BubbleTagListViewModel {
    
    private let networkManager = NetworkManager()
        
    let tagSearchModel = LiveData<BubbleTagListDetail, Error>(value: nil)
        
    var tagListData = [BubbleTagListDetailList]()
    
    func getSearchTagList(postDict:[String:Any],isBool:Bool) {
        
        networkManager.post(port: 1, endpoint: .bubbleTagList, body: postDict) { [weak self] (result: Result<BubbleTagListDetail, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let bubbleTagListData):
                if (bubbleTagListData.data?.list?.count ?? 0 > 0 && !isBool) {
                    self.tagListData.append(contentsOf: bubbleTagListData.data?.list ?? [BubbleTagListDetailList]())
                } else {
                    self.tagListData.removeAll()
                    self.tagListData.append(contentsOf: bubbleTagListData.data?.list ?? [BubbleTagListDetailList]())
                }
            self.tagSearchModel.value = bubbleTagListData
                debugPrint("success")
                
            case .failure(let error):
                self.tagSearchModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
}
