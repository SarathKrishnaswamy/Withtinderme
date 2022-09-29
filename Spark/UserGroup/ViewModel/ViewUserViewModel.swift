//
//  ViewUserViewModel.swift
//  Spark me
//
//  Created by adhash on 17/09/21.
//

import Foundation
/**
 
 */
final class ViewUserViewModel {
    
    private let networkManager = NetworkManager()
    
    let userViewModel = LiveData<UserViewBase, Error>(value: nil)

    var userListData = [ViewUsers]()
    
    func viewUserViewAPICall(postDict:[String:Any],type:Int) {
        
        networkManager.post(port: 1, endpoint: type == 1 ? .viewList : .homeList , body: postDict) { [weak self] (result: Result<UserViewBase, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let bubbleData):
                if bubbleData.data?.users?.count ?? 0 > 0 {
                    self.userListData.append(contentsOf: bubbleData.data?.users ?? [ViewUsers]())
                    debugPrint(self.userListData)

                }
                self.userViewModel.value = bubbleData
            case .failure(let error):
                self.userViewModel.error = error
                
            }
        }
    }
    
    func userListData(indexpath:IndexPath) -> UserGroupTableViewCellModel {
        var itemModel : ViewUsers?
        if userViewModel.value?.data?.users?.count ?? 0 > 0 {
         itemModel = userListData[indexpath.row]
        }
        return UserGroupTableViewCellModel(withModel: itemModel)
    }
}
