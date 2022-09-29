/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct PostDetails : Codable {
	let _id : String?
	let allowAnonymous : Bool?
	let postContent : String?
	let mediaUrl : String?
	let tagId : String?
	let status : Bool?
	let mediaType : Int?
	let postType : Int?
	let tagName : String?
	let threadId : String?
	let score : Double?
	let profileName : String?
	let gender : Int?
	let thumbNail : String?
	let profilePic : String?
	let clapCount : Int?
	let threadCount : Int?
	let lat : String?
	let lng : String?
	let viewCount : Int?
	let bgColor : String?
	let textColor : String?
	let userId : String?
	let threadLimit : Int?
	let createdDate : Int?
    let currencyCode: String?
    let currencySymbol : String?
    let monetize : Int?
    let monetizeAmount : Int?
	let modifiedDate : Int?
    let nft : Int?
	let __v : Int?
	let scoreModifiedDate : Int?

	enum CodingKeys: String, CodingKey {

		case _id = "_id"
		case allowAnonymous = "allowAnonymous"
		case postContent = "postContent"
		case mediaUrl = "mediaUrl"
		case tagId = "tagId"
		case status = "status"
		case mediaType = "mediaType"
		case postType = "postType"
		case tagName = "tagName"
		case threadId = "threadId"
		case score = "score"
		case profileName = "profileName"
		case gender = "gender"
		case thumbNail = "thumbNail"
		case profilePic = "profilePic"
		case clapCount = "clapCount"
		case threadCount = "threadCount"
		case lat = "lat"
		case lng = "lng"
		case viewCount = "viewCount"
		case bgColor = "bgColor"
		case textColor = "textColor"
		case userId = "userId"
		case threadLimit = "threadLimit"
		case createdDate = "createdDate"
        case currencyCode = "currencyCode"
        case currencySymbol = "currencySymbol"
        case monetize = "monetize"
        case monetizeAmount = "monetizeAmount"
		case modifiedDate = "modifiedDate"
        case nft = "nft"
		case __v = "__v"
		case scoreModifiedDate = "scoreModifiedDate"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		_id = try values.decodeIfPresent(String.self, forKey: ._id)
		allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
		postContent = try values.decodeIfPresent(String.self, forKey: .postContent)
		mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
		tagId = try values.decodeIfPresent(String.self, forKey: .tagId)
		status = try values.decodeIfPresent(Bool.self, forKey: .status)
		mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
		postType = try values.decodeIfPresent(Int.self, forKey: .postType)
		tagName = try values.decodeIfPresent(String.self, forKey: .tagName)
		threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
		score = try values.decodeIfPresent(Double.self, forKey: .score)
		profileName = try values.decodeIfPresent(String.self, forKey: .profileName)
		gender = try values.decodeIfPresent(Int.self, forKey: .gender)
		thumbNail = try values.decodeIfPresent(String.self, forKey: .thumbNail)
		profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
		clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
		threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
		lat = try values.decodeIfPresent(String.self, forKey: .lat)
		lng = try values.decodeIfPresent(String.self, forKey: .lng)
		viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
		bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor)
		textColor = try values.decodeIfPresent(String.self, forKey: .textColor)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		threadLimit = try values.decodeIfPresent(Int.self, forKey: .threadLimit)
        currencyCode = try values.decodeIfPresent(String.self, forKey: .currencyCode)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
        monetizeAmount = try values.decodeIfPresent(Int.self, forKey: .monetizeAmount)
		createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
		modifiedDate = try values.decodeIfPresent(Int.self, forKey: .modifiedDate)
        nft = try values.decodeIfPresent(Int.self, forKey: .nft)
		__v = try values.decodeIfPresent(Int.self, forKey: .__v)
		scoreModifiedDate = try values.decodeIfPresent(Int.self, forKey: .scoreModifiedDate)
	}

}
