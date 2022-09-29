//
//  BubbleViewModel.swift
//  Spark me
//
//  Created by adhash on 18/08/21.
//

import Foundation

/**
 This class is used to set the model view and api calls for bubble view
 */
final class BubbleViewModel {
    
    private let networkManager = NetworkManager()
    
    let bubbleModel = LiveData<BubbleModel, Error>(value: nil)
    
    let recentConversationModel = LiveData<RecentConversationBaseModel, Error>(value: nil)
        
    var bubbleListData = [BubbleList]()
    
    var recentConversationList = [RecentConversationList]()
    
    func bubbleListApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .threadBubbleList, body: postDict) { [weak self] (result: Result<BubbleModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let bubbleData):
                if bubbleData.data?.bubbleList?.count ?? 0 > 0 {
                    self.bubbleListData.append(contentsOf: bubbleData.data?.bubbleList ?? [BubbleList]())
                }
                self.bubbleModel.value = bubbleData
            case .failure(let error):
                self.bubbleModel.error = error
                
            }
        }
    }
    
    ///No Loader has been needed here
    func bubbleListApiCallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .threadBubbleList, body: postDict) { [weak self] (result: Result<BubbleModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let bubbleData):
                if bubbleData.data?.bubbleList?.count ?? 0 > 0 {
                    self.bubbleListData.append(contentsOf: bubbleData.data?.bubbleList ?? [BubbleList]())
                }
                self.bubbleModel.value = bubbleData
            case .failure(let error):
                self.bubbleModel.error = error
                
            }
        }
    }
    
    
    ///No Loader has been needed here
    func bubbleListApiCallNoLoadingSearch(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .threadBubbleList, body: postDict) { [weak self] (result: Result<BubbleModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let bubbleData):
                self.bubbleListData = []
                if bubbleData.data?.bubbleList?.count ?? 0 > 0 {
                    self.bubbleListData.append(contentsOf: bubbleData.data?.bubbleList ?? [BubbleList]())
                }
                self.bubbleModel.value = bubbleData
            case .failure(let error):
                self.bubbleModel.error = error
                
            }
        }
    }
    
    /// CVall recent loops api and set to the model class without loader
    func recentConversationListApiCall(postDict:[String:Any],isSearch:Bool,isLoadMore:Bool) {
        
        networkManager.postNoLoading(port: 1, endpoint: .threadconversationList, body: postDict) { [weak self] (result: Result<RecentConversationBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let recentConversationModel):
                
                if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                    if isSearch && isLoadMore {
                        if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                            //self.recentConversationList.removeAll()
                            debugPrint(self.recentConversationList.count)
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                            debugPrint(self.recentConversationList.count)
                        } else {
                            //self.recentConversationList.removeAll()
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                        }
                    }else if isSearch {
                        if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                            self.recentConversationList.removeAll()
                            debugPrint(self.recentConversationList.count)
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                            debugPrint(self.recentConversationList.count)
                        } else {
                            //self.recentConversationList.removeAll()
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                        }
                    }
                    else{
                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                    }
                    
                }
                else{
                        //self.recentConversationList.removeAll()
                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                    }
                
//                if recentConversationModel.data?.conversationList?.count ?? 0 > 0 && !isSearch {
//                    self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
//                }else{
//                    //if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
//                        self.recentConversationList.removeAll()
//                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
//                   // }
//                }
                self.recentConversationModel.value = recentConversationModel
            debugPrint(recentConversationModel)
            case .failure(let error):
                self.recentConversationModel.error = error
                debugPrint(error)
            }
        }
    }
    
    
    /// Recent loops api call withLoader
    func recentConversationListApiCallLoader(postDict:[String:Any],isSearch:Bool,isLoadMore:Bool) {
        
        
        
        networkManager.post(port: 1, endpoint: .threadconversationList, body: postDict) { [weak self] (result: Result<RecentConversationBaseModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let recentConversationModel):
                
                if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                    if isSearch && isLoadMore {
                        if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                            //self.recentConversationList.removeAll()
                            debugPrint(self.recentConversationList.count)
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                            debugPrint(self.recentConversationList.count)
                        } else {
                            //self.recentConversationList.removeAll()
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                        }
                    }else if isSearch {
                        if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
                            self.recentConversationList.removeAll()
                            debugPrint(self.recentConversationList.count)
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                            debugPrint(self.recentConversationList.count)
                        } else {
                            //self.recentConversationList.removeAll()
                            self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                        }
                    }
                    else{
                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                    }
                    
                }
                else{
                        //self.recentConversationList.removeAll()
                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
                    }
                
//                if recentConversationModel.data?.conversationList?.count ?? 0 > 0 && !isSearch {
//                    self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
//                }else{
//                    //if recentConversationModel.data?.conversationList?.count ?? 0 > 0 {
//                        self.recentConversationList.removeAll()
//                        self.recentConversationList.append(contentsOf: recentConversationModel.data?.conversationList ?? [RecentConversationList]())
//                   // }
//                }
                self.recentConversationModel.value = recentConversationModel
            debugPrint(recentConversationModel)
            case .failure(let error):
                self.recentConversationModel.error = error
                debugPrint(error)
            }
        }
    }
    
   
    /// Set the viewmodel cell using the bubble data with indexPath
    func bubblenData(indexpath:IndexPath) -> BubbleCellViewModel {
        var itemModel : BubbleList?
        if bubbleListData.count > 0 {
         itemModel = bubbleListData[indexpath.item]
        }
        return BubbleCellViewModel(withModel: itemModel, withBubbleModel: bubbleListData)
    }
    
    /// Set the viewmodel cell using the recent loops data with indexPath 
    func recentConversationData(indexpath:IndexPath) -> RecentConversationCellViewModel {
        var itemModel : RecentConversationList?
        if recentConversationList.count > 0 && indexpath.item - 1 <= recentConversationList.count{
            itemModel = recentConversationList[indexpath.item]
        }
        return RecentConversationCellViewModel(withModel: itemModel, withBubbleModel: recentConversationList)
    }

}
