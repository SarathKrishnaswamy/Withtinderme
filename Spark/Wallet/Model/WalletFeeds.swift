/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct WalletFeeds : Codable {
	let allowAnonymous : Bool?
	let postContent : String?
	let viewCount : Int?
	let threadCount : Int?
	let clapCount : Int?
	let createdDate : Int?
	let mediaUrl : String?
	let postType : Int?
	let postId : String?
	let tagName : String?
	let mediaType : Int?
	let tagId : String?
	let gender : Int?
	let bgColor : String?
	let textColor : String?
	let threadLimit : Int?
	let threadId : String?
	let thumbNail : String?
	let profileName : String?
	let nft : Int?
	let profilePic : String?
	let userId : String?
	let isView : Bool?
	let isClap : Bool?
    let currencySymbol : String?
    let monetize : Int?

	enum CodingKeys: String, CodingKey {

		case allowAnonymous = "allowAnonymous"
		case postContent = "postContent"
		case viewCount = "viewCount"
		case threadCount = "threadCount"
		case clapCount = "clapCount"
		case createdDate = "createdDate"
		case mediaUrl = "mediaUrl"
		case postType = "postType"
		case postId = "postId"
		case tagName = "tagName"
		case mediaType = "mediaType"
		case tagId = "tagId"
		case gender = "gender"
		case bgColor = "bgColor"
		case textColor = "textColor"
		case threadLimit = "threadLimit"
		case threadId = "threadId"
		case thumbNail = "thumbNail"
		case profileName = "profileName"
		case nft = "nft"
		case profilePic = "profilePic"
		case userId = "userId"
		case isView = "isView"
		case isClap = "isClap"
        case currencySymbol = "currencySymbol"
        case monetize = "monetize"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
		postContent = try values.decodeIfPresent(String.self, forKey: .postContent)
		viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
		threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
		clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
		createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
		mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
		postType = try values.decodeIfPresent(Int.self, forKey: .postType)
		postId = try values.decodeIfPresent(String.self, forKey: .postId)
		tagName = try values.decodeIfPresent(String.self, forKey: .tagName)
		mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
		tagId = try values.decodeIfPresent(String.self, forKey: .tagId)
		gender = try values.decodeIfPresent(Int.self, forKey: .gender)
		bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor)
		textColor = try values.decodeIfPresent(String.self, forKey: .textColor)
		threadLimit = try values.decodeIfPresent(Int.self, forKey: .threadLimit)
		threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
		thumbNail = try values.decodeIfPresent(String.self, forKey: .thumbNail)
		profileName = try values.decodeIfPresent(String.self, forKey: .profileName)
		nft = try values.decodeIfPresent(Int.self, forKey: .nft)
		profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		isView = try values.decodeIfPresent(Bool.self, forKey: .isView)
		isClap = try values.decodeIfPresent(Bool.self, forKey: .isClap)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
	}

}
