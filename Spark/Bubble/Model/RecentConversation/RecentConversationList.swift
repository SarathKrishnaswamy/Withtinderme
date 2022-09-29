

import Foundation
struct RecentConversationList : Codable {
    let currencySymbol : String?
	let threadId : String?
    let isMonetize : Int?
	let linkuserId : String?
	let linkpostId : String?
	let profilePic : String?
	let tagName : String?
	let description : String?
	let modifiedDate : Int?
	let displayName : String?
	let mediaType : Int?
    let mediaUrl : String?
    let thumbNailUrl : String?
    let allowAnonymous : Bool?

	enum CodingKeys: String, CodingKey {

		case threadId = "threadId"
		case linkuserId = "linkuserId"
		case linkpostId = "linkpostId"
        case currencySymbol = "currencySymbol"
        case isMonetize = "isMonetize"
		case profilePic = "profilePic"
		case tagName = "tagName"
		case description = "description"
		case modifiedDate = "modifiedDate"
		case displayName = "displayName"
		case mediaType = "mediaType"
        case mediaUrl = "mediaUrl"
        case thumbNailUrl = "thumbNailUrl"
        case allowAnonymous = "allowAnonymous"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
		linkuserId = try values.decodeIfPresent(String.self, forKey: .linkuserId)
		linkpostId = try values.decodeIfPresent(String.self, forKey: .linkpostId)
		profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
		tagName = try values.decodeIfPresent(String.self, forKey: .tagName)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		modifiedDate = try values.decodeIfPresent(Int.self, forKey: .modifiedDate)
		displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
		mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
        mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
        thumbNailUrl = try values.decodeIfPresent(String.self, forKey: .thumbNailUrl)
        allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
        isMonetize = try values.decodeIfPresent(Int.self, forKey: .isMonetize)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        
	}

}
