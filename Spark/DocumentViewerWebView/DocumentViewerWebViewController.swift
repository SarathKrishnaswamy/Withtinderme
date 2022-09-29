//
//  DocumentViewerWebViewController.swift
//  Spark
//
//  Created by Gowthaman P on 21/07/21.
//

import UIKit
import WebKit
import RSLoadingView

/**
 This class is used to show all the documents with the viewcontroller and navigationdelegate using the webview
 */
class DocumentViewerWebViewController: UIViewController,WKNavigationDelegate {
    
    /// Initialize the webview here to load
    @IBOutlet var webView: WKWebView!
    
    /// Show the url as empty string
    var url = ""
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
//        DispatchQueue.main.async {
//                RSLoadingView.hideFromKeyWindow()
//            }
        
        webView.navigationDelegate = self
        
     //   DispatchQueue.main.async {
            
            let docType = self.url.components(separatedBy: ".")
            do {
                let imageData = try Data(contentsOf: URL(string: self.url) ?? URL(fileURLWithPath: ""))
                
                if docType.last == "pdf" {
                    self.webView.load(imageData, mimeType: "application/pdf" , characterEncodingName: "UTF-8", baseURL: URL(string: self.url) ?? URL(fileURLWithPath: ""))
                }else{
                    self.webView.load(URLRequest(url: URL(string: self.url) ?? URL(fileURLWithPath: "")))
                }
            } catch {
                print("Unable to load data: \(error)")
            }
            
           
            self.webView.allowsBackForwardNavigationGestures = true
    //    }
        
    }
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        
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
    
    
    
    /// Tells the delegate that an error occurred during the early navigation process.
    /// - Parameters:
    ///   - webView: The web view that called the delegate method.
    ///   - navigation: The navigation object for the operation. This object corresponds to a WKNavigation object that WebKit returned when the load operation began. You use it to track the progress of that operation.
    ///   - error: The error that occurred.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        debugPrint(error.localizedDescription)
        DispatchQueue.main.async {
                RSLoadingView.hideFromKeyWindow()
            }
    }
}

