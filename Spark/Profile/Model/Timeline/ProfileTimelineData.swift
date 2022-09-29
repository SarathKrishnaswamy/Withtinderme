/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct ProfileTimelineData : Codable {
    let postedTag : [String]?
    let viewsCount : Int?
    let score : Int?
    let claps : Int?
    let connection : Int?
    let feeds : [ProfileTimelineFeeds]?
    let paginator : Paginator?

    enum CodingKeys: String, CodingKey {

        case postedTag = "postedTag"
        case viewsCount = "viewsCount"
        case score = "score"
        case claps = "claps"
        case connection = "connection"
        case feeds = "feeds"
        case paginator = "paginator"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        postedTag = try values.decodeIfPresent([String].self, forKey: .postedTag)
        viewsCount = try values.decodeIfPresent(Int.self, forKey: .viewsCount)
        score = try values.decodeIfPresent(Int.self, forKey: .score)
        claps = try values.decodeIfPresent(Int.self, forKey: .claps)
        connection = try values.decodeIfPresent(Int.self, forKey: .connection)
        feeds = try values.decodeIfPresent([ProfileTimelineFeeds].self, forKey: .feeds)
        paginator = try values.decodeIfPresent(Paginator.self, forKey: .paginator)
    }

}
