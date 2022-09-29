//
//  PaymentHistoryList.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 12/07/22.
//

import Foundation

struct PaymentHistoryList : Codable {
    let basePostId : String?
    let baseUserId : String?
    let userId : String?
    let jobId : String?
    let jobEvent : String?
    let status : Int?
    let amount : Int?
    let createdDate : Int?
    let modifiedDate : Int?
    let gender : Int?
    let userImage : String?
    let userName : String?
    let currencySymbol : String?
    let statusDesc : String?
    let monetizePlatformAmount : Int?
    let monetizeTax : Int?
    let monetizeActualAmount : Int?
    let transactionId : String?
    let paymentMethod : String?

    enum CodingKeys: String, CodingKey {

        case basePostId = "basePostId"
        case baseUserId = "baseUserId"
        case userId = "userId"
        case jobId = "jobId"
        case jobEvent = "jobEvent"
        case status = "status"
        case amount = "amount"
        case createdDate = "createdDate"
        case modifiedDate = "modifiedDate"
        case gender = "gender"
        case userImage = "userImage"
        case userName = "userName"
        case currencySymbol = "currencySymbol"
        case statusDesc = "statusDesc"
        case monetizePlatformAmount = "monetizePlatformAmount"
        case monetizeTax = "monetizeTax"
        case monetizeActualAmount = "monetizeActualAmount"
        case transactionId = "transactionId"
        case paymentMethod = "paymentMethod"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        basePostId = try values.decodeIfPresent(String.self, forKey: .basePostId)
        baseUserId = try values.decodeIfPresent(String.self, forKey: .baseUserId)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        jobId = try values.decodeIfPresent(String.self, forKey: .jobId)
        jobEvent = try values.decodeIfPresent(String.self, forKey: .jobEvent)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        amount = try values.decodeIfPresent(Int.self, forKey: .amount)
        createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
        modifiedDate = try values.decodeIfPresent(Int.self, forKey: .modifiedDate)
        gender = try values.decodeIfPresent(Int.self, forKey: .gender)
        userImage = try values.decodeIfPresent(String.self, forKey: .userImage)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        statusDesc = try values.decodeIfPresent(String.self, forKey: .statusDesc)
        monetizePlatformAmount = try values.decodeIfPresent(Int.self, forKey: .monetizePlatformAmount)
        monetizeTax = try values.decodeIfPresent(Int.self, forKey: .monetizeTax)
        monetizeActualAmount =  try values.decodeIfPresent(Int.self, forKey: .monetizeActualAmount)
        transactionId = try values.decodeIfPresent(String.self, forKey: .transactionId)
        paymentMethod = try values.decodeIfPresent(String.self, forKey: .paymentMethod)
        
    }

}
