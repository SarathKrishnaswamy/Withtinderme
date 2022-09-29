/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct LoginData : Codable {
	let accessToken : String?
	let mobilenumber : String?
	let profilepic : String?
	let email : String?
	let userId : String?
	let fname : String?
	let lname : String?
    let isProfileUpdated : Bool?
    let isVerified : Int?
    let IsApproved : Bool?
    let countryCode : String?
    let refreshToken : String?

	enum CodingKeys: String, CodingKey {

		case accessToken = "accessToken"
		case mobilenumber = "mobilenumber"
		case profilepic = "profilepic"
		case email = "email"
		case userId = "userId"
		case fname = "fname"
		case lname = "lname"
        case isProfileUpdated = "isProfileUpdated"
        case isVerified = "isVerified"
        case IsApproved = "IsApproved"
        case countryCode = "countryCode"
        case refreshToken = "refreshToken"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
		mobilenumber = try values.decodeIfPresent(String.self, forKey: .mobilenumber)
		profilepic = try values.decodeIfPresent(String.self, forKey: .profilepic)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		userId = try values.decodeIfPresent(String.self, forKey: .userId)
		fname = try values.decodeIfPresent(String.self, forKey: .fname)
		lname = try values.decodeIfPresent(String.self, forKey: .lname)
        isProfileUpdated = try values.decodeIfPresent(Bool.self, forKey: .isProfileUpdated)
        isVerified = try values.decodeIfPresent(Int.self, forKey: .isVerified)
        IsApproved = try values.decodeIfPresent(Bool.self, forKey: .IsApproved)
        countryCode = try values.decodeIfPresent(String.self, forKey: .countryCode)
        refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
	}

}
