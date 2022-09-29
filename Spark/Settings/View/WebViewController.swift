//
//  WebViewController.swift
//  Life Hope
//
//  Created by Gowthaman P on 12/11/20.
//

import UIKit
import WebKit
import RSLoadingView

class WebViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {

    /**
      This class is used to show all webpages with url link 
     */
    @IBOutlet var webView: WKWebView!
    @IBOutlet var titleLbl:UILabel?

    var urlStr = ""
    var titleStr = ""
    
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        self.view = webView
        
        webView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
        
        self.title = titleStr
        
//        if !self.urlStr.isEmpty {
            DispatchQueue.main.async {
                RSLoadingView().showOnKeyWindow()
            }

            DispatchQueue.main.async {
                let url = URL(string: self.urlStr)
                self.webView.navigationDelegate = self
                self.webView.uiDelegate = self
                self.webView.load(URLRequest(url: url ?? URL(fileURLWithPath: "")))
                self.webView.allowsBackForwardNavigationGestures = true
            }
 //       }
        
    }
    
    /// Here we are disable the option to zoom the page.
    /// - Returns: It have return the Webkit user script
    private func getZoomDisableScript() -> WKUserScript {
            let source: String = "var meta = document.createElement('meta');" +
                "meta.name = 'viewport';" +
                "meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';" +
                "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
            return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        }
    
    
    ///Back button tapped to dismiss the current page
    @IBAction func backButtonTapped(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Tells the delegate that navigation is complete.
    /// - Parameters:
    ///   - webView: The web view that loaded the content.
    ///   - navigation: The navigation object that finished.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
    }
    
    /// Tells the delegate that an error occurred during navigation.
    /// - Parameters:
    ///   - webView: The web view that reported the error.
    ///   - navigation: The navigation object for the operation. This object corresponds to a WKNavigation object that WebKit returned when the load operation began. You use it to track the progress of that operation.
    ///   - error: The error that occurred.
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
    }
}
