//
//  FeedDetailNftCellViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 02/03/22.
//

import Foundation
import UIKit

class FeedDetailNftCellViewModel {

    private var userListData:NftSparkDetailModel?
    
    init(withModel:NftSparkDetailModel?)
      {
        userListData = withModel
      }

    ///Profile Name
    public var getProfileName: String {
        return self.userListData?.profileName ?? ""
    }
    
    ///Date
    public var getPostedTime:String {
        let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(self.userListData?.createdDate ?? 0)")
        
        return Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
    }
    
    ///Profile Image
    public var getProfileImage: String {
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.userListData?.profilePic ?? "")"
        return url
    }
    
    ///PostType
    public var getPostType: Int {
        return self.userListData?.postType ?? 0
    }
    
    ///Tag Name
    public var getTagName: String {
        return self.userListData?.tagName ?? ""
    }
    
    ///Posted Content
    public var getPostedText: String {
        return self.userListData?.postContent ?? ""
    }
    
    
    /// Get the NFT value
    public var getNft: Int {
        return self.userListData?.nft ?? 0
    }
    
    
    ///Posted Media Url
    public var getPostedMediaUrl: String {
        
        var url = ""
        url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.userListData?.mediaUrl ?? "")"
        
        switch self.userListData?.mediaType  {
        case MediaType.Video.rawValue:
            url = self.userListData?.mediaUrl ?? ""
        default:
            break
        }

        return url
    }
    
    /// Get the posted thumbnail url
    public var getPostedThumbnailUrl: String {
        
        var url = ""
        url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.userListData?.thumbNail ?? "")"
        
        switch self.userListData?.mediaType  {
        case MediaType.Image.rawValue:
            url = self.userListData?.thumbNail ?? ""
        default:
            break
        }

        return url
    }
    
    ///Get View Count
    public var getViewCount: Int {
        return self.userListData?.viewCount ?? 0
    }
    
    ///Get Connection Count
    public var getThreadCount: Int {
        return self.userListData?.threadCount ?? 0
    }
   
    ///Get Clap Count
    public var getClapCount: Int {
        return self.userListData?.clapCount ?? 0
    }
    
    ///Get Posted Media Type
    public var getMediaType: Int {
        return self.userListData?.mediaType ?? 0
    }
    
    //Get TxtView Bg Color
    public var getTextViewBgColor: String {
        return self.userListData?.bgColor ?? ""
    }
    
    ///Get Text Color
    public var getTextViewTxtColor: String {
        return self.userListData?.textColor ?? ""
    }
    
    ///Get Text Color
    public var isAnonymousUser: Bool {
        return self.userListData?.allowAnonymous ?? false
    }
    
    //Get gender
    public var getGender: Int {
        return self.userListData?.gender ?? 1
    }
    
    ///Get gender
    public var userId: String {
        return self.userListData?.userId ?? ""
    }
    
    ///Get gender
    public var monetize: Int {
        return self.userListData?.monetize ?? 0
    }
}
