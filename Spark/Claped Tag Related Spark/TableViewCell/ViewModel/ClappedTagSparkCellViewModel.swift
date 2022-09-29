//
//  ClappedTagSparkCellViewModel.swift
//  Spark me
//
//  Created by Gowthaman P on 14/08/21.
//

import UIKit

class ClappedTagSparkCellViewModel {

    private var clappedData:ClapData?

    init(withModel:ClapData)
      {
        clappedData = withModel
      }
    
    ///Profile Name
    public var getProfileName: String {
        return self.clappedData?.profileName ?? ""
    }
    
    ///Date
    public var getPostedTime:String {
        let dateString = Helper.sharedInstance.convertTimeStampToDOBWithTime(timeStamp: "\(self.clappedData?.createdDate ?? 0)")
        
        return Helper.sharedInstance.convertTimeStampToDate(timeStamp: dateString).timeAgoSinceDate()
    }
    
    ///Profile Image
    public var getProfileImage: String {
        let url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("profilepic")/\(self.clappedData?.profilePic ?? "")"
        return url
    }
    
    ///PostType
    public var getPostType: Int {
        return self.clappedData?.postType ?? 0
    }
    
    ///Tag Name
    public var getTagName: String {
        return self.clappedData?.tagName ?? ""
    }
    
    ///Posted Content
    public var getPostedText: String {
        return self.clappedData?.postContent ?? ""
    }
    
    ///Posted Media Url
    public var getPostedMediaUrl: String {
        
        var url = ""
        url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.clappedData?.mediaUrl ?? "")"
        
        switch self.clappedData?.mediaType  {
        case MediaType.Video.rawValue:
            url = self.clappedData?.mediaUrl ?? ""
        default:
            break
        }

        return url
    }
    
    /// Get the posted thumbnail url
    public var getPostedThumbnailUrl: String {
        
        var url = ""
        url = "\(SessionManager.sharedInstance.settingData?.data?.blobURL ?? "")\(SessionManager.sharedInstance.settingData?.data?.blobContainerName ?? "")/\("post")/\(self.clappedData?.thumbNail ?? "")"
        
//        switch self.clappedData?.mediaType  {
//        case MediaType.Video.rawValue:
//            url = url
//        default:
//            break
//        }

        return url
    }
    
    ///Get View Count
    public var getViewCount: Int {
        return self.clappedData?.viewCount ?? 0
    }

    ///Get Clap Count
    public var getClapCount: Int {
        return self.clappedData?.clapCount ?? 0
    }
    
    ///Get thread Count
    public var getThreadCount: Int {
        return self.clappedData?.threadCount ?? 0
    }
    
    ///Get Posted Media Type
    public var getMediaType: Int {
        return self.clappedData?.mediaType ?? 0
    }
    
    ///Get TxtView Bg Color
    public var getTextViewBgColor: String {
        return self.clappedData?.bgColor ?? ""
    }
    
    ///Get Text Color
    public var getTextViewTxtColor: String {
        return self.clappedData?.textColor ?? ""
    }
    
    ///Get Anonymous User
    public var allowAnonymous: Bool {
        return self.clappedData?.allowAnonymous ?? false
    }
    
    ///Get Anonymous User
    public var gender: Int {
        return self.clappedData?.gender ?? 0
    }
    
    ///Get Anonymous User
    public var getNFTstatus: Int {
        return self.clappedData?.nft ?? 0
    }
    
   
}



