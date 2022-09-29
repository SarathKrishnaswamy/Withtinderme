//
//  PaymentHistoryData.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import Foundation


struct PaymentHistoryData : Codable {
    let totalAmount :String?
    let list : [PaymentHistoryList]?
    let amountTransferred :String?
    let paginator : PaymentHistoryPaginator?

    enum CodingKeys: String, CodingKey {

        case totalAmount = "totalAmount"
        case list = "list"
        case amountTransferred = "amountTransferred"
        case paginator = "paginator"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalAmount = try values.decodeIfPresent(String.self, forKey: .totalAmount)
        list = try values.decodeIfPresent([PaymentHistoryList].self, forKey: .list)
        amountTransferred = try values.decodeIfPresent(String.self, forKey: .amountTransferred)
        paginator = try values.decodeIfPresent(PaymentHistoryPaginator.self, forKey: .paginator)
        
    }

}
