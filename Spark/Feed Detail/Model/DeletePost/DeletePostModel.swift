//
//  DeletePostModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 20/05/22.
//

import Foundation

struct DeletePostModel : Codable {
    let isOk : Bool?
    let data : DeletePostData?

    enum CodingKeys: String, CodingKey {

        case isOk = "isOk"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
        data = try values.decodeIfPresent(DeletePostData.self, forKey: .data)
    }

}
