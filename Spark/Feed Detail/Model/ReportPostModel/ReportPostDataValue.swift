//
//  ReportPostDataValue.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 26/09/22.
//

import Foundation

struct ReportPostDataValue : Codable {
    let threadId : String?
    let status : Int?
    let message : String?

    enum CodingKeys: String, CodingKey {

        case threadId = "threadId"
        case status = "status"
        case message = "message"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }

}
