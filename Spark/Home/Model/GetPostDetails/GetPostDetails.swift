

import Foundation
struct GetPostDetails : Codable {
	let isOk : Bool?
	let data : GetPostDetailsData?

	enum CodingKeys: String, CodingKey {

		case isOk = "isOk"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
		data = try values.decodeIfPresent(GetPostDetailsData.self, forKey: .data)
	}

}
