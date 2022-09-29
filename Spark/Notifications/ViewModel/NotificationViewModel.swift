//
//  NotificationViewModel.swift
//  Life Hope
//
//  Created by adhash on 10/06/21.
//

import Foundation

/**
 This class is used to set the server calls  and call the models to set the data from api fro notificationViewModel
 */

final class NotificationViewModel {

    private let networkManager = NetworkManager()
    
    let notificationModel = LiveData<NotificationBase, Error>(value: nil)

    var notificstionListData = [NotificationList]()
    
    let notificationReadModel = LiveData<DataOkModel, Error>(value: nil)

    
    
    /// Call the api using post method for notify
    /// - Parameters:
    ///   - postDict: Using dictionary the body params has been passed
    ///   - isSearch: It is using Boolean params to be used as isSearch
    func notificationListApiCall(postDict:[String:Any],isSearch:Bool) {
    
        networkManager.postNoLoading(port: 1, endpoint: .notify, body: postDict) { [weak self] (result: Result<NotificationBase, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let notificationData):
            
            if notificationData.data?.list?.count ?? 0 > 0 && !isSearch {
                self.notificstionListData.append(contentsOf: notificationData.data?.list ?? [NotificationList]())
            }else{
                self.notificstionListData.removeAll()
                self.notificstionListData.append(contentsOf: notificationData.data?.list ?? [NotificationList]())
            }
            self.notificationModel.value = notificationData
          case .failure(let error):
            self.notificationModel.error = error
                
            }
        }
      }
    
   
    
    /// Accept or decline the api call using approveAccount
    /// - Parameter postDict: send body of parameter as dictionary
    func notificationReadApiCall(postDict:[String:Any]) {
    
        networkManager.post(port: 1, endpoint: .approveAccount, body: postDict) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let notificationReadData):
            
            self.notificationReadModel.value = notificationReadData
          case .failure(let error):
            self.notificationReadModel.error = error
                
            }
        }
      }
    
    
    /// It is used to set the notification data list using the indexpath
    /// - Parameter indexpath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    /// - Returns: It returns to cell model and set the values in the tableview cell.
    func notificationData(indexpath:IndexPath) -> NotificationCellViewModel {
        var itemModel : NotificationList?
        if notificstionListData.count > 0 {
         itemModel = notificstionListData[indexpath.row]
        }
        
        return NotificationCellViewModel(withModel: itemModel )
    }
}
