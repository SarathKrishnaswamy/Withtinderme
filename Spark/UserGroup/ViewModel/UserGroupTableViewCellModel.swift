//
//  UserGroupTableViewModel.swift
//  Spark me
//
//  Created by adhash on 17/09/21.
//

import Foundation

final class UserGroupTableViewCellModel {
        
    var viewUserData : ViewUsers?
    
    private let networkManager = NetworkManager()
    

    init(withModel:ViewUsers?)
      {
        viewUserData = withModel
      }
    

    ///bubble Name
    public var getConversationImage: String {

        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.viewUserData?.profilePic ?? "")"
        
        return url
    }
   
    ///bubble Name
    public var getVisibleDate: String {
        
        let dateString = convertTimeStampToDOBWithTime(timeStamp: "\(self.viewUserData?.createdDate ?? 0)")
        
        return convertTimeStampToDate(timeStamp: dateString).timeAgo(timeStamp:  "\(self.viewUserData?.createdDate ?? 0)")//timeAgoDisplay(DateString: dateString)
        
    }
    
    //bubble display name
    public var displayName: String {
        return self.viewUserData?.displayname ?? ""
    }
    
    ///bubble display name
    public var gender: Int {
        return self.viewUserData?.gender ?? 0
    }
    
    
    ///  Covert the time stamp to date
    func convertTimeStampToDate(timeStamp:String) -> Date {
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.date(from: timeStamp) ?? Date()
    }
    
    /// convert time stamp to dob with time
    func convertTimeStampToDOBWithTime(timeStamp:String) -> String {
            let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
            let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
            let dateFormater : DateFormatter = DateFormatter()
            dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            return dateFormater.string(from: dateFromServer as Date)
        }
    
    /// Time stamp to string
    func timestampToStringAgo(timestamp: Int64) -> String{
        let actualTime = Int64(Date().timeIntervalSince1970*1000)
        var lastSeenTime = actualTime - timestamp
        lastSeenTime /= 1000 //seconds
        var lastTimeString = ""
        if lastSeenTime < 60 {
            if lastSeenTime == 1 {
                lastTimeString = String(lastSeenTime) + " second ago"
            } else {
                lastTimeString = String(lastSeenTime) + " seconds ago"
            }
        } else {
            lastSeenTime /= 60
            if lastSeenTime < 60 {
                if lastSeenTime == 1 {
                    lastTimeString =  String(lastSeenTime) + " minute ago"
                } else {
                    lastTimeString =  String(lastSeenTime) + " minutes ago"
                }
                
            } else {
                lastSeenTime /= 60
                if lastSeenTime < 24 {
                    if lastSeenTime == 1 {
                        lastTimeString = String(lastSeenTime) + " hour ago"
                    } else {
                        lastTimeString = String(lastSeenTime) + " hours ago"
                    }
                } else {
                    lastSeenTime /= 24
                    if lastSeenTime == 1 {
                        lastTimeString = String(lastSeenTime) + " day ago"
                    } else {
                        lastTimeString = String(lastSeenTime) + " days ago"
                    }
                }
            }
        }
        return lastTimeString
    }

}
