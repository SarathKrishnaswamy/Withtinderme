//
//  NotificationCellViewModel.swift
//  Spark me
//
//  Created by adhash on 14/08/21.
//

import Foundation

final class NotificationCellViewModel {
    
    private var notificationListData:NotificationList?

    init(withModel:NotificationList?)
      {
        notificationListData = withModel
      }
    
    //notification Name
    public var getNotificationMessage: String {
        return self.notificationListData?.message ?? ""
    }
    
    //notification Name
    public var getNotificationImage: String {
        
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.notificationListData?.profilePic ?? "")"
        
        return url
    }
    
    //Notification Time
    public var getNotificationTime:String {
        let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(self.notificationListData?.createdDate ?? 0)")
        
        return Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
    }
    
    //Type of notification
    public var getTypeOfNotify: Int {
        return self.notificationListData?.typeOfNotify ?? 0
    }
    
    //Show accept/reject btn
    public var getAcceptRejectStatus: Bool {
        return self.notificationListData?.isShowButton ?? false
    }
    
    //Show Display Name
    public var displayName: String {
        return self.notificationListData?.displayName ?? ""
    }
    
    //Show Allow anonymous
    public var allowAnonymousUser: Bool {
        return self.notificationListData?.allowAnonymous ?? false
    }
    
    //Get Gender
    public var getGender: Int {
        return self.notificationListData?.gender ?? 0
    }
}
