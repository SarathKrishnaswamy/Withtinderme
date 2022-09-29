//
//  ReportPopstModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 26/09/22.
//

import Foundation

struct ReportPopstModel : Codable {
    let isOk : Bool?
    let data : ReportPostDataValue?

    enum CodingKeys: String, CodingKey {

        case isOk = "isOk"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
        data = try values.decodeIfPresent(ReportPostDataValue.self, forKey: .data)
    }

}
