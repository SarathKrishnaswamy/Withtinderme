/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct SettingData : Codable {
	let type : Int?
	let name : String?
	let googlePlayKey : String?
	let appColor : [AppColor]?
	let postType : [PostType]?
	let threadLimit : Int?
    let minThreadLimit : Int?
	let blobURL : String?
	let blobContainerName : String?
	let blobConnection : String?
    var BubbleDestroyTime : Int?
    let ChatURL : String?
    let ContactMail : String?
    let PrivacyURL : String?
    let TermsURL : String?
    let nFTInfo : NFTInfo?
    let monetizeInfo : MonetizeInfo?
    let versionInfo : VersionInfo?
    let wallet_desc : String?
    let cocnutInfo : CoconutInfo?
    var CoconutKey : String?
    let CoconutWebHookURL : String?
    let PlatformInfo : PlatformsInfo?
    

	enum CodingKeys: String, CodingKey {

		case type = "Type"
		case name = "Name"
		case googlePlayKey = "GooglePlayKey"
		case appColor = "AppColor"
		case postType = "PostType"
		case threadLimit = "ThreadLimit"
		case blobURL = "BlobURL"
		case blobContainerName = "BlobContainerName"
		case blobConnection = "BlobConnection"
        case BubbleDestroyTime = "BubbleDestroyTime"
        case ChatURL = "ChatURL"
        case ContactMail = "ContactMail"
        case PrivacyURL = "PrivacyURL"
        case TermsURL = "TermsURL"
        case versionInfo = "VersionInfo"
        case nFTInfo = "NFTInfo"
        case monetizeInfo = "MonetizeInfo"
        case cocnutInfo = "CoconutInfo"
        case minThreadLimit = "minThreadLimit"
        case wallet_desc = "wallet_desc"
        case CoconutKey = "CoconutKey"
        case CoconutWebHookURL = "CoconutWebHookURL"
        case PlatformInfo = "PlatformInfo"
        
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		type = try values.decodeIfPresent(Int.self, forKey: .type)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		googlePlayKey = try values.decodeIfPresent(String.self, forKey: .googlePlayKey)
		appColor = try values.decodeIfPresent([AppColor].self, forKey: .appColor)
		postType = try values.decodeIfPresent([PostType].self, forKey: .postType)
		threadLimit = try values.decodeIfPresent(Int.self, forKey: .threadLimit)
		blobURL = try values.decodeIfPresent(String.self, forKey: .blobURL)
		blobContainerName = try values.decodeIfPresent(String.self, forKey: .blobContainerName)
		blobConnection = try values.decodeIfPresent(String.self, forKey: .blobConnection)
        BubbleDestroyTime = try values.decodeIfPresent(Int.self, forKey: .BubbleDestroyTime)
        ChatURL = try values.decodeIfPresent(String.self, forKey: .ChatURL)
        ContactMail = try values.decodeIfPresent(String.self, forKey: .ContactMail)
        PrivacyURL = try values.decodeIfPresent(String.self, forKey: .PrivacyURL)
        TermsURL = try values.decodeIfPresent(String.self, forKey: .TermsURL)
        versionInfo = try values.decodeIfPresent(VersionInfo.self, forKey: .versionInfo)
        minThreadLimit = try values.decodeIfPresent(Int.self, forKey: .minThreadLimit)
        nFTInfo = try values.decodeIfPresent(NFTInfo.self, forKey: .nFTInfo)
        PlatformInfo = try values.decodeIfPresent(PlatformsInfo.self, forKey: .PlatformInfo)
        monetizeInfo = try values.decodeIfPresent(MonetizeInfo.self, forKey: .monetizeInfo)
        cocnutInfo = try values.decodeIfPresent(CoconutInfo.self, forKey: .cocnutInfo)
        wallet_desc = try values.decodeIfPresent(String.self, forKey: .wallet_desc)
        CoconutKey = try values.decodeIfPresent(String.self, forKey: .CoconutKey)
        CoconutWebHookURL = try values.decodeIfPresent(String.self, forKey: .CoconutWebHookURL)

	}

}
