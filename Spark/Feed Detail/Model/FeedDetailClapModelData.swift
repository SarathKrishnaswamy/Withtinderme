/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct FeedDetailClapModelData : Codable {
	let isTag : Bool?
	let isClap : Bool?
    let isMonetize: Int?
	let membersTotal : Int?
    var membersList : [MembersList]?
	let postDetails : PostDetails?
    let mediaList : [MediaList]?
    let isThread : Int?
    let isUser : IsUser?
    let isBubbleRequest : Bool?
    let mediaTotal : Int?
    

	enum CodingKeys: String, CodingKey {

		case isTag = "isTag"
		case isClap = "isClap"
        case isMonetize = "isMonetize"
		case membersTotal = "membersTotal"
		case membersList = "membersList"
		case postDetails = "postDetails"
        case isThread = "isThread"
        case isUser = "isUser"
        case isBubbleRequest = "isBubbleRequest"
        case mediaTotal = "mediaTotal"
        case mediaList = "mediaList"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isTag = try values.decodeIfPresent(Bool.self, forKey: .isTag)
		isClap = try values.decodeIfPresent(Bool.self, forKey: .isClap)
        isMonetize = try values.decodeIfPresent(Int.self, forKey: .isMonetize)
		membersTotal = try values.decodeIfPresent(Int.self, forKey: .membersTotal)
		membersList = try values.decodeIfPresent([MembersList].self, forKey: .membersList)
		postDetails = try values.decodeIfPresent(PostDetails.self, forKey: .postDetails)
        isThread = try values.decodeIfPresent(Int.self, forKey: .isThread)
        isUser = try values.decodeIfPresent(IsUser.self, forKey: .isUser)
        isBubbleRequest = try values.decodeIfPresent(Bool.self, forKey: .isBubbleRequest)
        mediaTotal = try values.decodeIfPresent(Int.self, forKey: .mediaTotal)
        mediaList = try values.decodeIfPresent([MediaList].self, forKey: .mediaList)
	}

}
