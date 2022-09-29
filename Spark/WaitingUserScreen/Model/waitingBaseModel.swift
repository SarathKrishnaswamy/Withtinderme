

import Foundation
struct waitingBaseModel : Codable {
	let isOk : Bool?
	let data : waitingData?

	enum CodingKeys: String, CodingKey {

		case isOk = "isOk"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isOk = try values.decodeIfPresent(Bool.self, forKey: .isOk)
		data = try values.decodeIfPresent(waitingData.self, forKey: .data)
	}

}
