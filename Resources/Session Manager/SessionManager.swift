//
//  SessionManager.swift
//  Spark
//
//  Created by Gowthaman P on 28/06/21.
//
import UIKit
/**
 Sessionmanager is used to save all the details using user defaults
 */
class SessionManager: NSObject {
    
    var settingData : SettingModel?
    var homeFeedsSwippedObject : HomeFeeds?

    static let sharedInstance = SessionManager()
    ///This method is used to save the firebase 'verification id' while login with mobile number
    var verificationID: String{
        get {
            return UserDefaults.standard.object(forKey: "verificationID") as? String != nil ? UserDefaults.standard.object(forKey: "verificationID") as! String : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "verificationID")
            defaults.synchronize()
        }
    }
    
    var getTagNameFromFeedDetails: [String:Any]?{
        get {
            return UserDefaults.standard.object(forKey: "getTagNameFromFeedDetails") as? [String:Any] ?? [String : Any]()
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "getTagNameFromFeedDetails")
            defaults.synchronize()
        }
    }
    
    ///This method is used to save the mobile number typed by the user
    var saveDeviceToken: String{
        get {
            return UserDefaults.standard.object(forKey: "DeviceToken") as? String != nil ? UserDefaults.standard.object(forKey: "DeviceToken") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "DeviceToken")
            defaults.synchronize()
        }
    }
    ///This method is used to save the user id
    var getUserId: String{
        get {
            return UserDefaults.standard.object(forKey: "getUserId") as? String != nil ? UserDefaults.standard.object(forKey: "getUserId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "getUserId")
            defaults.synchronize()
        }
    }
    ///This method is used to save the access token
    var getAccessToken: String{
        get {
            return UserDefaults.standard.object(forKey: "getAccessToken") as? String != nil ? UserDefaults.standard.object(forKey: "getAccessToken") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "getAccessToken")
            defaults.synchronize()
        }
    }
    ///This method is used to save the user login details
    var isUserLoggedIn : Bool{
        get {
            return UserDefaults.standard.object(forKey: "isUserLoggedIn") as? Bool != nil ? UserDefaults.standard.object(forKey: "isUserLoggedIn") as? Bool ?? false : false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isUserLoggedIn")
            defaults.synchronize()
        }
    }
   
    ///This method is used to save user details
    ///User Details
    var saveUserDetails: [String:Any]{
        get {
            return UserDefaults.standard.object(forKey: "saveUserDetails") as? [String:Any] ?? [String : Any]()
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveUserDetails")
            defaults.synchronize()
        }
    }
    
    ///This method is used to save the threadId
        var threadId: String{
            get {
                return UserDefaults.standard.object(forKey: "threadId") as? String != nil ? UserDefaults.standard.object(forKey: "threadId") as? String ?? "" : ""
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "threadId")
                defaults.synchronize()
            }
        }
    
    ///This method is used to save the userIdFromSelectedBubbleList
        var userIdFromSelectedBubbleList: String{
            get {
                return UserDefaults.standard.object(forKey: "userIdFromSelectedBubbleList") as? String != nil ? UserDefaults.standard.object(forKey: "userIdFromSelectedBubbleList") as? String ?? "" : ""
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "userIdFromSelectedBubbleList")
                defaults.synchronize()
            }
        }
    
    ///Save mobile number verified or not verified
    var isMobileNumberVerified: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isMobileNumberVerified") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isMobileNumberVerified")
            defaults.synchronize()
        }
    }
    
    var isRepost: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isRepost") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isRepost")
            defaults.synchronize()
        }
    }
    
    ///Save mobile number
    var saveMobileNumber: String{
        get {
            return UserDefaults.standard.object(forKey: "saveMobileNumber") as? String ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveMobileNumber")
            defaults.synchronize()
        }
    }
    
    ///Save country code
    var saveCountryCode: String{
        get {
            return UserDefaults.standard.object(forKey: "saveCountryCode") as? String ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveCountryCode")
            defaults.synchronize()
        }
    }
    
    ///Save Email
    var saveEmail: String{
        get {
            return UserDefaults.standard.object(forKey: "saveEmail") as? String ?? ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveEmail")
            defaults.synchronize()
        }
    }
    
    ///isContactApprovedOrNot
    var isContactApprovedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isContactApprovedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isContactApprovedOrNot")
            defaults.synchronize()
        }
    }
    
    ///isContactSync
    var isContactSyncedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isContactSyncedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isContactSyncedOrNot")
            defaults.synchronize()
        }
    }
    ///isProfileUpdatedOrNot
    var isProfileUpdatedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isProfileUpdatedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isProfileUpdatedOrNot")
            defaults.synchronize()
        }
    }
    
    var createPageisProfileUpdatedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "createPageisProfileUpdatedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "createPageisProfileUpdatedOrNot")
            defaults.synchronize()
        }
    }
    
    var attachementPageisProfileUpdatedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "attachementPageisProfileUpdatedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "attachementPageisProfileUpdatedOrNot")
            defaults.synchronize()
        }
    }
    
    var loopsPageisProfileUpdatedOrNot: Bool{
        get {
            return UserDefaults.standard.object(forKey: "loopsPageisProfileUpdatedOrNot") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "loopsPageisProfileUpdatedOrNot")
            defaults.synchronize()
        }
    }
    
    ///This method is used to save the mobile number typed by the user
    var saveAppleSocilaID: String{
        get {
            return UserDefaults.standard.object(forKey: "saveAppleSocilaID") as? String != nil ? UserDefaults.standard.object(forKey: "saveAppleSocilaID") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveAppleSocilaID")
            defaults.synchronize()
        }
    }
    
    ///User Current Location Details
    var saveUserCurrentLocationDetails: [String:Any]{
        get {
            return UserDefaults.standard.object(forKey: "saveUserCurrentLocationDetails") as? [String:Any] ?? [String : Any]()
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveUserCurrentLocationDetails")
            defaults.synchronize()
        }
    }
    
    ///This method is used to save the mobile number typed by the user
    var saveLoginMedium: String{
        get {
            return UserDefaults.standard.object(forKey: "saveLoginMedium") as? String != nil ? UserDefaults.standard.object(forKey: "saveLoginMedium") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "saveLoginMedium")
            defaults.synchronize()
        }
    }
    
    ///Save Tag Details
      var saveUserTagDetails: [String:Any]{
        get {
          return UserDefaults.standard.object(forKey: "saveUserTagDetails") as? [String:Any] ?? [String : Any]()
        }
        set {
          let defaults = UserDefaults.standard
          defaults.set(newValue, forKey: "saveUserTagDetails")
          defaults.synchronize()
        }
      }
    ///Save which controller loaded
    var isBoolForInshortsLayout : Bool{
        get {
            return UserDefaults.standard.object(forKey: "isBoolForInshortsLayout") as? Bool != nil ? UserDefaults.standard.object(forKey: "isBoolForInshortsLayout") as? Bool ?? false : false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isBoolForInshortsLayout")
            defaults.synchronize()
        }
    }
    
    ///This method is used to save the initial base post id
        var isUserPostId: String{
            get {
                return UserDefaults.standard.object(forKey: "isUserPostId") as? String != nil ? UserDefaults.standard.object(forKey: "isUserPostId") as? String ?? "" : ""
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "isUserPostId")
                defaults.synchronize()
            }
        }
    
    ///This method is used to save the last received message id
        var lastMsgId: String{
            get {
                return UserDefaults.standard.object(forKey: "lastMsgId") as? String != nil ? UserDefaults.standard.object(forKey: "lastMsgId") as? String ?? "" : ""
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "lastMsgId")
                defaults.synchronize()
            }
        }
    var saveGender: Int{
            get {
                return UserDefaults.standard.object(forKey: "saveGender") as? Int != nil ? UserDefaults.standard.object(forKey: "saveGender") as? Int ?? 0 : 0
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "saveGender")
                defaults.synchronize()
            }
        }
    
    var selectedIndexTabbar: Int{
            get {
                return UserDefaults.standard.object(forKey: "selectedIndexTabbar") as? Int != nil ? UserDefaults.standard.object(forKey: "selectedIndexTabbar") as? Int ?? 0 : 0
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "selectedIndexTabbar")
                defaults.synchronize()
            }
        }
    
    ///Save is image full view viewed
        var isImageFullViewed : Bool {
            get {
                return UserDefaults.standard.object(forKey: "isImageFullViewed") as? Bool != nil ? UserDefaults.standard.object(forKey: "isImageFullViewed") as? Bool ?? false : false
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "isImageFullViewed")
                defaults.synchronize()
            }
        }
    
    ///This method is used to save the refresh token
        var getRefreshToken: String{
            get {
                return UserDefaults.standard.object(forKey: "getRefreshToken") as? String != nil ? UserDefaults.standard.object(forKey: "getRefreshToken") as? String ?? "" : ""
            }
            set {
                let defaults = UserDefaults.standard
                defaults.set(newValue, forKey: "getRefreshToken")
                defaults.synchronize()
            }
        }
    
    
    ///isFromLink
    var isPostFromLink: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isPostFromLink") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isPostFromLink")
            defaults.synchronize()
        }
    }
    
    ///ApprovalCode
    var getApprovalCode: String{
        get {
            return UserDefaults.standard.object(forKey: "getApprovalCode") as? String != nil ? UserDefaults.standard.object(forKey: "getApprovalCode") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "getApprovalCode")
            defaults.synchronize()
        }
    }
    
    ///ApprovalCode
    var linkApprovalCode: String{
        get {
            return UserDefaults.standard.object(forKey: "linkApprovalCode") as? String != nil ? UserDefaults.standard.object(forKey: "linkApprovalCode") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkApprovalCode")
            defaults.synchronize()
        }
    }
    
    ///profileUserId
    var linkProfileUserId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkProfileUserId") as? String != nil ? UserDefaults.standard.object(forKey: "linkProfileUserId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkProfileUserId")
            defaults.synchronize()
        }
    }
    
    ///PostId
    var linkPostId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkPostId") as? String != nil ? UserDefaults.standard.object(forKey: "linkPostId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkPostId")
            defaults.synchronize()
        }
    }
    
    ///ThreadId
    var linkThreadId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkThreadId") as? String != nil ? UserDefaults.standard.object(forKey: "linkThreadId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkThreadId")
            defaults.synchronize()
        }
    }

    
    //FeedUserId
    var linkFeedProfileUserId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkFeedProfileUserId") as? String != nil ? UserDefaults.standard.object(forKey: "linkFeedProfileUserId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkFeedProfileUserId")
            defaults.synchronize()
        }
    }
    
    ///PostId
    var linkFeedPostId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkFeedPostId") as? String != nil ? UserDefaults.standard.object(forKey: "linkFeedPostId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkFeedPostId")
            defaults.synchronize()
        }
    }
    
    ///ThreadId
    var linkFeedThreadId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkFeedThreadId") as? String != nil ? UserDefaults.standard.object(forKey: "linkFeedThreadId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkFeedThreadId")
            defaults.synchronize()
        }
    }

    
    var linkNFTProfileUserId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkNFTProfileUserId") as? String != nil ? UserDefaults.standard.object(forKey: "linkNFTProfileUserId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkNFTProfileUserId")
            defaults.synchronize()
        }
    }
    
    ///PostId
    var linkNFTPostId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkNFTPostId") as? String != nil ? UserDefaults.standard.object(forKey: "linkNFTPostId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkNFTPostId")
            defaults.synchronize()
        }
    }
    
    ///ThreadId
    var linkNFTThreadId: String{
        get {
            return UserDefaults.standard.object(forKey: "linkNFTThreadId") as? String != nil ? UserDefaults.standard.object(forKey: "linkNFTThreadId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "linkNFTThreadId")
            defaults.synchronize()
        }
    }

    
    //sharebefor Profile login
    var isProfileFromBeforeLogin: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isFromBeforeLogin") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isFromBeforeLogin")
            defaults.synchronize()
        }
    }
    
    var isFeedFromBeforeLogin: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isFromBeforeLogin") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isFromBeforeLogin")
            defaults.synchronize()
        }
    }
    
    
    
    var isFromLink: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isFromLink") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isFromLink")
            defaults.synchronize()
        }
    }
    
    var isNftFromBeforeLogin: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isFromBeforeLogin") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isFromBeforeLogin")
            defaults.synchronize()
        }
    }
    
    //get other user id
    var otherUserId: String{
        get {
            return UserDefaults.standard.object(forKey: "otherUserId") as? String != nil ? UserDefaults.standard.object(forKey: "otherUserId") as? String ?? "" : ""
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "otherUserId")
            defaults.synchronize()
        }
    }
    
    
    //get other user id
    var isKYC: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isKYC") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isKYC")
            defaults.synchronize()
        }
    }
    
    
    //get other user id
    var isNFT: Int{
        get {
            return UserDefaults.standard.object(forKey: "isNFT") as? Int != nil ? UserDefaults.standard.object(forKey: "isNFT") as? Int ?? 0 : 0
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isNFT")
            defaults.synchronize()
        }
    }
    
    var isMonetize: Int{
        get {
            return UserDefaults.standard.object(forKey: "isMonetize") as? Int != nil ? UserDefaults.standard.object(forKey: "isMonetize") as? Int ?? 0 : 0
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isMonetize")
            defaults.synchronize()
        }
    }
    
    //get other user id
    var isSkip: Bool{
        get {
            return UserDefaults.standard.object(forKey: "isSkip") as? Bool ?? false
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isSkip")
            defaults.synchronize()
        }
    }
    
    
    //get other user id
    var isAgree: Int{
        get {
            return UserDefaults.standard.object(forKey: "isAgree") as? Int != nil ? UserDefaults.standard.object(forKey: "isAgree") as? Int ?? 0 : 0
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "isAgree")
            defaults.synchronize()
        }
    }
  
}
