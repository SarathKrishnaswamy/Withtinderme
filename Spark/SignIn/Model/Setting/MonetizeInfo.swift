//
//  MonetizeInfo.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 28/06/22.
//

import Foundation

struct MonetizeInfo : Codable {
    let Max : Int?
    let Min : Int?
    let usMax : Int?
    let usMin : Int?

    enum CodingKeys: String, CodingKey {

        case Max = "Max"
        case Min = "Min"
        case usMax = "usMax"
        case usMin = "usMin"
        
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        Max = try values.decodeIfPresent(Int.self, forKey: .Max)
        Min = try values.decodeIfPresent(Int.self, forKey: .Min)
        usMax = try values.decodeIfPresent(Int.self, forKey: .usMax)
        usMin = try values.decodeIfPresent(Int.self, forKey: .usMin)
        
    }

}
