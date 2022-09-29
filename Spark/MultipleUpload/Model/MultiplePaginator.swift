//
//  Multiple.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import Foundation
struct MultiplePaginator : Codable {
    let pageSize : Int?
    let pageNumber : Int?
    let totalPages : Int?
    let nextPage : Int?
    let previousPage : Int?

    enum CodingKeys: String, CodingKey {

        case pageSize = "pageSize"
        case pageNumber = "pageNumber"
        case totalPages = "totalPages"
        case nextPage = "nextPage"
        case previousPage = "previousPage"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageSize = try values.decodeIfPresent(Int.self, forKey: .pageSize)
        pageNumber = try values.decodeIfPresent(Int.self, forKey: .pageNumber)
        totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages)
        nextPage = try values.decodeIfPresent(Int.self, forKey: .nextPage)
        previousPage = try values.decodeIfPresent(Int.self, forKey: .previousPage)
    }

}
