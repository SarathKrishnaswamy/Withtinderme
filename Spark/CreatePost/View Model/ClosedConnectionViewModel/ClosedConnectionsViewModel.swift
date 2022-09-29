//
//  ClosedConnectionsViewModel.swift
//  Spark
//
//  Created by adhash on 17/07/21.
//

import Foundation

/**
 This view model is used to call the close friends list with array
 */

class ClosedConnectionsViewModel: NSObject {
    
    private let networkManager = NetworkManager()
    
    let closedViewModel = LiveData<ClosedConnectionListModel, Error>(value: nil)
    
    var closedConnectionFriendsData = [ClosedConnectionFriends]()
    
    
    /// Set the closed connection method to append with array with loader
    func closedConnectionList(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .closedConnectionList, body: postDict) { [weak self] (result: Result<ClosedConnectionListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let closedConnectionListData):
                
                if closedConnectionListData.data?.friends?.count ?? 0 > 0 {
                    if self.closedConnectionFriendsData.count > 0 {
                        self.closedConnectionFriendsData.removeAll()
                    }
                    self.closedConnectionFriendsData.append(contentsOf: closedConnectionListData.data?.friends ??  [ClosedConnectionFriends]())
                }else{
                    if self.closedConnectionFriendsData.count > 0 {
                        self.closedConnectionFriendsData.removeAll()
                    }
                }
                
                self.closedViewModel.value = closedConnectionListData
                debugPrint("success")
                
            case .failure(let error):
                self.closedViewModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    /// Set the closed connection method to append with array without loader
    func closedConnectionListNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .closedConnectionList, body: postDict) { [weak self] (result: Result<ClosedConnectionListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let closedConnectionListData):
                //self.closedConnectionFriendsData = []
                if closedConnectionListData.data?.friends?.count ?? 0 > 0 {
                    //
                    self.closedConnectionFriendsData.append(contentsOf: closedConnectionListData.data?.friends ??  [ClosedConnectionFriends]())
                }
                    
                
                self.closedViewModel.value = closedConnectionListData
                debugPrint("success")
                
            case .failure(let error):
                self.closedViewModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    
    func closedConnectionListSearchNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .closedConnectionList, body: postDict) { [weak self] (result: Result<ClosedConnectionListModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let closedConnectionListData):
                self.closedConnectionFriendsData = []
                if closedConnectionListData.data?.friends?.count ?? 0 > 0 {
//                    if self.closedConnectionFriendsData.count > 0 {
//                        self.closedConnectionFriendsData.removeAll()
//                    }
                self.closedConnectionFriendsData.append(contentsOf: closedConnectionListData.data?.friends ??  [ClosedConnectionFriends]())
                }
                    //else{
//                    if self.closedConnectionFriendsData.count > 0 {
//                        self.closedConnectionFriendsData.removeAll()
//                    }
//                }
                
                self.closedViewModel.value = closedConnectionListData
                debugPrint("success")
                
            case .failure(let error):
                self.closedViewModel.error = error
                debugPrint("failed")
                
                
            }
        }
    }
    
    //
    func closedConnectionFriendsData(indexpath:IndexPath) -> ConnectionListCellViewModel {
        var itemModel : ClosedConnectionFriends?
        if closedConnectionFriendsData.count > 0 {
         itemModel = closedConnectionFriendsData[indexpath.row]
        }
        
        return ConnectionListCellViewModel(withModel: itemModel )
    }
}
