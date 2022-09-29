//
//  FeedDetailsViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 13/08/21.
//

import UIKit

/// receibve the message from the delegation of details to receive the message
protocol receivedMessageDelegate : AnyObject {
    
    func receivedMessageDetails()
   
}

/**
 This view model is used to receive all the feed details with the api calls here.
 */
class FeedDetailsViewModel : NSObject {
    
    static let instance = FeedDetailsViewModel()
    
    private let networkManager = NetworkManager()
    
    let feedDetails = LiveData<FeedDetailClapModel, Error>(value: nil)
    
    let homeClapModel = LiveData<ClapModel, Error>(value: nil)
    
    let endConversationModel = LiveData<DataOkModel, Error>(value: nil)
    
    let conversationMessageList = LiveData<ConversationListModel, Error>(value: nil)
    
    let revealIdentityModel = LiveData<DataOkModel, Error>(value: nil)
    
    let checkTagStatus = LiveData<CheckTagStatus, Error>(value: nil)
    
    let clapThreadModel = LiveData<CreatePostModel, Error>(value: nil)
    
    var messageListArray:[ConversationList]? = [ConversationList]()
    
    var lastMsgId = ""
    
    let checkThreadLimitModel = LiveData<CreatePostModel, Error>(value: nil)
    
    weak var delegate:receivedMessageDelegate?
    
    let threadRequestModel = LiveData<ClappedBaseModel, Error>(value: nil)
    
    let deletePostModel = LiveData<DeletePostModel, Error>(value: nil)
    
    let reportPostModel = LiveData<ReportPopstModel, Error>(value: nil)
    
    ///Feed detail tableview cell
    func setUpPostDetails(indexPath: IndexPath) -> FeedDetailTableViewCellViewModel? {
        let itemModel = feedDetails.value?.data?.postDetails
        return FeedDetailTableViewCellViewModel(withModel: itemModel)
    }
    
    ///Collection view member list
    func setUpThreadMember(indexPath: Int) -> ThreadMemberCellViewModel? {
        let itemModel: MembersList?
        
        //        if feedDetails.value?.data?.membersTotal ?? 0 > 0{
        //            itemModel = feedDetails.value?.data?.membersList?[indexPath.item == 0 ? 0 : indexPath.item - 1]
        //        }else{
        itemModel = feedDetails.value?.data?.membersList?[indexPath == 0 ? 0 : indexPath - 1]
        //        }
        return ThreadMemberCellViewModel(withModel: itemModel)
        
    }
    
    /// Get all the feed details with the clap model to set the value of post detail
    func getFeedDetails(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getPostDetail, body: params) { [weak self] (result: Result<FeedDetailClapModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
               
                self.feedDetails.value = saveData
                
            case .failure(let error):
                self.feedDetails.error = error
                
            }
        }
    }
    
    
    /// Get all the feed details with the clap model to set the value of post detail without loader
    func getFeedDetailsNoLoading(params:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getPostDetail, body: params) { [weak self] (result: Result<FeedDetailClapModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
               
                self.feedDetails.value = saveData
                
            case .failure(let error):
                self.feedDetails.error = error
                
            }
        }
    }
    
    /// Get the member list post detail here with the feed detail clap model observer
    func getMemberListPostDetails(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getSelectedMemberPostDetail, body: params) { [weak self] (result: Result<FeedDetailClapModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
                self.feedDetails.value = saveData
                
            case .failure(let error):
                self.feedDetails.error = error
                
            }
        }
    }
    
    /// Get the member list post detail here with the feed detail clap model observer with no loader
    func getMemberListPostDetailsNoLoading(params:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getSelectedMemberPostDetail, body: params) { [weak self] (result: Result<FeedDetailClapModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
                self.feedDetails.value = saveData
                
            case .failure(let error):
                self.feedDetails.error = error
                
            }
        }
    }
    
    
    /// Home clap api with home model
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
    
    /// Exit from loop api call
    func endConversationAPICall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .endConversation, body: params) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let saveData):
                self.endConversationModel.value = saveData
            case .failure(let error):
                self.endConversationModel.error = error
                
            }
        }
    }
    
    /// get conversation message list
    func getConversationMessageList(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .conversationCommentsList, body: params) { [weak self] (result: Result<ConversationListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let conversationListModelData):
                if conversationListModelData.data?.conversationList?.count ?? 0 > 0 {
                    //self.messageListArray?.append(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList]())
                    self.messageListArray?.insert(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList](), at: 0)
                }
                //self.messageListArray = conversationListModelData.data?.conversationList
                self.conversationMessageList.value = conversationListModelData
                
            case .failure(let error):
                self.conversationMessageList.error = error
                
            }
        }
    }
    
    ///No Loading get conversation modelapi call
    func getConversationMessageListNoLoading(params:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .conversationCommentsList, body: params) { [weak self] (result: Result<ConversationListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let conversationListModelData):
                if conversationListModelData.data?.conversationList?.count ?? 0 > 0 {
                    //self.messageListArray?.append(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList]())
                    self.messageListArray?.insert(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList](), at: 0)
                }
                //self.messageListArray = conversationListModelData.data?.conversationList
                self.conversationMessageList.value = conversationListModelData
                
            case .failure(let error):
                self.conversationMessageList.error = error
                
            }
        }
    }
    
    ///Deletepost api call
    func deletePostApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .deletePost, body: postDict) { [weak self] (result: Result<DeletePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let homeListData):
                self.deletePostModel.value = homeListData
                
            case .failure(let error):
                self.deletePostModel.error = error
                
            }
        }
    }
    
    ///Report post api call
    func reporstPostApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .reportPostUser, body: postDict) { [weak self] (result: Result<ReportPopstModel
                                                                                               , Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let homeListData):
                self.reportPostModel.value = homeListData
                
            case .failure(let error):
                self.reportPostModel.error = error
                
            }
        }
    }
    
    
//    func getConversationMessageList(params:[String:Any], id:Int) {
//
//        networkManager.post(port: 1, endpoint: .conversationCommentsList, body: params) { [weak self] (result: Result<ConversationListModel, Error>) in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let conversationListModelData):
//                //
//                if conversationListModelData.data?.conversationList?.count ?? 0 > 0 {
//                    if id == 1{
//                     self.messageListArray = []
//                        //let obj =
//                        //if !(messageListArray?.containsSameElements(as: conversationListModelData.data?.conversationList ?? [ConversationList]()) ?? false){
//                            self.messageListArray?.insert(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList](), at: 0)
//                        //}
//                    //self.messageListArray?.append(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList]())
//
//                        //self.messageListArray?.unique()
//                    }
//                    else{
//                     self.messageListArray?.insert(contentsOf: conversationListModelData.data?.conversationList ?? [ConversationList](), at: 0)
//                    }
//                }
//                //self.messageListArray = conversationListModelData.data?.conversationList
//                self.conversationMessageList.value = conversationListModelData
//
//            case .failure(let error):
//                self.conversationMessageList.error = error
//
//            }
//        }
//    }
    
    /// Reveal the identity api call
    func revealIdentityAPICall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .threadReveal, body: params) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let conversationListModelData):
                self.revealIdentityModel.value = conversationListModelData
                
            case .failure(let error):
                self.revealIdentityModel.error = error
                
            }
        }
    }
    
    /// Receive the message by listening if socket connected
    
    //    // MARK: - Socket IO Methods & Methods related to Chat Updates
    func receiveMessage() {
        
        if !SocketIOManager.sharedSocketInstance.isConnected {
            SocketIOManager.sharedSocketInstance.ConnectsToSocket()
        }
        
        SocketIOManager.sharedSocketInstance.newsocket.on("receive_message") { data, ack in
           
            print("Received Message 1",data[0] as? NSDictionary)
            
            if (data[0] as? NSDictionary)?.value(forKey: "msg_id") as? String ?? "" == self.lastMsgId || (data[0] as? NSDictionary)?.value(forKey: "to") as? String ?? "" != SessionManager.sharedInstance.threadId {
                return
            }
            
            let receivedMsgDict = data[0] as? NSDictionary
            let jsonDecoder = JSONDecoder()
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: receivedMsgDict ?? NSDictionary(), options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                self.lastMsgId = (data[0] as? NSDictionary)?.value(forKey: "msg_id") as? String ?? ""
                let model = try jsonDecoder.decode(ConversationList.self, from: jsonData)
                // here "decoded" is of type `Any`, decoded from JSON data
                
                self.messageListArray?.append(model)
                
                self.delegate?.receivedMessageDetails()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Check the tag status of the api call
    func checkTagStatusAPICall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .checkTagStatus, body: params) { [weak self] (result: Result<CheckTagStatus, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let checkTagStatusData):
                self.checkTagStatus.value = checkTagStatusData
            case .failure(let error):
                self.checkTagStatus.error = error
                
            }
        }
    }
    
    /// Check thread limit api call
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
    
    /// Check theb clap mthread api call with params
    func clapThreadApiCall(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .clapThread, body: params) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let createPostData):
                self.clapThreadModel.value = createPostData
            case .failure(let error):
                self.clapThreadModel.error = error
                
            }
        }
    }
    
    /// get the bubble list id with clap model
    func getbubbleListById(params:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getbubbleListById, body: params) { [weak self] (result: Result<FeedDetailClapModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let createPostData):
                self.feedDetails.value = createPostData
            case .failure(let error):
                self.feedDetails.error = error
                
            }
        }
    }
    
    
    /// Send the thread request of base model
    func sendThreadRequest(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .saveThreadrequest, body: postDict) { [weak self] (result: Result<ClappedBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let homeListData):
            self.threadRequestModel.value = homeListData

          case .failure(let error):
            self.threadRequestModel.error = error

            }
        }
      }
    
    
    /// Check the monetize api call with create post model
    func chcekMonetizeLimitApiCall(postDict:[String:Any]){
        networkManager.post(port: 1, endpoint: .checkMonetizePostLimit, body: postDict) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let checkThreadModel):
            self.checkThreadLimitModel.value = checkThreadModel

          case .failure(let error):
            self.checkThreadLimitModel.error = error

            }
        }
    }
    
    /// Check the clap thread monetize api call 
    func clapThreadMonetizeApiCall(params:[String:Any]) {
        networkManager.post(port: 1, endpoint: .clapMonetizeThread, body: params) { [weak self] (result: Result<CreatePostModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let createPostData):
                self.clapThreadModel.value = createPostData
            case .failure(let error):
                self.clapThreadModel.error = error
                
            }
        }
    }
}


extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
