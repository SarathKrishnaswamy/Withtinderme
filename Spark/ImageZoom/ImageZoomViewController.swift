//
//  ImageZoomViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 27/04/22.
//

import UIKit
import ImageScrollView
import Kingfisher

/**
 This class is used to zoom the image from any of the page.
 */
class ImageZoomViewController: UIViewController {
    
   
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var imageName = UIImage()
    var url = String()
    var delegate : backFromImageDelegate?
    
   
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        
        let Imageurl = URL(string: self.url)
        
        imageScrollView.setup()
        imageScrollView.imageScrollViewDelegate = self
        bgImage.kf.setImage(with: URL(string: url))
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: url))
        downloadImage(with :url){image in
             guard let image  = image else { return}
            self.imageScrollView.display(image: image)
            self.imageScrollView.imageContentMode = .aspectFit
            self.imageScrollView.initialOffset = .begining
            
              // do what you need with the returned image.
         }
    }
    
    
    /// Download the imaage using url and set the image using kingfisher
    /// - Parameters:
    ///   - urlString: Set url link of thr image
    ///   - imageCompletionHandler: After downloaded the image set in completion handler and set in UIImage
    func downloadImage(with urlString : String , imageCompletionHandler: @escaping (UIImage?) -> Void){
            guard let url = URL.init(string: urlString) else {
                return  imageCompletionHandler(nil)
            }
            let resource = ImageResource(downloadURL: url)
            
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result,error,er,data  in
//                switch result {
//                case .success(let value):
            imageCompletionHandler(result)
//                case .failure:
//                    imageCompletionHandler(nil)
//                }
            }
        }


/// Dimiss the current the image view
    @IBAction func backBtnOnPressed(_ sender: Any) {
        self.delegate?.backfromimage()
        self.dismiss(animated: true) {
           
        }
    }
    

}


extension UIImageView {
    
    ///Download the image from url to set the  content mode
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


extension ImageZoomViewController: ImageScrollViewDelegate {
    /// Zoom the image to using scroll orientation
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    /// Zooming the scrollving at scale
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
    }
    
    /// Scroll view did scroll offset will change
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
}
