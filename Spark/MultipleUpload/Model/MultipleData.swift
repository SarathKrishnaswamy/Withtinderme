//
//  MultipleData.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import Foundation

struct MultipleData : Codable {
    let mediaList : [MultipleMediaList]?
    let paginator : MultiplePaginator?

    enum CodingKeys: String, CodingKey {

        case mediaList = "mediaList"
        case paginator = "paginator"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mediaList = try values.decodeIfPresent([MultipleMediaList].self, forKey: .mediaList)
        paginator = try values.decodeIfPresent(MultiplePaginator.self, forKey: .paginator)
    }

}
