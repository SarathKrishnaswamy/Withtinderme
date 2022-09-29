//
//  SplashViewController.swift
//  Spark
//
//  Created by Gowthaman P on 06/07/21.
//




import UIKit
import Lottie
import RAMAnimatedTabBarController
import GoogleMaps
import GooglePlaces
import SwiftyGif
import CoreLocation




/**
 This class is used for getting all internal data access from server and configuration setup purposes
 */


class SplashViewController: UIViewController {
   

    

   
    
   
    
    
    
    
    ///Set the Animation image in UIImageView
    @IBOutlet weak var animationImageView: UIImageView!
    
    ///Animation Image Set the Animation here
    var jeremyGif: UIImage?
    
    
    ///Set the approval code to login to dashboard
    var linkApprovalCode = String()
    
    ///LocationManager Its set detect the location
    var locationManager = CLLocationManager()
    
    ///Share the profile user id to set in api
    var shareProfileUserId = String()
    
    ///ViewModel Get the Api model to set the values
    var viewModel = LoginViewModel()
    
    
    ///Set the UIWindow set the root viewcontroller
    var window:UIWindow?

    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        GMSServices.provideAPIKey("AIzaSyA8wp779xvVe2uQY7MNytQGtvXA6rFyWxM")
        GMSPlacesClient.provideAPIKey("AIzaSyC-kAsJzv3cK5G6i-gZUSJ9mqqaGjV52oM")
        
        //GMSPlacesClient.provideAPIKey("AIzaSyDBP0fjtzuwuUC3Y4uZj2KEiS3CF4S0RcQ")
        
        
        
        loadAnimatedImage()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        if Connection.isConnectedToNetwork(){
           print("Connected")
            setupViewModel()
            viewModel.settingAPICall()
            NotificationCenter.default.addObserver(self, selector: #selector(openApprovalCode), name: Notification.Name("approvalCode"), object: nil)
           // NotificationCenter.default.addObserver(self, selector: #selector(openProfile), name: Notification.Name("listenProfiletLink"), object: nil)
            
            
                
            if SessionManager.sharedInstance.isUserLoggedIn && SessionManager.sharedInstance.isContactApprovedOrNot {
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                self.navigationController?.pushViewController(homeVC, animated: false)
            }
                
                
//            }else if SessionManager.sharedInstance.isUserLoggedIn && !SessionManager.sharedInstance.isContactApprovedOrNot {
//                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
//                let waitingVC = storyBoard.instantiateViewController(identifier: WAITING_VIEW_CONTROLLER) as! WaitingViewController
//                self.navigationController?.pushViewController(waitingVC, animated: true)
//            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
                    loginVC.linkApprovalCode = self.linkApprovalCode
                    self.navigationController?.pushViewController(loginVC, animated: false)
                }
            }
        }
        else{
            let alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)

            

            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
            // ... Do something
                internetRetry()
               
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true) {
            // ... Do something
            }
            
        }
        
        
    }
    
    /**
     Internet retry alert will be show using alertview
     - Parameters:
       - isConnectedToNetwork: boolean value helps to check whether internet is available or not
     - True means network available else network unavailable
     */
    
    func internetRetry(){
        if Connection.isConnectedToNetwork(){
           print("Connected")
            setupViewModel()
            viewModel.settingAPICall()
            NotificationCenter.default.addObserver(self, selector: #selector(openApprovalCode), name: Notification.Name("approvalCode"), object: nil)
           // NotificationCenter.default.addObserver(self, selector: #selector(openProfile), name: Notification.Name("listenProfiletLink"), object: nil)
            if SessionManager.sharedInstance.isUserLoggedIn && SessionManager.sharedInstance.isContactApprovedOrNot {
                
                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                let homeVC = storyBoard.instantiateViewController(identifier: TABBAR_STORYBOARD) as! RAMAnimatedTabBarController
                self.navigationController?.pushViewController(homeVC, animated: false)
            }
                
                
//            }else if SessionManager.sharedInstance.isUserLoggedIn && !SessionManager.sharedInstance.isContactApprovedOrNot {
//                let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
//                let waitingVC = storyBoard.instantiateViewController(identifier: WAITING_VIEW_CONTROLLER) as! WaitingViewController
//                self.navigationController?.pushViewController(waitingVC, animated: true)
//            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
                    loginVC.linkApprovalCode = self.linkApprovalCode
                    self.navigationController?.pushViewController(loginVC, animated: false)
                }
            }
        }
        else{
            let alertController = UIAlertController(title: "No Internet connection", message: "Please check your internet connection or try again later", preferredStyle: .alert)

            

            let OKAction = UIAlertAction(title: "Retry", style: .default) { [self] (action) in
            // ... Do something
                internetRetry()
               
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true) {
            // ... Do something
            }
            
        }
    }
    
    
    
    
    ///Set the approval code from setings Api
    /// - Parameters:
    /// - notification: Approval code is used for new user to invite and approve
    @objc func openApprovalCode(notification:NSNotification){
        let approvalCode = "\((notification.object as? [String:Any])?["approvalCode"] as? String ?? "")"
        self.linkApprovalCode = approvalCode
        print(approvalCode)
    }
    
    
    
    
    
    ///Wave Animation Handling based on UserLogin status
    /// - Status-0:  Wave Animation shown
    ///- Status-1:  Intro Animation shown
    func loadAnimatedImage() {
        do {
            let gif = try UIImage(gifName: "km.gif", levelOfIntegrity:0.5)
            self.animationImageView.setGifImage(gif, loopCount: 1)
        }
        catch{
            print("error")
        }
        
        
    }
    
    
    ///Notifies the view controller that its view is about to be added to a view hierarchy.
    /// - Parameters:
    ///     - animated: If true, the view is being added to the window using an animation.
    ///  - This method is called before the view controller's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    /// Open the profile page
    /// - Parameters:
    ///     - notification: This will give the userId to open the profile page.
    @objc func openProfile(notification:NSNotification){
        let userId = "\((notification.object as? [String:Any])?["userId"] ?? "")"
        self.shareProfileUserId = userId
    }
   
   
    
    /// Call settings api for core configuration setup
    /// - userProfileId is empty and userProfileStatus is false means navigate to login screen
    /// - userProfileId is not empty and userProfileStatus is false means navigate to edit profile screen
    /// - userProfileId is not empty and userProfileStatus is true means navigate to Home screen
     
    func setupViewModel() {
        viewModel.settingModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
        }
        viewModel.settingModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.isOk ?? false {
                self.checkAppUpdate()
                SessionManager.sharedInstance.settingData?.data?.BubbleDestroyTime = self.viewModel.settingModel.value?.data?.BubbleDestroyTime ?? 0
            }
        }
    }
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
//        imageView?.removeFromSuperview()
//        jeremyGif = nil
//        imageView = nil
    }
}

extension SplashViewController : CLLocationManagerDelegate {
    ///Location manager delegate to set the coordintes of latitute and longitude
    /// - Parameters:
    ///     - manager: CLLocationManager to detect the current location
    ///     - locations: Array of CLLocation to set the latitude and longitude 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        SessionManager.sharedInstance.saveUserCurrentLocationDetails = ["lat":locValue.latitude,"long":locValue.longitude]
        locationManager.stopUpdatingLocation()
    }
    
}
