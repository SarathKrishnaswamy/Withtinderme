/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct VersionInfo : Codable {
	let updateMsg : String?
	let latestVersion : String?
	let playStoreUrl : String?
	let forceUpdate : Bool?
	let isUpdate : Int?
	let updateTitle : String?
    let tutorialUrl : String?
    let tutorialView : Bool?
    let isFb : Int?
    let autoApproval : Int?
    let autoApprovalCode : String?
    let BlobConnection : String?
    let isDelete : Int?

	enum CodingKeys: String, CodingKey {

		case updateMsg = "updateMsg"
		case latestVersion = "latestVersion"
		case playStoreUrl = "playStoreUrl"
		case forceUpdate = "forceUpdate"
		case isUpdate = "isUpdate"
		case updateTitle = "updateTitle"
        case tutorialUrl = "tutorialUrl"
        case tutorialView = "tutorialView"
        case isFb = "isFb"
        case autoApproval = "autoApproval"
        case autoApprovalCode = "autoApprovalCode"
        case BlobConnection = "BlobConnection"
        case isDelete = "isDelete"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		updateMsg = try values.decodeIfPresent(String.self, forKey: .updateMsg)
		latestVersion = try values.decodeIfPresent(String.self, forKey: .latestVersion)
		playStoreUrl = try values.decodeIfPresent(String.self, forKey: .playStoreUrl)
		forceUpdate = try values.decodeIfPresent(Bool.self, forKey: .forceUpdate)
		isUpdate = try values.decodeIfPresent(Int.self, forKey: .isUpdate)
		updateTitle = try values.decodeIfPresent(String.self, forKey: .updateTitle)
        tutorialUrl = try values.decodeIfPresent(String.self, forKey: .tutorialUrl)
        tutorialView = try values.decodeIfPresent(Bool.self, forKey: .tutorialView)
        isFb = try values.decodeIfPresent(Int.self, forKey: .isFb)
        autoApproval = try values.decodeIfPresent(Int.self, forKey: .autoApproval)
        autoApprovalCode = try values.decodeIfPresent(String.self, forKey: .autoApprovalCode)
        BlobConnection = try values.decodeIfPresent(String.self, forKey: .BlobConnection)
        isDelete = try values.decodeIfPresent(Int.self, forKey: .isDelete)
        
	}

}
