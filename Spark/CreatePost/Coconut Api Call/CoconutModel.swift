//
//  CoconutModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 03/06/22.
//

import Foundation
struct CoconutModel : Codable {
    /**
      This ia model class is used to set model of  cococonut key json parsing
     */
    let id : String?
    let created_at : String?
    let completed_at : String?
    let status : String?
    let progress : String?
    let input : CoconutInput?
    let outputs : [CoconutOutput]?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case created_at = "created_at"
        case completed_at = "completed_at"
        case status = "status"
        case progress = "progress"
        case input = "input"
        case outputs = "outputs"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        completed_at = try values.decodeIfPresent(String.self, forKey: .completed_at)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        progress = try values.decodeIfPresent(String.self, forKey: .progress)
        input = try values.decodeIfPresent(CoconutInput.self, forKey: .input)
        outputs = try values.decodeIfPresent([CoconutOutput].self, forKey: .outputs)
    }

}
