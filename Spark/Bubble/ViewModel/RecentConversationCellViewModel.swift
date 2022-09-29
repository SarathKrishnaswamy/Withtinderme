//
//  RecentConversationCellViewModel.swift
//  Spark me
//
//  Created by adhash on 03/09/21.
//

import Foundation

/**
 This class is used to set the recent conversation view model cell with array of  list data
 */

final class RecentConversationCellViewModel {
    
    var recentConversationListData:RecentConversationList?
    
    var recentConversationList = [RecentConversationList]()
    
    private let networkManager = NetworkManager()
    

    init(withModel:RecentConversationList?,withBubbleModel:[RecentConversationList]?)
      {
        recentConversationListData = withModel
        recentConversationList = withBubbleModel ?? [RecentConversationList]()
      }
    

    ///Conversation image
    public var getConversationImage: String {

        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.recentConversationListData?.profilePic ?? "")"
        
        return url
    }
    
    /// Get the post image
    public var getPostImage: String {

        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.recentConversationListData?.mediaUrl ?? "")"
        
        return url
    }
    
    /// Get the video thumbnail image
    public var getVideoThumpNailImage: String {

        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.recentConversationListData?.thumbNailUrl ?? "")"
        
        return url
    }
    
    ///Get the visible date
    public var getVisibleDate: String {
        
        let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(self.recentConversationListData?.modifiedDate ?? 0)")
        
       return convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
        
    }
    
    /// Get Recent display name
    public var displayName: String {
        return self.recentConversationListData?.displayName ?? ""
    }
    
    /// Get recent tagName
    public var tagName: String {
        return self.recentConversationListData?.tagName ?? ""
    }
    
    ///Get the tagName
    public var mediaType: Int {
        return self.recentConversationListData?.mediaType ?? 0
    }
    
    /// It is used to convert timestamp to date
    func convertTimeStampToDate(timeStamp:String) -> Date {
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.date(from: timeStamp) ?? Date()
    }
    
    /// Convert timestamp to dob with time
    func convertTimeStampToDOBWithTime(timeStamp:String) -> String {
            let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
            let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            return dateFormater.string(from: dateFromServer as Date)
        }

}
