//
//  ShareModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/03/22.
//
import Foundation
/**
 This is share model api to get the data string
 */
struct ShareModel : Codable {
    let isOk : Bool?
    let data : String?

    enum CodingKeys: String, CodingKey {

        case isOk = "isOk"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
        data = try values.decodeIfPresent(String.self, forKey: .data)
    }

}

