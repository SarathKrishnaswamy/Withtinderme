/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SaveProfileData : Codable {
	let _id : String?
	let mobilenumber : String?
	let profilepic : String?
	let osversion : String?
	let isVerified : Int?
	let email : String?
	let fname : String?
	let lname : String?
	let manufacturer : String?
	let fcmtoken : String?
	let app_version_with_build : String?
	let devicetype : Int?
	let appversion : String?
	let devicetoken : String?
	let isProfileUpdated : Bool?
	let dob : Int?
	let clapCount : Int?
	let viewCount : Int?
	let threadCount : Int?
	let connectionCount : Int?
	let location : String?
	let gender : String?
	let aboutme : String?
	let createdDate : Int?
	let modifiedDate : Int?
	let __v : Int?
	let isApproved : Bool?
	let displayName : String?
	let isSyncContact : Bool?
	let countryCode : String?

	enum CodingKeys: String, CodingKey {

		case _id = "_id"
		case mobilenumber = "mobilenumber"
		case profilepic = "profilepic"
		case osversion = "osversion"
		case isVerified = "isVerified"
		case email = "email"
		case fname = "fname"
		case lname = "lname"
		case manufacturer = "manufacturer"
		case fcmtoken = "fcmtoken"
		case app_version_with_build = "app_version_with_build"
		case devicetype = "devicetype"
		case appversion = "appversion"
		case devicetoken = "devicetoken"
		case isProfileUpdated = "isProfileUpdated"
		case dob = "dob"
		case clapCount = "clapCount"
		case viewCount = "viewCount"
		case threadCount = "threadCount"
		case connectionCount = "connectionCount"
		case location = "location"
		case gender = "gender"
		case aboutme = "aboutme"
		case createdDate = "createdDate"
		case modifiedDate = "modifiedDate"
		case __v = "__v"
		case isApproved = "IsApproved"
		case displayName = "displayName"
		case isSyncContact = "IsSyncContact"
		case countryCode = "countryCode"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		_id = try values.decodeIfPresent(String.self, forKey: ._id)
		mobilenumber = try values.decodeIfPresent(String.self, forKey: .mobilenumber)
		profilepic = try values.decodeIfPresent(String.self, forKey: .profilepic)
		osversion = try values.decodeIfPresent(String.self, forKey: .osversion)
		isVerified = try values.decodeIfPresent(Int.self, forKey: .isVerified)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		fname = try values.decodeIfPresent(String.self, forKey: .fname)
		lname = try values.decodeIfPresent(String.self, forKey: .lname)
		manufacturer = try values.decodeIfPresent(String.self, forKey: .manufacturer)
		fcmtoken = try values.decodeIfPresent(String.self, forKey: .fcmtoken)
		app_version_with_build = try values.decodeIfPresent(String.self, forKey: .app_version_with_build)
		devicetype = try values.decodeIfPresent(Int.self, forKey: .devicetype)
		appversion = try values.decodeIfPresent(String.self, forKey: .appversion)
		devicetoken = try values.decodeIfPresent(String.self, forKey: .devicetoken)
		isProfileUpdated = try values.decodeIfPresent(Bool.self, forKey: .isProfileUpdated)
		dob = try values.decodeIfPresent(Int.self, forKey: .dob)
		clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
		viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
		threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
		connectionCount = try values.decodeIfPresent(Int.self, forKey: .connectionCount)
		location = try values.decodeIfPresent(String.self, forKey: .location)
		gender = try values.decodeIfPresent(String.self, forKey: .gender)
		aboutme = try values.decodeIfPresent(String.self, forKey: .aboutme)
		createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
		modifiedDate = try values.decodeIfPresent(Int.self, forKey: .modifiedDate)
		__v = try values.decodeIfPresent(Int.self, forKey: .__v)
		isApproved = try values.decodeIfPresent(Bool.self, forKey: .isApproved)
		displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
		isSyncContact = try values.decodeIfPresent(Bool.self, forKey: .isSyncContact)
		countryCode = try values.decodeIfPresent(String.self, forKey: .countryCode)
	}

}
