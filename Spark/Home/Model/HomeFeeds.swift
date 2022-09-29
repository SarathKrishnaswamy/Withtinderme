/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

struct HomeFeeds : Codable {
    let viewCount : Int?
    let threadCount : Int?
    var clapCount : Int?
    let createdDate : Int?
    let postId : String?
    let profileName : String?
    let profilePic : String?
    let userId : String?
    let threadId : String?
    let isView : Bool?
    var isClap : Bool?
    let postContent : String?
    let mediaUrl : String?
    let postType : Int?
    var isLoaded : Bool?
    var thumbNail : String?
    let mediaType : Int?
    let tagName : String?
    let tagId : String?
    let textColor : String?
    let bgColor : String?
    let nft : Int?
    let monetize : Int?
    let allowAnonymous : Bool?
    let gender : Int?
    let threadLimit : Int?
    let currencySymbol : String?
    var isViewed : Bool?
    //let monetize : Int?
    
    enum CodingKeys: String, CodingKey {

        case viewCount = "viewCount"
        case threadCount = "threadCount"
        case clapCount = "clapCount"
        case createdDate = "createdDate"
        case postId = "postId"
        case profileName = "profileName"
        case profilePic = "profilePic"
        case userId = "userId"
        case isView = "isView"
        case isClap = "isClap"
        case postContent = "postContent"
        case postType = "postType"
        case mediaUrl = "mediaUrl"
        case isLoaded = "isLoaded"
        case thumbNail = "thumbNail"
        case mediaType = "mediaType"
        case tagName = "tagName"
        case tagId = "tagId"
        case textColor = "textColor"
        case bgColor = "bgColor"
        case allowAnonymous = "allowAnonymous"
        case nft = "nft"
        case monetize = "monetize"
        case gender = "gender"
        case threadId = "threadId"
        case threadLimit = "threadLimit"
        case currencySymbol = "currencySymbol"
        case isViewed = "isViewed"
       // case monetize = "monetize"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        viewCount = try values.decodeIfPresent(Int.self, forKey: .viewCount)
        threadCount = try values.decodeIfPresent(Int.self, forKey: .threadCount)
        clapCount = try values.decodeIfPresent(Int.self, forKey: .clapCount)
        createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
        postId = try values.decodeIfPresent(String.self, forKey: .postId)
        profileName = try values.decodeIfPresent(String.self, forKey: .profileName)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        isView = try values.decodeIfPresent(Bool.self, forKey: .isView)
        isClap = try values.decodeIfPresent(Bool.self, forKey: .isClap)
        postContent = try values.decodeIfPresent(String.self, forKey: .postContent)
        postType = try values.decodeIfPresent(Int.self, forKey: .postType)
        mediaUrl = try values.decodeIfPresent(String.self, forKey: .mediaUrl)
        isLoaded = try values.decodeIfPresent(Bool.self, forKey: .isLoaded)
        thumbNail = try values.decodeIfPresent(String.self, forKey: .thumbNail)
        mediaType = try values.decodeIfPresent(Int.self, forKey: .mediaType)
        tagName = try values.decodeIfPresent(String.self, forKey: .tagName)
        tagId = try values.decodeIfPresent(String.self, forKey: .tagId)
        textColor = try values.decodeIfPresent(String.self, forKey: .textColor)
        bgColor = try values.decodeIfPresent(String.self, forKey: .bgColor)
        allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
        nft = try values.decodeIfPresent(Int.self, forKey: .nft)
        monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)
        gender = try values.decodeIfPresent(Int.self, forKey: .gender)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
        threadLimit = try values.decodeIfPresent(Int.self, forKey: .threadLimit)
        currencySymbol = try values.decodeIfPresent(String.self, forKey: .currencySymbol)
        isViewed = try values.decodeIfPresent(Bool.self, forKey: .isViewed)
        //monetize = try values.decodeIfPresent(Int.self, forKey: .monetize)

    }

}
