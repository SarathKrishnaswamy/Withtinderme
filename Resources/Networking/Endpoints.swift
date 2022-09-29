//
//  Endpoints.swift
//  
//
//

import Foundation

///  Set all the update endpoints api calls here with dev and live url here
enum Endpoints: String {

    //Dev
    case user_base = "https://sparkdev.synctag.com/api/"//"https://spark.synctag.com/api/" //"https://sparkdev.synctag.com/api/"//
    case socket_base = "https://sparkdev.synctag.com/socket"//"https://spark.synctag.com" //"https://sparkdev.synctag.com/socket"//
    case razorPayTestKey = "rzp_test_wwVVWvbM40vF9d" //rzp_live_BQV5kjx8ap1OVA
//
    
    //live
    
//    case user_base = "https://spark.synctag.com/api/"//"https://spark.synctag.com/api/" //"https://sparkdev.synctag.com/api/"//
//    case socket_base = "https://spark.synctag.com"//"https://spark.synctag.com" //"https://sparkdev.synctag.com/socket"//
//    case razorPayTestKey = "rzp_live_BQV5kjx8ap1OVA" //rzp_live_BQV5kjx8ap1OVA
    
    
    //Cocunut Api
    case coconutApi = "https://api.coconut.co/v2/jobs" //---- 1
    
    case refreshToken = "auth/refresh" // ---- 2
    
    case generateToken = "auth/generateToken" //---- 3
    
    case home = "Post/home" //---- 4
    
    case getPostDetailsById = "post/getPostDetailsById" //---- 5
    
    case homeClap = "claps/add" //---- 6
    
    case homeList = "claps/list" //---- 7
    
    case viewList = "view/list" //---- 8
    
    case settings = "setting/1" //---- 9
    
    case signup = "auth/login" //---- 10
   // case login = "user/login"
    //case resendEmail = "user/resendEmail"
    case updateProfile = "users/updateprofile" //---- 11
    
    case getProfile = "users/profile" //---- 12
    
    case getMyPostedTimeline = "Post/timeline" //---- 13
    
    case closedConnectionList = "connection/connectionList" //---- 14
    
    case createPost = "post" //---- 15
    
    case monetizeRepost = "post/monetizeRepost" //---- 16
    
    case checkThreadLimit = "post/checkThreadLimit"  //---- 17
    
    case checkTagStatus = "post/checkTagsStatusbyId" //---- 18
    
    case gettagsForPost = "tags" //---- 19
    
    case threadRequest = "thread" //---- 20
    
    case feedSearch = "post/search" //----21
    
    case notify = "notify" //---- 22
    
    case approveAccount = "notify/read" //---- 23
    
    case threadBubbleList = "thread/bubbleList" //---- 24
    
    case threadconversationList = "thread/conversationList" //---- 25
    
    case getPostDetail = "thread/getThreadById" //---- 26
    
    case bubbleTagList = "tags/tagListUserbyId" //---- 27
    
    case threadMemberList = "thread/getThreadMemberList" //---- 28
    
    case reportThreadUser = "thread/reportThreadUser" // ---- 29
    
    case bubbleDelete = "thread/bubbleUpdateById" // ---- 30
    
    case getSelectedMemberPostDetail = "thread/getThreadByPostId" // ---- 31
    
    case getBlockedUserList = "users/blockedUserlist" //---- 32
    
    case getBlockUserList = "users/connectionlistById" //---- 33
    
    case blockSelectedUser = "users/blockedUserSave" //---- 34
    
    case otpVerifyForSocialMediaLogin = "users/updateIsVerfied" //---- 35
    
    case contactSync = "users/contactSync" // Not needed this class is not used
    
    case getProfileById = "users/getProfileById" //---- 36
    
    case timelineById = "post/userTimelineById" //---- 38
    
    case GetApprovedStatus = "users/GetApprovedStatus" //Not needed this class is not used
    
    case endConversation = "thread/conversationEnd" // Not Used
    
    case conversationCommentsList = "thread/conversationCommentList" // ---- 39
    
    case logOut = "users/logOut" //---- 40
    
    case threadReveal = "thread/saveThreadReveal" // ---- 41
    
    case approvedByToken = "users/approvedByToken" //---- 42
    
    case clapThread = "thread/clapThread" // ---- 43
    
    case getbubbleListById = "thread/getbubbleListById" // ---- 45
    
    case saveThreadrequest = "thread/clapHomeThread" //----- 46
    
    case userBynftId = "users/getNFTById" //---- 47
    
    case getNFTList = "post/getNFTList" //---- 48
    
    case getNFTDetail = "post/getNFTPostDetailsById" //---- 49
    
    case transferNFTDetail = "post/saveNFTTansferDetails" //---- 50
    
    case deletePost = "post/deletePostDetailsById" //---- 51
    
    case saveMediaByPostId = "post/saveMediaByPostId" //---- 52
    
    case getPostMediaList = "thread/getPostMediaList" // ---- 53
    
    case checkMonetizePostLimit = "post/checkMonetizePostLimit" //---54
    
    case clapMonetizeThread = "thread/clapMonetizeThread" //
    
    case getTransDetailsByType = "post/getTransDetailsByType" //---- 56
    
    case byId = "post/byId" //---- 57
    
    case eyeshotByPostId = "view/eyeshotByPostId" // ---- 58
    
    case delete = "users/accountDelete/ChQFeqJW9eHx2ksP" //---- 59

    case reportPostUser = "thread/reportPostUser" //----60
    
    /// Set the url as concatenate with retrun as string 
    func fullUrl(port: Int) -> String {
        if self == Endpoints.user_base {
            return self.rawValue
        }
        var fullUrl = ""
        if port == 1{
            fullUrl = Endpoints.user_base.rawValue + self.rawValue
        }else if port == 2{
            fullUrl = Endpoints.coconutApi.rawValue
           // fullUrl = Endpoints.milstone_base.rawValue + self.rawValue
        }
        return fullUrl
    }
}



