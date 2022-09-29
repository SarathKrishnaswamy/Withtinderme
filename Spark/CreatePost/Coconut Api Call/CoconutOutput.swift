//
//  CoconutOutput.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 03/06/22.
//

import Foundation
struct CoconutOutput : Codable {
    /**
     This class is used as value type to get the datas from coconut api 
     */
    let key : String?
    let type : String?
    let format : String?
    let status : String?

    enum CodingKeys: String, CodingKey {

        case key = "key"
        case type = "type"
        case format = "format"
        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        format = try values.decodeIfPresent(String.self, forKey: .format)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}
