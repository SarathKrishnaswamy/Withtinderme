//
//  BubbleCellViewModel.swift
//  Spark me
//
//  Created by adhash on 18/08/21.
//

import Foundation

/**
 This view model is used to set the bubble list from bubble view cell
 */
final class BubbleCellViewModel {
    
    var bubbleListData:BubbleList?
    
    var bubbleList = [BubbleList]()
    
    private let networkManager = NetworkManager()
    
    var bubbleDeleteModel = LiveData<BubbleDeleteModel, Error>(value: nil)

    init(withModel:BubbleList?,withBubbleModel:[BubbleList]?)
      {
        bubbleListData = withModel
        bubbleList = withBubbleModel ?? [BubbleList]()
      }
    
    
    
    func bubbleDeleteApiCall(postDict:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .bubbleDelete, body: postDict) { [weak self] (result: Result<BubbleDeleteModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let bubbleDeleteData):
            self.bubbleDeleteModel.value = bubbleDeleteData
          case .failure(let error):
            self.bubbleDeleteModel.error = error
                
            }
        }
      }

    //bubble Name
    public var getBubbleImage: String {

        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.bubbleListData?.profilePic ?? "")"
        
        return url
    }
    
    //bubble Name
    public var getVisibleDate: Int {
        return self.bubbleListData?.visibleDate ?? 0
    }
    
    //bubble unique Id
    public var getBubbleId: String {
        return self.bubbleListData?._id ?? ""
    }
    
    public var isAnonymousUser: Bool {
        return self.bubbleListData?.allowAnonymous ?? false
    }
    
    //bubble name
    public var getBubbleName: String {
        return self.bubbleListData?.displayName ?? ""
    }
    
    //Get gender
    public var getGender: Int {
        return self.bubbleListData?.gender ?? 0
    }

}
