//
//  NftSparkDetailModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 08/02/22.
//

import Foundation
/**
 Set all the nft spark detail model here
 */
struct NftSparkDetailModel : Codable {
    let _id : String?
    let modifiedDate : Int?
    let allowAnonymous : Bool?
    let postContent : String?
    let viewCount : Int?
    let threadCount : Int?
    let clapCount : Int?
    let createdDate : Int?
    let mediaUrl : String?
    let postType : Int?
    let tagName : String?
    let mediaType : Int?
    let bgColor : String?
    let textColor : String?
    let thumbNail : String?
    let profileName : String?
    let profilePic : String?
    let threadLimit : Int?
    let tagId : String?
    let userId : String?
    let gender : Int?
    let nft : Int?
    let nftAddress : String?
    let threadId : String?
    let nfttokenId : String?
    let nfttxId : String?
    let nftAttributes : [NftAttributeData]?
    let monetize : Int?

    enum CodingKeys: String, CodingKey {

        case _id = "_id"
        case modifiedDate = "modifiedDate"
        case allowAnonymous = "allowAnonymous"
        case postContent = "postContent"
        case viewCount = "viewCount"
        case threadCount = "threadCount"
        case clapCount = "clapCount"
        case createdDate = "createdDate"
        case mediaUrl = "mediaUrl"
        case postType = "postType"
        case tagName = "tagName"
        case mediaType = "mediaType"
        case bgColor = "bgColor"
        case textColor = "textColor"
        case thumbNail = "thumbNail"
        case profileName = "profileName"
        case profilePic = "profilePic"
        case threadLimit = "threadLimit"
        case tagId = "tagId"
        case userId = "userId"
        case gender = "gender"
        case nft = "nft"
        case nftAddress = "nftAddress"
        case threadId = "threadId"
        case nfttokenId = "nfttokenId"
        case nfttxId = "nfttxId"
        case nftAttributes = "attributes"
        case monetize = "monetize"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        modifiedDate = try values.decodeIfPresent(Int.self, forKey: .modifiedDate)
        allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
        postContent = try values.decodeIfPresent(String.self, forKey: .postContent)
        viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
        threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
        clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
        createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
        mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
        postType = try values.decodeIfPresent(Int.self, forKey: .postType)
        tagName = try values.decodeIfPresent(String.self, forKey: .tagName)
        mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
        bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor)
        textColor = try values.decodeIfPresent(String.self, forKey: .textColor)
        thumbNail = try values.decodeIfPresent(String.self, forKey: .thumbNail)
        profileName = try values.decodeIfPresent(String.self, forKey: .profileName)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        threadLimit = try values.decodeIfPresent(Int.self, forKey: .threadLimit)
        tagId = try values.decodeIfPresent(String.self, forKey: .tagId)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        gender = try values.decodeIfPresent(Int.self, forKey: .gender)
        nft = try values.decodeIfPresent(Int.self, forKey: .nft)
        nftAddress = try values.decodeIfPresent(String.self, forKey: .nftAddress)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
        nfttokenId = try values.decodeIfPresent(String.self, forKey: .nfttokenId)
        nfttxId = try values.decodeIfPresent(String.self, forKey: .nfttxId)
        nftAttributes = try values.decodeIfPresent([NftAttributeData].self, forKey: .nftAttributes)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
    }

}

