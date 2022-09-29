//
//  PaymentHistoryViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import Foundation

final class PaymentHistoryViewModel {
    
    private let networkManager = NetworkManager()
    
    let paymentModel = LiveData<PaymentHistoryModel, Error>(value: nil)
    let paymentBreakUpModel = LiveData<PaymentHistoryDetailModel, Error>(value: nil)
    
    
        
    var paymentListData = [PaymentHistoryList]()
    
    //var recentConversationList = [RecentConversationList]()
    
    func paymentPaidListApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .getTransDetailsByType, body: postDict) { [weak self] (result: Result<PaymentHistoryModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let paymentData):
                if paymentData.data?.list?.count ?? 0 > 0 {
                    self.paymentListData.append(contentsOf: paymentData.data?.list ?? [PaymentHistoryList]())
                }
                self.paymentModel.value = paymentData
            case .failure(let error):
                self.paymentModel.error = error
                
            }
        }
    }
    
    
    func paymentPaidDetailApiCall(postDict:[String:Any]) {
        
        networkManager.post(port: 1, endpoint: .byId, body: postDict) { [weak self] (result: Result<PaymentHistoryDetailModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let paymentData):
                
                self.paymentBreakUpModel.value = paymentData
            case .failure(let error):
                self.paymentBreakUpModel.error = error
                
            }
        }
    }
    
    
    
    //NoLoader
    
    func bubbleListApiCallNoLoading(postDict:[String:Any]) {
        
        networkManager.postNoLoading(port: 1, endpoint: .getTransDetailsByType, body: postDict) { [weak self] (result: Result<PaymentHistoryModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let paymentData):
                if paymentData.data?.list?.count ?? 0 > 0 {
                    self.paymentListData.append(contentsOf: paymentData.data?.list ?? [PaymentHistoryList]())
                }
                self.paymentModel.value = paymentData
            case .failure(let error):
                self.paymentModel.error = error
                
            }
        }
    }
    
   
    
//    func bubblenData(indexpath:IndexPath) -> BubbleCellViewModel {
//        var itemModel : BubbleList?
//        if paymentListData.count > 0 {
//         itemModel = paymentListData[indexpath.item]
//        }
//        return BubbleCellViewModel(withModel: itemModel, withBubbleModel: paymentListData)
//    }
    
    

}

