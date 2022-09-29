//
//  MultipleMediaList.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 30/06/22.
//

import Foundation
struct MultipleMediaList : Codable {
  
    let bgColor : String?
    let createdDate : Int?
    let mediaType : Int?
    let mediaUrl : String?
    let postContent : String?
    let textColor : String?
    let thumbNail : String?
    

    enum CodingKeys: String, CodingKey {

        case bgColor = "bgColor"
        case createdDate = "createdDate"
        case mediaType = "mediaType"
        case mediaUrl = "mediaUrl"
        case postContent = "postContent"
        case textColor = "textColor"
        case thumbNail = "thumbNail"
        
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor)
        createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
        mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
        mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
        postContent = try values.decodeIfPresent(String.self, forKey: .postContent)
        textColor = try values.decodeIfPresent(String.self, forKey: .textColor)
        thumbNail = try values.decodeIfPresent(String.self, forKey: .thumbNail)
       
    }
}
