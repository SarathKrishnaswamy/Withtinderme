//
//  UIImageView + Extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 27/11/20.
//

import UIKit
import SDWebImage

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()

class customImageView : UIImageView {
    
    var imageUrlString : String?
    
    func loadImageUsingCacheWithUrlString(urlString: String,isFromProfile:Bool) {
        
        imageUrlString = urlString
        
        image = isFromProfile == true ? #imageLiteral(resourceName: "no_profile_image_male") : #imageLiteral(resourceName: "NoImage")
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url ?? URL(fileURLWithPath: ""), completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    if self.imageUrlString == urlString {
                        self.image = downloadedImage
                    }
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    return
                }
            })
            
        }).resume()
    }
}

extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 15.0
        self.clipsToBounds = true
    }
}

extension UIImageView {
    public func setImageFromUrl(urlString: String, imageView:UIImageView, placeHolderImage:String) {
        let cacheImage = SDImageCache.shared.imageFromCache(forKey: urlString)
        if cacheImage == nil
        {
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
            let url = URL(string: urlString)
            imageView.sd_setImage(with: url, placeholderImage:UIImage(named: placeHolderImage), options: []) { (image, error, cacheType, url) in
                if error == nil{
                    DispatchQueue.main.async(execute: {
                        imageView.image = image
                    })
                }
                else {
                    imageView.image = UIImage(named: placeHolderImage)
                    debugPrint(error ?? "")
                }
            }
        }
        else {
            DispatchQueue.main.async(execute: {
                imageView.image = cacheImage
            })
        }
    }
}
extension UIImageView {

    class func getSDImages(imageBaseUrl: String, imageView : UIImageView, reSize : CGSize) -> Void
    {
        var imageUrl = URL.init(string: "")

        imageView.image = #imageLiteral(resourceName: "NoImage")

        let imageV : UIImage! = SDImageCache.shared.imageFromCache(forKey: imageBaseUrl)

        let url = URL(string: imageBaseUrl)

        imageUrl = url

        if imageV == nil // Check whether Image is already in cache or not
        {
            //Again download tha image and set

            imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "NoImage"), options: []) { (image, error, cacheType, url) in
                if error == nil && imageUrl == url {

                    if reSize != CGSize.zero
                    {
                        DispatchQueue.main.async {
                            let reSizeImage = image?.resizedImageWithinRect(rectSize: reSize)

                            imageView.image = reSizeImage
                        }

                    }
                    else {

                        imageView.image = image

                    }
                }
                else {

                    imageView.image = #imageLiteral(resourceName: "NoImage")
                }
            }
        }
        else {

            if reSize != CGSize.zero
            {
                let reSizeImage = imageV.resizedImageWithinRect(rectSize: reSize)

                imageView.image = reSizeImage
            }
            else {
                imageView.image = imageV
            }
        }

    }
}
