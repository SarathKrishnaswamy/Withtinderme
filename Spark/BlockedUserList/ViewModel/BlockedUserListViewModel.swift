//
//  BlockUserViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit

class BlockedUserListViewModel {
    
    /// Call the server model as network manager
    private let networkManager = NetworkManager()
    
    ///set the model list as tuple for BlockedUserListModel
    let blockedUserList = LiveData<BlockedUserListModel, Error>(value: nil)
    
    
    /// Set the data ok model for observe the datas
    let blockSelectedUser = LiveData<DataOkModel, Error>(value: nil)
    
    /// Set the BlockedUserListModelUsers in the array
    var userList = [BlockedUserListModelUsers]()
    
    
    /// Call the api of  "getBlockedUserList" to get the blocked user list using post method
    /// - Parameters:
    ///   - postDict: send the body to the api call as dictionary
    ///   - isSearch: It is used to search for boolean whether its from search or not.
    /// - This is used to load using loader to call the api
    func blockedUserListAPICall(postDict:[String:Any],isSearch:Bool) {
        
        networkManager.post(port: 1, endpoint: .getBlockedUserList, body: postDict) { [weak self] (result: Result<BlockedUserListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let blockedUsers):
                if blockedUsers.data?.users?.count ?? 0 > 0 && !isSearch {
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }else{
                    self.userList.removeAll()
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }
                self.blockedUserList.value = blockedUsers
                debugPrint("success")
                
            case .failure(let error):
                self.blockedUserList.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    /// Call the api of  "getBlockedUserList" to get the blocked user list using post method
    /// - Parameters:
    ///   - postDict: send the body to the api call as dictionary
    ///   - isSearch: It is used to search for boolean whether its from search or not.
    /// - This is used to load without using loader to call the api
    //Loading without loader
    func blockedUserListAPICallNoLoading(postDict:[String:Any],isSearch:Bool) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getBlockedUserList, body: postDict) { [weak self] (result: Result<BlockedUserListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let blockedUsers):
                if blockedUsers.data?.users?.count ?? 0 > 0 && !isSearch {
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }else{
                    self.userList.removeAll()
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }
                self.blockedUserList.value = blockedUsers
                debugPrint("success")
                
            case .failure(let error):
                self.blockedUserList.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    
    
    /// Call the api of  "getBlockUserList" to get the blocked user list using post method
    /// - Parameters:
    ///   - postDict: send the body to the api call as dictionary
    ///   - isSearch: It is used to search for boolean whether its from search or not.
    /// - This is used to load using loader to call the api
    func blockUserAPICall(postDict:[String:Any],isSearch:Bool) {
        
        networkManager.post(port: 1, endpoint: .getBlockUserList, body: postDict) { [weak self] (result: Result<BlockedUserListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let blockedUsers):
                if blockedUsers.data?.users?.count ?? 0 > 0 && !isSearch {
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }else{
                    self.userList.removeAll()
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }
                self.blockedUserList.value = blockedUsers
                debugPrint("success")
                
            case .failure(let error):
                self.blockedUserList.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    
    
    /// Call the api of  "getBlockUserList" to get the blocked user list using post method
    /// - Parameters:
    ///   - postDict: send the body to the api call as dictionary
    ///   - isSearch: It is used to search for boolean whether its from search or not.
    /// - This is used to load Without using loader to call the api
    //Without Loader
    func blockUserAPICallNoLoading(postDict:[String:Any],isSearch:Bool) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getBlockUserList, body: postDict) { [weak self] (result: Result<BlockedUserListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let blockedUsers):
                if blockedUsers.data?.users?.count ?? 0 > 0 && !isSearch {
                   // self.userList = []
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }else{
                    self.userList.removeAll()
                    self.userList.append(contentsOf: blockedUsers.data?.users ?? [BlockedUserListModelUsers]())
                }
                self.blockedUserList.value = blockedUsers
                debugPrint("success")
                
            case .failure(let error):
                self.blockedUserList.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    
    /// Call the api of  "blockSelectedUser" to get the blocked user list using post method
    /// - Parameters:
    ///   - postDict: send the body to the api call as dictionary
    /// - Block the selected user using this dictionary
    func blockSelectedUserAPICall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .blockSelectedUser, body: postDict) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let blockedUsers):
                self.blockSelectedUser.value = blockedUsers
                debugPrint("success")
                
            case .failure(let error):
                self.blockSelectedUser.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    
    
    /// It is used to set the blocked user list using the indexpath
    /// - Parameter indexpath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    /// - Returns: It returns to cell model and set the values in the tableview cell.
    func BlockedUserList(indexpath:IndexPath) -> BlockedUserListTableViewCellViewModel {

        let itemModel = userList[indexpath.row]
        
        return BlockedUserListTableViewCellViewModel(withModel: itemModel )
    }
}
