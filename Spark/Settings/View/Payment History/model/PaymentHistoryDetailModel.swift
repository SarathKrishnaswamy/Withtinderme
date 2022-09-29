//
//  PaymentHistoryDetailModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import Foundation
struct PaymentHistoryDetailModel : Codable {
    let isOk : Bool?
    let data : PostHistoryBreakupDetailData?

    enum CodingKeys: String, CodingKey {

        case isOk = "isOk"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
        data = try values.decodeIfPresent(PostHistoryBreakupDetailData.self, forKey: .data)
    }

}
