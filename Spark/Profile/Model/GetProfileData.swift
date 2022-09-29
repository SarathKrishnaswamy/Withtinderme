/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct GetProfileData : Codable {
	let mobilenumber : String?
	let profilepic : String?
	let email : String?
	let fname : String?
	let lname : String?
	let location : String?
	let gender : Int?
	let dob : Int?
	let userId : String?
	let aboutme : String?
	let isProfileUpdated : Bool?
	let clapCount : Int?
	let score : Int?
	let viewCount : Int?
	let threadCount : Int?
    let isVerified : Int?
	let postedTag : [PostedTag]?
    let countryCode : String?
    let connectionCount : Int?
    let nft : Int?
    let accountDetails : String?
    let isKYC: Bool?
    let isAgree : Int?
    let isSkip: Bool?
    
	enum CodingKeys: String, CodingKey {

		case mobilenumber = "mobilenumber"
		case profilepic = "profilepic"
		case email = "email"
		case fname = "fname"
		case lname = "lname"
		case location = "location"
		case gender = "gender"
		case dob = "dob"
		case userId = "userId"
		case aboutme = "aboutme"
		case isProfileUpdated = "isProfileUpdated"
		case clapCount = "clapCount"
		case score = "score"
		case viewCount = "viewCount"
		case threadCount = "threadCount"
		case postedTag = "postedTag"
        case isVerified = "isVerified"
        case countryCode = "countryCode"
        case connectionCount = "connectionCount"
        case nft = "nft"
        case accountDetails = "accountDetails"
        case isKYC = "isKYC"
        case isAgree = "isAgree"
        case isSkip = "isSkip"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		mobilenumber = try values.decodeIfPresent(String.self, forKey: .mobilenumber)
		profilepic = try values.decodeIfPresent(String.self, forKey: .profilepic)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		fname = try values.decodeIfPresent(String.self, forKey: .fname)
		lname = try values.decodeIfPresent(String.self, forKey: .lname)
		location = try values.decodeIfPresent(String.self, forKey: .location)
		gender = try values.decodeIfPresent(Int.self, forKey: .gender)
		dob = try values.decodeIfPresent(Int.self, forKey: .dob)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		aboutme = try values.decodeIfPresent(String.self, forKey: .aboutme)
		isProfileUpdated = try values.decodeIfPresent(Bool.self, forKey: .isProfileUpdated)
		clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
		score = try values.decodeIfPresent(Int.self, forKey: .score)
		viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
		threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
        isVerified = try values.decodeIfPresent(Int.self, forKey: .isVerified)
		postedTag = try values.decodeIfPresent([PostedTag].self, forKey: .postedTag)
        countryCode = try values.decodeIfPresent(String.self, forKey: .countryCode)
        connectionCount = try values.decodeIfPresent(Int.self, forKey: .connectionCount)
        nft = try values.decodeIfPresent(Int.self, forKey: .nft)
        accountDetails = try values.decodeIfPresent(String.self, forKey: .accountDetails)
        isKYC = try values.decodeIfPresent(Bool.self, forKey: .isKYC)
        isAgree = try values.decodeIfPresent(Int.self, forKey: .isAgree)
        isSkip = try values.decodeIfPresent(Bool.self, forKey: .isSkip)

	}

}
