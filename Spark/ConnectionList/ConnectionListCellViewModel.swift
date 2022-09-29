//
//  ConnectionListCellViewModel.swift
//  Spark me
//
//  Created by adhash on 31/08/21.
//

import Foundation

/**
 This class is used to set  view model in the closed connections with get the user name, get connection count  and get notification image and set the gender.
 */
final class ConnectionListCellViewModel {
    
    private var closedConnectionFriendsData:ClosedConnectionFriends?

    init(withModel:ClosedConnectionFriends?)
      {
        closedConnectionFriendsData = withModel
      }
    
    //getUserName
    public var getUserName: String {
        return self.closedConnectionFriendsData?.displayName ?? ""
    }
    
    //getUserName
    public var getConnectionCount: String {
        return "\(self.closedConnectionFriendsData?.connectionCount ?? 0) Connections"
    }
    
    //notification Name
    public var getNotificationImage: String {
        
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.closedConnectionFriendsData?.profilePic ?? "")"
        
        return url
    }
    
    //Get Gender
    public var getGender: Int {
        return self.closedConnectionFriendsData?.gender ?? 0
    }
}
