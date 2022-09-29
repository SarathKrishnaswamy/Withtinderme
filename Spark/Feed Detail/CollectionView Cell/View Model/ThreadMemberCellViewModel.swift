//
//  ThreadMemberCellViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 13/08/21.
//

import UIKit
/**
 Thread member cell view model is used to retrive from api and set the name and get the image and check anonymous user
 */
class ThreadMemberCellViewModel {

    private var userListData:MembersList?
    
    init(withModel:MembersList?)
      {
        userListData = withModel
      }

    public var getName: String {
        return self.userListData?.displayName ?? ""
    }
    
    public var getImage: String {
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.userListData?.profilePic ?? "")"
        return url
    }
    
    public var isAnonymousUser: Bool {
        return self.userListData?.allowAnonymous ?? false
    }
    
    
}
