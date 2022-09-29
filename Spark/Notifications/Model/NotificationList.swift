/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
/**
 Notification list has been shown here with image and the ids 
 */
struct NotificationList : Codable {
    let profilePic : String?
    let userId : String?
    let createdDate : Int?
    let typeOfNotify : Int?
    let message : String?
    let notifyId : String?
    let isRead : Bool?
    var isShowButton : Bool?
    let isAccept : Bool?
    let allowAnonymous : Bool?
    let displayName : String?
    let gender : Int?
    let postId : String?
    let threadId : String?

    enum CodingKeys: String, CodingKey {

        case profilePic = "profilePic"
        case userId = "userId"
        case createdDate = "createdDate"
        case typeOfNotify = "typeOfNotify"
        case message = "message"
        case notifyId = "notifyId"
        case isRead = "isRead"
        case isShowButton = "isShowButton"
        case isAccept = "isAccept"
        case allowAnonymous = "allowAnonymous"
        case displayName = "displayName"
        case gender = "gender"
        case postId = "postId"
        case threadId = "threadId"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        createdDate = try values.decodeIfPresent(Int.self, forKey: .createdDate)
        typeOfNotify = try values.decodeIfPresent(Int.self, forKey: .typeOfNotify)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        notifyId = try values.decodeIfPresent(String.self, forKey: .notifyId)
        isRead = try values.decodeIfPresent(Bool.self, forKey: .isRead)
        isShowButton = try values.decodeIfPresent(Bool.self, forKey: .isShowButton)
        isAccept = try values.decodeIfPresent(Bool.self, forKey: .isAccept)
        allowAnonymous = try values.decodeIfPresent(Bool.self, forKey: .allowAnonymous)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        gender = try values.decodeIfPresent(Int.self, forKey: .gender)
        postId = try values.decodeIfPresent(String.self, forKey: .postId)
        threadId = try values.decodeIfPresent(String.self, forKey: .threadId)
    }

}
