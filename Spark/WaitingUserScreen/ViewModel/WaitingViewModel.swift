//
//  WaitingViewModel.swift
//  Spark me
//
//  Created by adhash on 02/09/21.
//

import Foundation

final class WaitingViewModel {

    private let networkManager = NetworkManager()
    
    let waitingModel = LiveData<waitingBaseModel, Error>(value: nil)
    
    let finalWaitingModel = LiveData<waitingBaseModel, Error>(value: nil)
    
    let contactSyncModel = LiveData<DataOkModel, Error>(value: nil)

    let approveStatusModel = LiveData<DataOkModel, Error>(value: nil)
    
    func contactSyncAPICall() {
        
        networkManager.get(port: 1, endpoint: .GetApprovedStatus) { [weak self] (result: Result<waitingBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
            
            case .success(let waitingData):
                self.waitingModel.value = waitingData
                //SessionManager.sharedInstance.settingData = settingData
                debugPrint(waitingData)

            case .failure(let error):
                self.waitingModel.error = error
                debugPrint(error)
            }
        }
    }

    func contactSync(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .contactSync, body: postDict) { [weak self] (result: Result<waitingBaseModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let contactSyncData):
            self.finalWaitingModel.value = contactSyncData
               // SessionManager.sharedInstance.isContactSyncedOrNot = self.finalWaitingModel.value?.data?.isSyncContact ?? false

          case .failure(let error):
            self.finalWaitingModel.error = error

            }
        }
      }
    
    func getApproveStatusWithToken(postDict:[String:Any]) {

        networkManager.post(port: 1, endpoint: .approvedByToken, body: postDict) { [weak self] (result: Result<DataOkModel, Error>) in
            guard let self = self else { return }

            switch result {
          case .success(let contactSyncData):
            self.approveStatusModel.value = contactSyncData

          case .failure(let error):
            self.approveStatusModel.error = error

            }
        }
      }
    
}
