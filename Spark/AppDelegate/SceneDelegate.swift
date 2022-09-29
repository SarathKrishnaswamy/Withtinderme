//
//  SceneDelegate.swift
//  Spark
//
//  Created by Gowthaman P on 24/06/21.
//

import UIKit
import FBSDKCoreKit
import FirebaseDynamicLinks
import Firebase
import BackgroundTasks
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var appRefreshTaskId = "com.adhash.sparkfetch"
    var appProcessingTaskId = "com.adhash.sparkprocess"
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //hyperCriticalRulesExample()
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: appRefreshTaskId, using: nil) { task in
//           // Logger.shared.info("[BGTASK] Perform bg fetch \(appRefreshTaskId)")
//            print("[BGTASK] Perform bg fetch \(self.appRefreshTaskId)")
//            task.setTaskCompleted(success: true)
//            self.scheduleAppRefresh()
//        }
//
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: appProcessingTaskId, using: nil) { task in
//            //Logger.shared.info("[BGTASK] Perform bg processing \(appProcessingTaskId)")
//            print("[BGTASK] Perform bg processing \(self.appProcessingTaskId)")
//            task.setTaskCompleted(success: true)
//            self.scheduleBackgroundProcessing()
//        }
        guard let _ = (scene as? UIWindowScene) else { return }
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        guard let userActivity = connectionOptions.userActivities.first(where: { $0.webpageURL != nil }) else { return }
        print("Incoming URL is \(userActivity.webpageURL)")
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL ?? URL(fileURLWithPath: "")) { (dynamicLink, error) in
            guard error == nil else{
                print("Found an error! \(error!.localizedDescription)")
                
                return
            }
            if let dynamicLink = dynamicLink {
                self.handleIncomingDynamicLink(dynamicLink)
            }
        }
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
               return
           }

           ApplicationDelegate.shared.application(
               UIApplication.shared,
               open: url,
               sourceApplication: nil,
               annotation: [UIApplication.OpenURLOptionsKey.annotation]
           )
        
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        
        //if let incomingURL = userActivity.webpageURL {
        print("Incoming URL is \(userActivity.webpageURL)")
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL ?? URL(fileURLWithPath: "")) { (dynamicLink, error) in
            guard error == nil else{
                print("Found an error! \(error!.localizedDescription)")
                return
            }
            if let dynamicLink = dynamicLink {
                self.handleIncomingDynamicLink(dynamicLink)
            }
        }
        // }
    }
    
   
    
    
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink?) {
        guard let dynamicLink = dynamicLink else { return }
        guard let deepLink = dynamicLink.url else { return }
        print("deepLink:\(deepLink)")
        let fileName = deepLink.absoluteString
        let fileArray = fileName.components(separatedBy: "/")
        
        let finalFileName = fileArray[4]
        
        
        if finalFileName == "ViewProfile"{
            let profileId = fileArray[5]
            SessionManager.sharedInstance.linkProfileUserId = profileId
            print(SessionManager.sharedInstance.linkProfileUserId)
            SessionManager.sharedInstance.isProfileFromBeforeLogin = true
            NotificationCenter.default.post(name: Notification.Name("listenProfiletLink"), object: [ "userId":profileId])
            
            
        }
        
        else if finalFileName == "NFTPost"{
            let postId = fileArray[5]
            let userId = fileArray[6].dropFirst(3)
            let threadId = fileArray[7].dropFirst(4)
            SessionManager.sharedInstance.linkNFTPostId = postId
            SessionManager.sharedInstance.linkNFTThreadId = String(threadId)
            SessionManager.sharedInstance.linkNFTProfileUserId = String(userId)
            SessionManager.sharedInstance.isNftFromBeforeLogin = true
            NotificationCenter.default.post(name: Notification.Name("NFTPostLink"), object: [ "postId":postId, "userId":userId, "threadId":threadId])
        }
        else if finalFileName == "referral"{
            print(fileArray)
            let approvalCode = fileArray[5]
            SessionManager.sharedInstance.linkApprovalCode = approvalCode
            //NotificationCenter.default.post(name: Notification.Name("approvalCode"), object: ["approvalCode":approvalCode])
        }
        else{
            let postId = fileArray[4]
            let userId = fileArray[5].dropFirst(3)
            let threadId = fileArray[6].dropFirst(4)
            SessionManager.sharedInstance.linkFeedPostId = postId
            SessionManager.sharedInstance.linkFeedThreadId = String(threadId)
            SessionManager.sharedInstance.linkFeedProfileUserId = String(userId)
            SessionManager.sharedInstance.isFeedFromBeforeLogin = true
            SessionManager.sharedInstance.isFromLink = true
            print(SessionManager.sharedInstance.linkFeedPostId)
            print(SessionManager.sharedInstance.linkFeedThreadId)
            if SessionManager.sharedInstance.getAccessToken != "" {
            NotificationCenter.default.post(name: Notification.Name("listenPostLink"), object: ["postId":postId, "userId":userId, "threadId":threadId])
            }
//          
        }
        //print(finalFileName)
       
        
    }
    
//    func scheduleAppRefresh() {
//        print("bg fetch")
//            let request = BGAppRefreshTaskRequest(identifier: appRefreshTaskId)
//
//            request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Refresh after 5 minutes.
//
//            do {
//                try BGTaskScheduler.shared.submit(request)
//            } catch {
//                print("Could not schedule app refresh task \(error.localizedDescription)")
//            }
//        }
//
//         @available(iOS 13.0, *)
//        func scheduleBackgroundProcessing() {
//            print("bg process")
//            let request = BGProcessingTaskRequest(identifier: appProcessingTaskId)
//            request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
//            request.requiresExternalPower = false // Need to true if your task requires a device connected to power source. Defaults to false.
//
//            request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60) // Process after 5 minutes.
//
//            do {
//                try BGTaskScheduler.shared.submit(request)
//            } catch {
//                print("Could not schedule image fetch: (error)")
//            }
//        }
//
    func sceneDidDisconnect(_ scene: UIScene) {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        
        
        
      
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let latestVersionStr = SessionManager.sharedInstance.settingData?.data?.versionInfo?.latestVersion
        if latestVersionStr != "\(Bundle.main.releaseVersionNumberPretty)" && SessionManager.sharedInstance.settingData?.data?.versionInfo?.isUpdate == 1 {
            updateAlert()
        }
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
//        self.scheduleAppRefresh()
//        self.scheduleBackgroundProcessing()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    fileprivate func updateAlert() {
        // create the alert
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleFont = [NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
        let titleAttrString = NSMutableAttributedString(string: SessionManager.sharedInstance.settingData?.data?.versionInfo?.updateTitle ?? "", attributes: titleFont as [NSAttributedString.Key : Any])
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        let messageFont = [NSAttributedString.Key.font: UIFont.MontserratRegular(.normal)]
        let messageAttrString = NSMutableAttributedString(string: "\n\(SessionManager.sharedInstance.settingData?.data?.versionInfo?.updateMsg ?? "")", attributes: messageFont as [NSAttributedString.Key : Any])
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        if SessionManager.sharedInstance.settingData?.data?.versionInfo?.forceUpdate ?? false == false { //Optional Update
            alert.addAction(UIAlertAction(title: "Skip Now", style: .cancel, handler: { (_) in
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (_) in
            if let url = URL(string: SessionManager.sharedInstance.settingData?.data?.versionInfo?.playStoreUrl ?? "") {
                UIApplication.shared.open(url)
            }
        }))
        // show the alert
        window?.rootViewController?.present(alert, animated: true, completion: nil)
        //self.present(alert, animated: true, completion: nil)
    }
    
}

