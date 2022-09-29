//
//  PlatformInfo.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/07/22.
//

import Foundation
struct PlatformsInfo : Codable {
    let indiaPlatform : Int?
    let indiaRazorPay : Int?
    let usPlatform : Int?
    let usRazorPay : Int?

    enum CodingKeys: String, CodingKey {

        case indiaPlatform = "indiaPlatform"
        case indiaRazorPay = "indiaRazorPay"
        case usPlatform = "usPlatform"
        case usRazorPay = "usRazorPay"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        indiaPlatform = try values.decodeIfPresent(Int.self, forKey: .indiaPlatform)
        indiaRazorPay = try values.decodeIfPresent(Int.self, forKey: .indiaRazorPay)
        usPlatform = try values.decodeIfPresent(Int.self, forKey: .usPlatform)
        usRazorPay = try values.decodeIfPresent(Int.self, forKey: .usRazorPay)
    }

}

