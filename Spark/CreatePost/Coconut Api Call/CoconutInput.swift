//
//  CoconutInput.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 03/06/22.
//

import Foundation

struct CoconutInput : Codable {
    /**
     This class is used to show the status of coconut api input data
     */
    let status : String?

    enum CodingKeys: String, CodingKey {

        case status = "status"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }

}
