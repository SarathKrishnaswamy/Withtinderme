//
//  BlockUserTableViewCellViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 29/08/21.
//

import UIKit

class BlockedUserListTableViewCellViewModel: NSObject {

    /// Model list for blocked user list
    private var blockedUserList:BlockedUserListModelUsers?

    init(withModel:BlockedUserListModelUsers?)
      {
        blockedUserList = withModel
      }
    
    ///Get the user name
    public var getName: String {
        return self.blockedUserList?.displayName ?? ""
    }
    
    ///Get the connection count
    public var getConnectionCount: String {
        return "\(self.blockedUserList?.connectionCount ?? 0) Connections"
    }
    
    /// Get the profile image from api of settings
    //notification Name
    public var getProfileImage: String {
        
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.blockedUserList?.profilePic ?? "")"
        
        return url
    }
    
    ///Get the gender from the model list
    public var gender: Int {
        return self.blockedUserList?.gender ?? 0
    }
    
}
