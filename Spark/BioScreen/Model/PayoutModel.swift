//
//  PayoutModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 05/08/22.
//

import Foundation

struct PayoutModel : Codable {
    let pan_number : String?
    let acc_number : String?
    let upi_number : String?
    let aadhar_number : String?
    let ifsc_code : String?

    enum CodingKeys: String, CodingKey {

        case pan_number = "pan_number"
        case acc_number = "acc_number"
        case upi_number = "upi_number"
        case aadhar_number = "aadhar_number"
        case ifsc_code = "ifsc_code"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pan_number = try values.decodeIfPresent(String.self, forKey: .pan_number)
        acc_number = try values.decodeIfPresent(String.self, forKey: .acc_number)
        upi_number = try values.decodeIfPresent(String.self, forKey: .upi_number)
        aadhar_number = try values.decodeIfPresent(String.self, forKey: .aadhar_number)
        ifsc_code = try values.decodeIfPresent(String.self, forKey: .ifsc_code)
    }

}
