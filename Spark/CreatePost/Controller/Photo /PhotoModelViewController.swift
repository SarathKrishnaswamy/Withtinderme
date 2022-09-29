//
//  CustomModalViewController.swift
//  HalfScreenPresentation
//
//  Created by Hafiz on 06/06/2021.
//

import UIKit
import PhotoEditorSDK
import AVFoundation
import MobileCoreServices


protocol backFromPhotomodelDelegate {
    func backFromAttachement()
}

/**
 This class is used to select the photos and camera selection and it is used to select the recording audio and attach the audio files
 */

class PhotoModelViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,PhotoEditViewControllerDelegate, VideoEditViewControllerDelegate,backFromPhotomodelDelegate, backtoMultipostDelegate {
    
    /// Dimiss the page and move back
    func back() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        self.backMultiPostdelegate?.back()
    }
    
    /// Dimiss the page and back from attachment to repost upload cancelled
    func backFromAttachement() {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("changeTabBarItemIconFromCreatePost"), object: ["index":0])
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name("RepostUploadCancelled"), object: nil)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func videoEditViewController(_ videoEditViewController: VideoEditViewController, didFinishWithVideoAt url: URL?) {
        debugPrint(url)
    }
    
    func videoEditViewControllerDidFailToGenerateVideo(_ videoEditViewController: VideoEditViewController) {
        
    }
    
    func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
        
    }
    
    
    /// Select the photo and save the image then dismiss and send to attachment page.
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        
        let presentingViewController = self.presentingViewController
        self.dismiss(animated: false, completion: {
            presentingViewController?.dismiss(animated: true, completion: {})
        })
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
        let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
        editImageVC.currencySymbol = currencySymbol
        editImageVC.currenyCode = currenyCode
        editImageVC.monetizeSpark = self.monetizeSpark
        editImageVC.selectedImage = image
        editImageVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
        editImageVC.multiplePost = self.multiplePost
        editImageVC.repostId = self.repostId
        editImageVC.typedQuestionDict = typedQuestionDict
        editImageVC.backtoMultipostDelegate = backMultiPostdelegate
        self.present(editImageVC, animated: true, completion: nil)
    }
    
    
    /// It is used to generate a photo and dismiss the page
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// It is used to generate a photo and dismiss the page
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Constants
    let defaultHeight: CGFloat = 200
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = 200//UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 200
    
    // Dynamic container constraint
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var dimmedView:UIView!
    @IBOutlet weak var containerView:UIView!
    
    @IBOutlet weak var photoView:UIView!
    @IBOutlet weak var galleryView:UIView!
    
    @IBOutlet weak var img1:UIImageView!
    @IBOutlet weak var img2:UIImageView!
    @IBOutlet weak var lbl1:UILabel!
    @IBOutlet weak var lbl2:UILabel!
    
    var isFromPhotoSelection = false
    
    let maxDimmedAlpha: CGFloat = 0.6
    
    var window: UIWindow?
    
    var typedQuestionDict = [String:Any]()
    
    var nftParam = Int()
    
    var alert = UIAlertController()
    
    var monetizeSpark = Int()
    
    var currenyCode = ""
    
    var currencySymbol = ""
    
    var FromLoopMonetize = 0
    
    var multiplePost = 0
    
    var repostId = ""
    
    var backfromPhotmodelDelegate : backFromPhotomodelDelegate?
    
    var backMultiPostdelegate : backtoMultipostDelegate?
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        setupPanGesture()
        
        photoView.dropShadow()
        galleryView.dropShadow()
        
        if !isFromPhotoSelection{ //From audio recording
            img1.image = #imageLiteral(resourceName: "post_record")
            img2.image = #imageLiteral(resourceName: "post_attachment")
            lbl1.text = "Record"
            lbl2.text = "Attach"
        }
        
    }
   
    
    
    
    /// It is used to check the audio mic access and requires the permission and open settings
    func checkAudioMicAccess() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let audioRecordVC = storyBoard.instantiateViewController(identifier: "AudioRecorderViewController") as! AudioRecorderViewController
            audioRecordVC.currenyCode = currenyCode
            audioRecordVC.currencySymbol = currencySymbol
            audioRecordVC.nftParam = nftParam
            audioRecordVC.delegate = self
            audioRecordVC.typedQuestionDict = typedQuestionDict
            audioRecordVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
            audioRecordVC.multiplePost = self.multiplePost
            audioRecordVC.repostId = self.repostId
            audioRecordVC.monetizeSpark = monetizeSpark
            audioRecordVC.backMultiPostdelegate = self
            self.present(audioRecordVC, animated: true, completion: nil)
            print("Permission granted")
        case .denied:
            print("Permission denied")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                //to change font of title and message.
                let titleFont = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
                let messageFont = [NSAttributedString.Key.font: UIFont.MontserratMedium(.normal)]
                
                let titleAttrString = NSMutableAttributedString(string: "Audio record permission", attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: "\nThis app requires access to audio record to get your audio spark. Go to Settings to grant access.\n", attributes: messageFont)
                alert.setValue(titleAttrString, forKey: "attributedTitle")
                alert.setValue(messageAttrString, forKey: "attributedMessage")
                
                if let settings = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settings) {
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                        
                        UIApplication.shared.open(settings)
                    })
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                   // self.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true, completion: nil)
                //                //if #available(iOS 13.0, *) {
                //                if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                //                    while let presentedViewController = topController.presentedViewController {
                //                        topController = presentedViewController
                //                    }
                //                    topController.present(alert, animated: true, completion: nil)
                //                }
            }
            
        case .undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                // Handle granted
            })
        @unknown default:
            print("Unknown case")
        }
    }
    
    
    
    ///Gallery button tapped to select the image from photos or select the audio from recording
    @IBAction func galleryButtonTapped(sender:UIButton) {
        
        if !isFromPhotoSelection{ //From audio recording
            
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.checkAudioMicAccess()
                }
            }
            
            
        }else{
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    /// It is used to select the audio recording or select the camera to  click the snap
    @IBAction func cameraButtonTapped(sender:UIButton) {
        
        
        
        if !isFromPhotoSelection{ //From audio recording
            
            openAudioViewer()
        }else{
            //                    let cameraViewController = CameraViewController()
            //                    cameraViewController.completionBlock = { [unowned cameraViewController] image, _ in
            //                        guard let image = image else {
            //                            return
            //                        }
            //
            //                        let photo = Photo(image: image)
            //                        let photoEditViewController = PhotoEditViewController(photoAsset: photo)
            //                        photoEditViewController.delegate = self
            //
            //                        cameraViewController.present(photoEditViewController, animated: true, completion: nil)
            //                    }
            //                    self.present(cameraViewController, animated: true, completion: nil)
            // Check if project runs on a device with camera available
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                //openCamera()
//            }
//            else {
//
//                print("Camera is not available")
//
//            }
            cameraSelected()
            
        }
        
    }
    
    
    /// Select the camera with the permission if device has no camera
    func cameraSelected() {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        if UIImagePickerController.isSourceTypeAvailable(.camera) != nil {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
                case .authorized:
                    showCameraPicker()
                case .denied:
                    alertPromptToAllowCameraAccessViaSettings()
                case .notDetermined:
                    permissionPrimeCameraAccess()
                default:
                    permissionPrimeCameraAccess()
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                //Analytics.track(event: .permissionsPrimeCameraNoCamera)
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }


    /// Access the camera permission using open seetings when its denied
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: "\"Spark Me\" Would Like To Access the Camera", message: "Please grant permission to use the Camera so that you can upload images.", preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
            //Analytics.track(event: .permissionsPrimeCameraOpenSettings)
            if let appSettingsURL = NSURL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(appSettingsURL as URL)
            }
        })
        present(alert, animated: true, completion: nil)
    }

    

    /// Select the camera permission to upload the images.
    func permissionPrimeCameraAccess() {
        let alert = UIAlertController( title: "\"Spark Me\" Would Like To Access the Camera", message: "Please allow to access your Camera so that you can upload images.", preferredStyle: .alert )
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            //Analytics.track(event: .permissionsPrimeCameraAccepted)
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                    DispatchQueue.main.async {
                        self?.cameraSelected() // try again
                    }
                })
            }
        })
        alert.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
           // Analytics.track(event: .permissionsPrimeCameraCancelled)
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }


    /// Open the camera to snap the image
    func showCameraPicker() {
        let videoController = UIImagePickerController()
        videoController.sourceType = .camera
        videoController.videoQuality = .typeHigh
        videoController.mediaTypes = [kUTTypeMovie as String,kUTTypeImage as String]
        videoController.delegate = self
        present(videoController, animated: true, completion: nil)
    }
    
    
    
    /// Tells the delegate that the user picked a still image or movie.
    /// - Parameters:
    ///   - picker: The controller object managing the image picker interface.
    ///   - info: A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in UIImagePickerController.InfoKey.
    ///   - Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
    ///   - When editing is enabled, the image picker view presents the user with a preview of the currently selected image or movie along with controls for modifying it. (This behavior is managed by the picker view prior to calling this method.) If the - - - user modifies the image or movie, the editing information is available in the info parameter. The original image is also returned in the info parameter.
    ///   - If you set the image picker’s showsCameraControls property to false and provide your own custom controls, you can take multiple pictures before dismissing the image picker interface. However, if you set that property to true, your - delegate must dismiss the image picker interface after the user takes one picture or cancels the operation.
    ///   - Implementation of this method is optional, but expected.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let mediaType:AnyObject? = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as AnyObject?
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    
                    let urlOfVideo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
                    
                    // Do something with the URL
                    dismiss(animated: true, completion: nil)
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
                    typedQuestionDict["mediaType"] = MediaType.Video.rawValue
                    editImageVC.currencySymbol = currencySymbol
                    editImageVC.currenyCode = currenyCode
                    editImageVC.nftParam = self.nftParam
                    editImageVC.monetizeSpark = self.monetizeSpark
                    editImageVC.typedQuestionDict = typedQuestionDict
                    editImageVC.selectedVideoPath = urlOfVideo?.absoluteString ?? ""
                    editImageVC.selectedVideoUrl = urlOfVideo
                    editImageVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
                    editImageVC.multiplePost = self.multiplePost
                    editImageVC.repostId = self.repostId
                    editImageVC.isFromPhotoModel = 1
                    editImageVC.delegate = self
                    editImageVC.backtoMultipostDelegate = self
                    self.present(editImageVC, animated: true, completion: nil)
                    
                }
                else if stringType == kUTTypeImage as String {
                    if let image = (info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage) {
                        
                        
                        let presentingViewController = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            presentingViewController?.dismiss(animated: true, completion: {})
                        })
                        typedQuestionDict["mediaType"] = MediaType.Image.rawValue
                        let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                        let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
                        editImageVC.currencySymbol = currencySymbol
                        editImageVC.currenyCode = currenyCode
                        editImageVC.nftParam = self.nftParam
                        editImageVC.monetizeSpark = self.monetizeSpark
                        editImageVC.selectedImage = image
                        editImageVC.typedQuestionDict = typedQuestionDict
                        editImageVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
                        editImageVC.multiplePost = self.multiplePost
                        editImageVC.repostId = self.repostId
                        editImageVC.isFromPhotoModel = 1
                        editImageVC.delegate = self
                        editImageVC.backtoMultipostDelegate = self
                        self.present(editImageVC, animated: true, completion: nil)
                        
                    }
                }
            }
        }
        
        
    }
    
    
    ///Convert the image picker controller into dictionary
    // Helper function inserted by Swift migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    
    /// Set the input value for the image
    // Helper function inserted by Swift migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    
    
    /// Resize the image for UIImage
    /// - Parameters:
    ///   - image: UIImage need to compress it
    ///   - targetSize: Set the size of width and height
    /// - Returns: It returns as image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    ///After pressing close action it will dismiss the page.
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //animateShowDimmedView()
        //animatePresentContainer()
    }
    
    
    /// Setup the view as background color as clear
    func setupView() {
        view.backgroundColor = .clear
    }
    
    /// Setup the pan gesture to initialise
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    
    /// Handle the pan gesture to dismiss the page
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    /// Show the container height with the animation
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    /// Show the bottom constraint contant to 0
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    
    /// The bg view will be dimmed with animation alpha will be shown.
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    
    /// The animate dimmedview alpha will be less and dismissed
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}

//#MARK: Open Audio Recorder Class
extension PhotoModelViewController : UIDocumentPickerDelegate {
    
    
    /// Open the file manager to select the mp3 files wav files and mp4 files of audio
    func openAudioViewer() {
        
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeMP3),String(kUTTypeMPEG4Audio),String(kUTTypeWaveformAudio)], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    /// Pick the audio viewer as as file path and set the filepath to attachment page.
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if(urls.count > 0) {
                
                let fileArray = "\(urls.first ?? URL(fileURLWithPath: ""))".components(separatedBy: "/")
                let finalFileName = fileArray.last
                let finalName = finalFileName?.components(separatedBy: ".")
                debugPrint(finalFileName ?? "")
                debugPrint(finalName ?? "")
                
                let fileURL = urls.first ?? URL(fileURLWithPath: "")
                do {
                    let data = try Data(contentsOf: fileURL)
                    let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
                    let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
                    editImageVC.currencySymbol = currencySymbol
                    editImageVC.currenyCode = currenyCode
                    editImageVC.nftParam = nftParam
                    editImageVC.monetizeSpark = self.monetizeSpark
                    typedQuestionDict["mediaType"] = MediaType.Audio.rawValue
                    editImageVC.typedQuestionDict = typedQuestionDict
                    editImageVC.selectedDocData = data
                    editImageVC.selectedDocTypeArray = finalName ?? []
                    editImageVC.asseturl = urls.first ?? URL(fileURLWithPath: "")
                    editImageVC.isFromPhotoModel = 1
                    editImageVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
                    editImageVC.multiplePost = self.multiplePost
                    editImageVC.repostId = self.repostId
                    editImageVC.delegate = self
                    editImageVC.backtoMultipostDelegate = self
                    self.present(editImageVC, animated: true, completion: nil)
                }catch {
                    debugPrint(error.localizedDescription)
                }
                
            }
        }
    }
    
}
