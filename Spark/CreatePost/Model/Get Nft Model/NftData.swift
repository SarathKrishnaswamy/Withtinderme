//
//  NftData.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 04/02/22.
//

import Foundation
struct NftData : Codable {
    
    /**
     This class is used to set the Nft Data keys 
     */
    let nft : Int?
    let monetize : Int?
    let isKYC : Bool?
    let isAgree : Int?
    let isSkip : Bool?
    
    

    enum CodingKeys: String, CodingKey {

        case nft = "nft"
        case monetize = "monetize"
        case isKYC = "isKYC"
        case isAgree = "isAgree"
        case isSkip = "isSkip"
        
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nft = try values.decodeIfPresent(Int.self, forKey: .nft)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
        isKYC = try values.decodeIfPresent(Bool.self, forKey: .isKYC)
        isAgree = try values.decodeIfPresent(Int.self, forKey: .isAgree)
        isSkip = try values.decodeIfPresent(Bool.self, forKey: .isSkip)
        
    }

}
