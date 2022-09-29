//
//  NftAttributeDate.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 23/03/22.
//

import Foundation

/**
 Set all the NFT attributed data
 */
struct NftAttributeData : Codable {
    
    let display_type : String?
    let trait_type : String?
    let value : String?

    enum CodingKeys: String, CodingKey {
        case display_type = "display_type"
        case trait_type = "trait_type"
        case value = "value"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        display_type = try values.decodeIfPresent(String.self, forKey: .display_type)
        trait_type = try values.decodeIfPresent(String.self, forKey: .trait_type)
        do {
            value = try String(values.decode(Int.self, forKey: .value))
        } catch DecodingError.typeMismatch {
            value = try values.decode(String.self, forKey: .value)
        }
        //value = try values.decodeIfPresent(NSString.self, forKey: .value)
    }

}
