

import Foundation
struct RecentConversationData : Codable {
	let conversationList : [RecentConversationList]?
	let paginator : RecentConversationPaginator?

	enum CodingKeys: String, CodingKey {

		case conversationList = "conversationList"
		case paginator = "paginator"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		conversationList = try values.decodeIfPresent([RecentConversationList].self, forKey: .conversationList)
		paginator = try values.decodeIfPresent(RecentConversationPaginator.self, forKey: .paginator)
	}

}
