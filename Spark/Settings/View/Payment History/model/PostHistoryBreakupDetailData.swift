//
//  PostHistoryBreakupDetailData.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import Foundation

struct PostHistoryBreakupDetailData : Codable {
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
    let nftipfs : String?
    let monetize : Int?
    let monetizeAmount : Int?
    let monetizeActualAmount : Int?
    let monetizePlatformAmount : Int?
    let monetizeTax : Int?
    let currencyCode : String?
    let currencySymbol : String?
    let threadId : String?
    let transactionId : String?
    let paymentMethod : String?
    let attributes : [String]?

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
        case nftipfs = "nftipfs"
        case monetize = "monetize"
        case monetizeAmount = "monetizeAmount"
        case monetizeActualAmount = "monetizeActualAmount"
        case monetizePlatformAmount = "monetizePlatformAmount"
        case monetizeTax = "monetizeTax"
        case currencyCode = "currencyCode"
        case currencySymbol = "currencySymbol"
        case threadId = "threadId"
        case transactionId = "transactionId"
        case paymentMethod = "paymentMethod"
        case attributes = "attributes"
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
        nftipfs = try values.decodeIfPresent(String.self, forKey: .nftipfs)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
        monetizeAmount = try values.decodeIfPresent(Int.self, forKey: .monetizeAmount)
        monetizeActualAmount = try values.decodeIfPresent(Int.self, forKey: .monetizeActualAmount)
        monetizePlatformAmount = try values.decodeIfPresent(Int.self, forKey: .monetizePlatformAmount)
        monetizeTax = try values.decodeIfPresent(Int.self, forKey: .monetizeTax)
        currencyCode = try values.decodeIfPresent(String.self, forKey: .currencyCode)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
        transactionId = try values.decodeIfPresent(String.self, forKey: .transactionId)
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        attributes = try values.decodeIfPresent([String].self, forKey: .attributes)
    }

}
