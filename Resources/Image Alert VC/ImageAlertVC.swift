//
//  ImageAlertVC.swift
//  CustomAlert
//
//  Created by mac-00021 on 22/03/21.
//

import UIKit
import WebKit

/**
 This class is used to set the alert with image using the webview amd label nodata
 */
final class ImageAlertVC: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    //MARK:- @IBOutlet -
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var viewBack: UIView!
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var imgViewImage: UIImageView!
    @IBOutlet private weak var lblNoData: UILabel!
    
    // MARK:- Global Variables -
    
    var name: String? = ""
    var imageName: String? = ""
    var url: URL?
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            self.viewBack.layer.cornerRadius = 20
            self.viewBack.backgroundColor = UIColor.gradientColor2
            self.webView.layer.cornerRadius = 20
            self.webView.clipsToBounds = true
            self.webView.navigationDelegate = self
            self.webView.uiDelegate = self
            self.imgViewImage.layer.cornerRadius = 20
            self.imgViewImage.clipsToBounds = true
            self.webView.allowsBackForwardNavigationGestures = true
        }
        
        lblTitle.isHidden = name == ""
        lblTitle.text = name
        lblTitle.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if imageName != "" {
            
            lblTitle.isHidden = false
            imgViewImage.isHidden = false
            lblNoData.isHidden = true
            webView.isHidden = true
            imgViewImage.image = UIImage(named: self.imageName ?? "")
            
        } else if url != nil {
            
            lblTitle.isHidden = false
            imgViewImage.isHidden = true
            lblNoData.isHidden = true
            webView.isHidden = false
            webView.load(URLRequest(url: url!))
            
        } else {
            
            lblTitle.isHidden = true
            lblNoData.isHidden = false
        }
    }
    
    @IBAction func onClickedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [UIColor.splashStartColor.cgColor, UIColor.splashEndColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}
