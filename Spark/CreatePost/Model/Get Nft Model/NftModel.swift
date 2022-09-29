//
//  NftModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 04/02/22.
//

import Foundation
struct NftModel : Codable {
    /**
     This class is used to set the model of nft key strings
     */
    let isOk : Bool?
    let nftData : NftData?

    enum CodingKeys: String, CodingKey {

        case isOk = "isOk"
        case nftData = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
        nftData = try values.decodeIfPresent(NftData.self, forKey: .nftData)
    }

}
