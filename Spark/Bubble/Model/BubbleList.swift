/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct BubbleList : Codable {
	let _id : String?
    let linkpostId : String?
    let linkuserId : String?
    let displayName : String?
    let profilePic : String?
    let threadId : String?
    let visibleDate : Int?
    let threadpostId : String?
    let threaduserId : String?
    let allowAnonymous : Bool?
    let gender : Int?

	enum CodingKeys: String, CodingKey {

		case _id = "_id"
		case linkpostId = "linkpostId"
		case linkuserId = "linkuserId"
		case displayName = "displayName"
		case profilePic = "profilePic"
        case threadId = "threadId"
        case visibleDate = "visibleDate"
        case threadpostId = "threadpostId"
        case threaduserId = "threaduserId"
        case allowAnonymous = "allowAnonymous"
        case gender = "gender"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		_id = try values.decodeIfPresent(String.self, forKey: ._id)
		linkpostId = try values.decodeIfPresent(String.self, forKey: .linkpostId)
		linkuserId = try values.decodeIfPresent(String.self, forKey: .linkuserId)
		displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
		profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
        visibleDate = try values.decodeIfPresent(Int.self, forKey: .visibleDate)
        threadpostId = try values.decodeIfPresent(String.self, forKey: .threadpostId)
        threaduserId = try values.decodeIfPresent(String.self, forKey: .threaduserId)
        allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
        gender = try values.decodeIfPresent(Int.self, forKey: .gender)
	}

}
