//
//  AttachmentViewModel.swift
//  Spark
//
//  Created by Gowthaman P on 16/07/21.
//

import UIKit
import AVFoundation
import AVKit
import RSLoadingView

class AttachmentViewModel: NSObject {

    private let networkManager = NetworkManager()
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    let nftPostModel = LiveData<NftModel, Error>(value: nil)
    
    
    /// Set the nft view model here  and call userby nft id api
    func createNftPostApiCall(){
        
        networkManager.get(port: 1, endpoint: .userBynftId) { [weak self] (result: Result<NftModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            
            case .success(let nftData):
                self.nftPostModel.value = nftData
                debugPrint("success")
                
            case .failure(let error):
                self.nftPostModel.error = error
                debugPrint("failed")
                
            }
        }
    }
    
    
    
    ///Convert Video file path to Data
    func convertVideoPathToData(fileUrl:URL, withblock:@escaping (_ data:Data?)->()) {
        let asset = AVAsset(url: fileUrl)
        let fileURL: URL? = fileUrl
        var assetData: Data? = nil

        // asset is you AVAsset object
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHEVCHighestQuality)

        exportSession?.outputURL = fileURL
        // e.g .mov type
        exportSession?.outputFileType = .mp4

        exportSession?.exportAsynchronously(completionHandler: {
            if let fileURL = fileURL {
                do {
                assetData = try Data(contentsOf: fileURL)
                    withblock(assetData)
                    
                }catch{
                    debugPrint(error.localizedDescription)
                }
            }
            print("AVAsset saved to NSData.")
        })
    }
    
    ///Upload Video file to Blob
    func uploadVideoDataToBlob(data:Data, withblock:@escaping (_ isSuccess:Bool?, _ url:String)->()) {
        //VideoUpload
        DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
        
        if Connection.isConnectedToNetwork(){
            InternetSpeed().testDownloadSpeed(withTimout: 2.0) { megabytesPerSecond, error in
                if megabytesPerSecond > 0.5{
                    AzureManager.shared.uploadVideoToBlobWithData(folderName: "post", data: data) { isSuccess, error, url in
                        if isSuccess {
                            //RSLoadingView.hideFromKeyWindow()
                            withblock(true,url)
                        }else{
                           // RSLoadingView.hideFromKeyWindow()
                        
                            print(error?.localizedDescription)
                            print("My error is")
                            print(error)
                            
                            withblock(false,url)
                           // self.showErrorAlert(error: "Image upload failed.")
                        }
                    }
                }
                else{
                    print("Uploading failed")
                    self.appDelegate?.scheduleNotification(notificationType: "Uploading failed", sound: false)
                }
            }
           
        }
        else{
            
        }
   
    }
    
    ///Upload Thumpnail Image file to Blob
    func uploadThumpNailImageToBlob(image:UIImage, withblock:@escaping (_ isSuccess:Bool?, _ url:String)->()) {
        //Image Upload
        DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
        AzureManager.shared.uploadThumpNailImageToBlob(folderName: "post", image: image) { isSuccess, error, url in
            if isSuccess {
                //RSLoadingView.hideFromKeyWindow()
                withblock(true,url)
            }else{
                print(error)
                //RSLoadingView.hideFromKeyWindow()
                withblock(false,url)
            }
        }
    }
    
    ///Upload Image file to Blob
    func uploadImageToBlob(image:UIImage, withblock:@escaping (_ isSuccess:Bool?, _ url:String)->()) {
        //Image Upload
        DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
        AzureManager.shared.uploadDataFromAws(folderName: "post", image: image) { isSuccess, error, url in
            if isSuccess {
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                withblock(true,url)
            }else{
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                withblock(false,url)
            }
        }
    }
    
    ///Upload Video file to Blob
    func uploadDocumentDataToBlob(data:Data,documentType:String,subFolderName:String, withblock:@escaping (_ isSuccess:Bool?, _ url:String, _ data:Data)->()) {
        //VideoUpload
        DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
        AzureManager.shared.uploadDocumentDataToBlob(folderName: "post", data: data, documentType: documentType, subFolderName: subFolderName) { isSuccess, error, url,data  in
            if isSuccess {
                DispatchQueue.main.async {
                //RSLoadingView.hideFromKeyWindow()
            }
                withblock(true,url, data)
            }else{
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                withblock(false,url, data)
               // self.showErrorAlert(error: "Image upload failed.")
            }
        }
    }
    
    ///Upload Video file to Blob
    func uploadAudioDataToBlob(data:Data,documentType:String,subFolderName:String, withblock:@escaping (_ isSuccess:Bool?, _ url:String)->()) {
        //VideoUpload
        DispatchQueue.main.async {
                //RSLoadingView().showOnKeyWindow()
            }
        AzureManager.shared.uploadAudioDataToBlob(folderName: "post", data: data, documentType: documentType, subFolderName: subFolderName) { isSuccess, error, url in
            if isSuccess {
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                withblock(true,url)
            }else{
                DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
                withblock(false,url)
            }
        }
    }
    
    /// Get the thumbnailImage from video
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.main.async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                let reSizeImage = thumbImage.resizedImageWithinRect(rectSize: CGSize(width: UIScreen.main.bounds.size.width - 32 , height: 290))
                DispatchQueue.main.async { //8
                    completion(reSizeImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
}
