//
//  AppDelegate.swift
//  Spark
//
//  Created by Gowthaman P on 24/06/21.
//

import UIKit
import CoreData
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import FirebaseMessaging
import GoogleMaps
import GooglePlaces
import PhotoEditorSDK
import Contacts
import SocketIO
import FirebaseDynamicLinks
import IQKeyboardManagerSwift
import UserNotifications
import AVKit
import BackgroundTasks


enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

/**
 This calls the first when the app launches this class calls immediately with user notifiication delegate
 */
@main
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {
    
    let hostNames = ["google.com", "google.com", "google.com"]
    var hostIndex = 0
    var reachability  = try! Reachability()
    var isInternetConnected = Connection.isConnectedToNetwork()
    let customURLScheme = "dlscheme"
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    let notificationCenter = UNUserNotificationCenter.current()
    var isSound = false
    static var shared: AppDelegate {
            UIApplication.shared.delegate as! AppDelegate
        }
    
    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations where the user launched the app directly. For information about the possible keys in this dictionary and how to handle them, see UIApplication.LaunchOptionsKey.
    /// - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    /// - Use this method (and the corresponding application(_:willFinishLaunchingWithOptions:) method) to complete your app’s initialization and make any final tweaks. This method is called after state restoration has occurred but before your app’s window and other UI have been presented. At some point after this method returns, the system calls another of your app delegate’s methods to move the app to the active (foreground) state or the background state.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //KeychainItem.deleteUserIdentifierFromKeychain()
        
      
        notificationCenter.delegate = self
//        let audioSession = AVAudioSession.sharedInstance()
//               
//               do {
//                   try audioSession.setCategory(AVAudioSession.Category.playback)
//               } catch  {
//                   print("Audio session failed")
//               }
               
        
        IQKeyboardManager.shared.enable = true
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.adhash.spark", using: DispatchQueue.main) { task in
                    self.handleAppRefresh(task: task as! BGProcessingTask)
                }
        //fetchContacts()
        
        //sleep(2)
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = self.customURLScheme
        FirebaseApp.configure()
        
        NotificationConfiguration(application)
        IQKeyboardManager.shared.enable = false
        
        //FCM Registration
        Messaging.messaging().delegate = self
        
        
        ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )
            
        self.registerForPushNotifications(application: application)

        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "654931077657-31siiqp7fmlbida9udbatusfeuen3cep.apps.googleusercontent.com"//APIContstant.googleSigninClientKey
        GIDSignIn.sharedInstance().delegate = self        
        
        //Get firebase FCM token
        updateFirestorePushTokenIfNeeded()
        
        //Photo
        if let licenseURL = Bundle.main.url(forResource: "pesdk_ios_license _8_8_2021", withExtension: "") {
            PESDK.unlockWithLicense(at: licenseURL)
          }
        //Video
        if let licenseURL = Bundle.main.url(forResource: "vesdk_ios_license_8_8_2021", withExtension: "") {
            VESDK.unlockWithLicense(at: licenseURL)
          }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }
    func scheduleAppRefresh() {
           let request = BGProcessingTaskRequest(identifier: "com.adhash.spark")
           request.requiresNetworkConnectivity = true
           //request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // Fetch no earlier than 15 minutes from now
           
           do {
               try BGTaskScheduler.shared.submit(request)
               print("BGTask Scheduled")
           } catch {
               print("Could not schedule app refresh: \(error)")
           }
       }
       func handleAppRefresh(task: BGProcessingTask) {
           //Scehdules a second refresh
           scheduleAppRefresh()
          // BGNotification()
           print("BG Background Task fired")
   }
   
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        //debugPrint(<#T##Any#>)
        if identifier == "com.adhash.spark" {
                backgroundSessionCompletionHandler = completionHandler
            }
    }
    
    
    func scheduleNotification(notificationType: String, sound: Bool) {

           //Compose New Notificaion
           let content = UNMutableNotificationContent()
           let categoryIdentifire = "Delete Notification Type"
           content.sound = UNNotificationSound.default
           content.body = notificationType
           content.badge = 0
           content.categoryIdentifier = categoryIdentifire

           //Add attachment for Notification with more content
           if (notificationType == "Local Notification with Content")
           {
               let imageName = "Apple"
               guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
               let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
               content.attachments = [attachment]
           }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
           let identifier = "Local Notification"
           let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        self.isSound = true

           notificationCenter.add(request) { (error) in
               if let error = error {
                   print("Error \(error.localizedDescription)")
               }
           }

           //Add Action button the Notification
           if (notificationType == "Local Notification with Action")
           {
               let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
               let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
               let category = UNNotificationCategory(identifier: categoryIdentifire,
                                                     actions: [snoozeAction, deleteAction],
                                                     intentIdentifiers: [],
                                                     options: [])
               notificationCenter.setNotificationCategories([category])
           }
       }
    
    
    // [START openurl]
     @available(iOS 9.0, *)
     func application(_ app: UIApplication, open url: URL,
                      options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
       return application(app, open: url,
                          sourceApplication: options[UIApplication.OpenURLOptionsKey
                            .sourceApplication] as? String,
                          annotation: "")
     }

     func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                      annotation: Any) -> Bool {
       if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
         // Handle the deep link. For example, show the deep-linked content or
         // apply a promotional offer to the user's account.
         // [START_EXCLUDE]
         // In this sample, we just open an alert.
         handleDynamicLink(dynamicLink)
         // [END_EXCLUDE]
         return true
       }
       // [START_EXCLUDE silent]
       // Show the deep link that the app was called with.
       showDeepLinkAlertView(withMessage: "openURL:\n\(url)")
       // [END_EXCLUDE]
       return false
     }

     // [END openurl]
     // [START continueuseractivity]
     func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
       let handled = DynamicLinks.dynamicLinks()
         .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
           // [START_EXCLUDE]
           if let dynamiclink = dynamiclink {
             self.handleDynamicLink(dynamiclink)
           }
           // [END_EXCLUDE]
         }

       // [START_EXCLUDE silent]
       if !handled {
         // Show the deep link URL from userActivity.
         let message =
           "continueUserActivity webPageURL:\n\(userActivity.webpageURL?.absoluteString ?? "")"
         showDeepLinkAlertView(withMessage: message)
       }
       // [END_EXCLUDE]
       return handled
     }

     // [END continueuseractivity]
     func handleDynamicLink(_ dynamicLink: DynamicLink) {
       let matchConfidence: String
       if dynamicLink.matchType == .weak {
         matchConfidence = "Weak"
       } else {
         matchConfidence = "Strong"
       }
       let message = "App URL: \(dynamicLink.url?.absoluteString ?? "")\n" +
         "Match Confidence: \(matchConfidence)\nMinimum App Version: \(dynamicLink.minimumAppVersion ?? "")"
       showDeepLinkAlertView(withMessage: message)
     }

     func showDeepLinkAlertView(withMessage message: String) {
       let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
       let alertController = UIAlertController(
         title: "Deep-link Data",
         message: message,
         preferredStyle: .alert
       )
       alertController.addAction(okAction)
       window?.rootViewController?.present(alertController, animated: true, completion: nil)
     }
    
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    

    func updateFirestorePushTokenIfNeeded() {
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            debugPrint("Remote FCM registration token: \(token)")
            SessionManager.sharedInstance.saveDeviceToken = "\(token)"
          }
        }
    }
    
    //MARK: NOTIFICATION CONFIGURATION
    func NotificationConfiguration(_ application: UIApplication){
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self
          Messaging.messaging().delegate = self
          Messaging.messaging().isAutoInitEnabled = true
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        //MARK: DEFINE CATEGRORY ID FOR GEETING AND PROCESSING CUSTOM NOTIFICATION
        let openBoardAction = UNNotificationAction(identifier: UNNotificationDefaultActionIdentifier, title: "Open Board", options: UNNotificationActionOptions.foreground)
        let contentAddedCategory = UNNotificationCategory(identifier: "CATID!", actions: [openBoardAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([contentAddedCategory])

        application.registerForRemoteNotifications()
    }
   
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//      print("Firebase registration token: \(String(describing: fcmToken))")
//      let dataDict:[String: String] = ["token": fcmToken ?? ""]
//    SessionManager.sharedInstance.saveDeviceToken = "\(String(describing: fcmToken))"
//      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//    }
//    func application(application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//      Messaging.messaging().apnsToken = deviceToken
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        SessionManager.sharedInstance.saveDeviceToken = "\(String(describing: fcmToken))"
        updateFirestorePushTokenIfNeeded()

    }
  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Messaging.messaging().apnsToken = deviceToken
//        let token = Messaging.messaging().fcmToken
//        debugPrint("FCM Token:",token ?? "")
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
       // SessionManager.sharedInstance.saveDeviceToken = "\(String(describing: token))"
        // Pass device token to auth
        let deviceTokenString = deviceToken.hexString
        print("APNS Token:",deviceTokenString)
        SessionManager.sharedInstance.saveDeviceToken = deviceTokenString
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if isSound{
            completionHandler([.alert,.badge])
            self.isSound = false
        }
        else{
            completionHandler([.alert, .sound, .badge])
        }
        
    }
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        debugPrint(userInfo)
        print("*********************************")
        print(userInfo["typeOfnotify"] as? String ?? "")
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            if userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "1" || userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "2" || userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "3" ||  userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "5" ||  userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "6" ||  userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "7" || userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "8" || userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "9" || userInfo["gcm.notification.typeOfnotify"] as? String ?? "" == "10" {
                
                NotificationCenter.default.post(name: Notification.Name("PushRedirectionFCM"), object: ["postId":userInfo["gcm.notification.postId"] as? String ?? "","threadId":userInfo["gcm.notification.threadId"] as? String ?? "","typeOfnotify":userInfo["gcm.notification.typeOfnotify"] as? String ?? "","userId":userInfo["gcm.notification.userId"] as? String ?? ""])
                
            }
        }
        
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
   
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Spark")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}


extension AppDelegate {
    
    func settingsAPICall() {
      
        
        
    }
    
}
