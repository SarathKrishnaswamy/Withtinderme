

import Foundation
struct CheckTagStatus : Codable {
	let isOk : Bool?
	let data : CheckTagStatusData?

	enum CodingKeys: String, CodingKey {

		case isOk = "isOk"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
		data = try values.decodeIfPresent(CheckTagStatusData.self, forKey: .data)
	}

}
