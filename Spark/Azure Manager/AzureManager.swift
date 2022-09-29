//
//  AwsManager.swift
//  Life Hope
//
//  Created by adhash on 25/03/21.
//

import Foundation
import AZSClient
import AVFoundation
import RSLoadingView

final class AzureManager {
    
    // MARK: Properties
    static let shared = AzureManager()
    static let azureUrl = SessionManager.sharedInstance.settingData?.data?.blobURL
    
    static let connectionString = SessionManager.sharedInstance.settingData?.data?.blobConnection
    static let containerName = SessionManager.sharedInstance.settingData?.data?.blobContainerName
   
    ///Called when upload profile image to Azure Storage
    func uploadDataFromAws(folderName:String ,image: UIImage ,  onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String)->()) {
        
        let containerURL = "\(AzureManager.azureUrl ?? "")\(AzureManager.containerName ?? "")"
        var container : AZSCloudBlobContainer
        var error: NSError?
        container = AZSCloudBlobContainer(url: URL(string: containerURL) ?? URL(fileURLWithPath: ""), error: &error)
        do {
            let storageAccount : AZSCloudStorageAccount
            try storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            
            let blob = container.blockBlobReference(fromName: "\(folderName)/\(SessionManager.sharedInstance.getUserId)/\(UUID().uuidString)_\(Int(NSDate().timeIntervalSince1970)).png")
            
           
            let imageData = image.jpegData(compressionQuality: 0.3) ?? Data()
            
            let fileSize = Float(Double(imageData.count)/1024/1024)
            print("File Size = \(fileSize) MB")
            
            if fileSize > 30 {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                showErrorAlert(error: "Maximum uploading image size exceeded.")
                DispatchQueue.main.async {
                //RSLoadingView.hideFromKeyWindow()
            }
                return
            }
            
            blob.upload(from: imageData, completionHandler: {(NSError) -> Void in
                if ((error) != nil) {
                    debugPrint("error")
                    DispatchQueue.main.async {
                //RSLoadingView.hideFromKeyWindow()
            }
                }
                else {
                    print("Image URL : ",blob.storageUri.primaryUri.absoluteString)
                    
                    let fileArray = blob.storageUri.primaryUri.absoluteString.components(separatedBy: "?")
                    let finalFileName = fileArray.first
                    let imageName = finalFileName?.components(separatedBy: "/")
                    onCompletion(true,nil,"\(imageName?[5] ?? "")/\(imageName?[6] ?? "")")

                }
            })
        }catch{
            
        }
    }
    
    ///Called when upload profile image to Azure Storage
    func uploadThumpNailImageToBlob(folderName:String ,image: UIImage ,  onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String)->()) {
        
        let containerURL = "\(AzureManager.azureUrl ?? "")\(AzureManager.containerName ?? "")"
        var container : AZSCloudBlobContainer
        var error: NSError?
        container = AZSCloudBlobContainer(url: (NSURL(string: containerURL ) )! as URL, error: &error)
        
        do {
            let storageAccount : AZSCloudStorageAccount
            try storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            let blob = container.blockBlobReference(fromName: "\(folderName)/\(SessionManager.sharedInstance.getUserId)/\(Int(NSDate().timeIntervalSince1970)).png")
            blob.properties.contentType = "image/png"
            let imageData = image.jpegData(compressionQuality: 0.5) ?? Data()
            
            blob.upload(from: imageData, completionHandler: {(NSError) -> Void in
                if ((error) != nil) {
                    debugPrint("error")
                    DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                }
                else {
                    print("Image URL : ",blob.storageUri.primaryUri.absoluteString)
                    let fileArray = blob.storageUri.primaryUri.absoluteString.components(separatedBy: "?")
                    let finalFileName = fileArray.first
                    let imageName = finalFileName?.components(separatedBy: "/")
                    onCompletion(true,nil,"\(imageName?[5] ?? "")/\(imageName?[6] ?? "")")

                }
            })
        }catch{
            
        }
    }
    
    ///Called when upload profile image to Azure Storage
    func uploadDocumentDataToBlob(folderName:String ,data: Data ,documentType:String,subFolderName:String,  onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String, _ data:Data)->()) {
        
        let containerURL = "\(AzureManager.azureUrl ?? "")\(AzureManager.containerName ?? "")"
        var container : AZSCloudBlobContainer
        var error: NSError?
        container = AZSCloudBlobContainer(url: (NSURL(string: containerURL ) )! as URL, error: &error)
        do {
            let storageAccount : AZSCloudStorageAccount
            try! storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            
            let blob = container.blockBlobReference(fromName: "\(folderName)/\(SessionManager.sharedInstance.getUserId)/\(UUID().uuidString)_\(Int(NSDate().timeIntervalSince1970)).\(documentType)")
            
            let fileSize = Float(Double(data.count)/1024/1024)
            print("File Size = \(fileSize) MB")
            
            if fileSize > 25 {
                
                showErrorAlert(error: "Maximum uploading file size exceeded.")
                DispatchQueue.main.async {
                    let center = UNUserNotificationCenter.current()
                    center.removeAllDeliveredNotifications() // To remove all delivered notifications
                    center.removeAllPendingNotificationRequests()
                }
                
                DispatchQueue.main.async {
                    RSLoadingView.hideFromKeyWindow()
                }
                return
            }
                        
            blob.upload(from: data, completionHandler: {(NSError) -> Void in
                if ((error) != nil) {
                    debugPrint("error")
                    DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                }
                else {
                    print("Image URL : ",blob.storageUri.primaryUri.absoluteString)
                    let fileArray = blob.storageUri.primaryUri.absoluteString.components(separatedBy: "?")
                    let finalFileName = fileArray.first
                    let imageName = finalFileName?.components(separatedBy: "/")
                    onCompletion(true,nil,"\(imageName?[5] ?? "")/\(imageName?[6] ?? "")", data)

                }
            })
        }
    }
    
    ///Called when upload profile image to Azure Storage
    func uploadAudioDataToBlob(folderName:String ,data: Data ,documentType:String,subFolderName:String,  onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String)->()) {
        
        let containerURL = "\(AzureManager.azureUrl ?? "")\(AzureManager.containerName ?? "")"
        var container : AZSCloudBlobContainer
        var error: NSError?
        container = AZSCloudBlobContainer(url: (NSURL(string: containerURL ) )! as URL, error: &error)
        do {
            let storageAccount : AZSCloudStorageAccount
            try! storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            
            let blob = container.blockBlobReference(fromName: "\(folderName)/\(SessionManager.sharedInstance.getUserId)/\(UUID().uuidString)_\(Int(NSDate().timeIntervalSince1970)).\(documentType)")
            
            let fileSize = Float(Double(data.count)/1024/1024)
            print("File Size = \(fileSize) MB")
            
            if fileSize > 300 {
            
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                center.removeAllPendingNotificationRequests()
                showErrorAlert(error: "Maximum uploading file size exceeded.")
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                return
            }
                        
            blob.upload(from: data, completionHandler: {(NSError) -> Void in
                if ((error) != nil) {
                    debugPrint("error")
                }
                else {
                    print("Image URL : ",blob.storageUri.primaryUri.absoluteString)
                    let fileArray = blob.storageUri.primaryUri.absoluteString.components(separatedBy: "?")
                    let finalFileName = fileArray.first
                    let imageName = finalFileName?.components(separatedBy: "/")
                    onCompletion(true,nil,"\(imageName?[5] ?? "")/\(imageName?[6] ?? "")")

                }
            })
        }
    }
    ///Call when image download triggred in AWSS3 Bucket
    func downloadFromS3(folderName:String ,mediaUrl: String , completion: @escaping ( _ error: Error?, _ url: String?)-> Void){
        do {
            var container : AZSCloudBlobContainer
            let storageAccount : AZSCloudStorageAccount;
            try! storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            let blob = container.blockBlobReference(fromName: "\(folderName)/\(mediaUrl)")
            blob.downloadToData { error, Data in
                if ((error) != nil) {
                    debugPrint("error")
                    DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                }
                else {
                    DispatchQueue.main.async {
                        debugPrint(blob.storageUri.primaryUri.absoluteURL)
                        debugPrint(blob.storageUri.primaryUri.absoluteString)
                        completion(nil,blob.storageUri.primaryUri.absoluteString)
                    }
                }
            }
        }
    }
    ///Called when delete uploaded image in AWSS3 bucket
    func deleteDataFromAws(key: String , onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String)->()) {
        do {
            var container : AZSCloudBlobContainer
            let storageAccount : AZSCloudStorageAccount;
            try storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
            let blobClient = storageAccount.getBlobClient()
            container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
            let blob = container.blockBlobReference(fromName: "profilepic/\(key)")
            blob.delete { error in
                debugPrint(error?.localizedDescription as Any)
                debugPrint(blob.storageUri.primaryUri.absoluteString)
                onCompletion(true,nil,blob.storageUri.primaryUri.absoluteString)
            }
        }catch{
            
        }
    }
    
    
    ///Called when upload profile image to Azure Storage
    func uploadVideoToBlobWithData(folderName:String ,data: Data ,  onCompletion: @escaping (_ success: Bool, _ error: Error?,_ url: String)->()) {
        
        DispatchQueue.background(background: {
            // do something in background
            let containerURL = "\(AzureManager.azureUrl ?? "")\(AzureManager.containerName ?? "")"
            var container : AZSCloudBlobContainer
            var error: NSError?
            print("Started Uploading")
            print(error?.code)
            
            DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
            container = AZSCloudBlobContainer(url: (NSURL(string: containerURL ) )! as URL, error: &error)
        
            print("2")
            print(error)
            do {
                DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
                let storageAccount : AZSCloudStorageAccount
                try! storageAccount = AZSCloudStorageAccount(fromConnectionString: AzureManager.connectionString ?? "")
                let blobClient = storageAccount.getBlobClient()
                container = blobClient.containerReference(fromName: AzureManager.containerName ?? "")
                
                let blob = container.blockBlobReference(fromName: "\(folderName)/\(SessionManager.sharedInstance.getUserId)/\(Int(NSDate().timeIntervalSince1970)).mp4")

                let fileSize = Float(Double(data.count)/1024/1024)
                print("File Size = \(fileSize) MB")
                
                if fileSize > 300 {
                    let center = UNUserNotificationCenter.current()
                    center.removeAllDeliveredNotifications() // To remove all delivered notifications
                    center.removeAllPendingNotificationRequests()
                    self.showErrorAlert(error: "Maximum uploading file size exceeded.")
                    DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                    return
                }
                            
                
                blob.upload(from: InputStream.init(data: data)) {(NSError) -> Void in
                    if ((error) != nil) {
                        print("3")
                        debugPrint("error")
                        DispatchQueue.main.async {
                            RSLoadingView.hideFromKeyWindow()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            RSLoadingView.hideFromKeyWindow()
                        }
                        print("Video URL : ",blob.storageUri.primaryUri.absoluteString)
                        onCompletion(true,nil,blob.storageUri.primaryUri.absoluteString)
                    }
                    print("4")
                    print(NSError)
                }
                
            }
        }, completion:{
            // when background job finished, do something in main thread
        })
        
    }
    
    /// Show the error alert by custom alert
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            
            CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                                   message: error,
                                                   alertType: .oneButton(),
                                                   alertRadius: 30,
                                                   btnRadius: 20)
        }
    }
    
}

extension DispatchQueue {

    /// Set the background queue with asynchronous options
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
