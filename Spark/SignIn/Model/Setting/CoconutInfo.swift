//
//  CoconutInfo.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 17/06/22.
//

import Foundation


struct CoconutInfo : Codable {
    let coconutKey : String?
    let coconutWebHookURL : String?
    let waterMarkURL : String?

    enum CodingKeys: String, CodingKey {

        case coconutKey = "CoconutKey"
        case coconutWebHookURL = "CoconutWebHookURL"
        case waterMarkURL = "WaterMarkURL"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coconutKey = try values.decodeIfPresent(String.self, forKey: .coconutKey)
        coconutWebHookURL = try values.decodeIfPresent(String.self, forKey: .coconutWebHookURL)
        waterMarkURL = try values.decodeIfPresent(String.self, forKey: .waterMarkURL)
    }

}
