//
//  PostedTagViewController.swift
//  Spark
//
//  Created by Gowthaman P on 21/07/21.
//

import UIKit
import EasyTipView

class PostedTagViewController: UIViewController {
    
    @IBOutlet weak var collectionView:UICollectionView?
    
    @IBOutlet weak var dimmedView:UIView!
    @IBOutlet weak var containerView:UIView!
        
    let maxDimmedAlpha: CGFloat = 0.6
    
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint?
    
    var viewModel = ProfileViewModel()
    
    var postedTagArray:[PostedTag]?
    
    // Constants
    let defaultHeight: CGFloat = 0
    let dismissibleHeight: CGFloat = 0
    let maximumContainerHeight: CGFloat = 0//UIScreen.main.bounds.height - 300
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 0
    
    var preferences = EasyTipView.Preferences()
    
    var easyTipView : EasyTipView?
     
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
                
        setupPanGesture()
        
        easyTipViewSetUp()
                
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    func easyTipViewSetUp() {
        
        preferences.drawing.font = UIFont.MontserratMedium(.normal)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.textAlignment = NSTextAlignment.center
        preferences.drawing.backgroundColor = linearGradientColor(
            from: [.splashStartColor, .splashEndColor],
            locations: [0,1],
            size: CGSize(width: 80, height:80)
        )
        
        preferences.drawing.arrowPosition = .bottom
        
        preferences.animating.dismissTransform = CGAffineTransform(translationX: -30, y: -100)
        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 30, y: 100)
        preferences.animating.showInitialAlpha = 0
        preferences.animating.showDuration = 1
        preferences.animating.dismissDuration = 1
        preferences.animating.dismissOnTap = true
    }
    
    ///Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///- Parameters:
    ///    - animated: If true, the view is being added to the window using an animation.
    ///- This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
    ///-  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidAppear(_:) method when the view was first presented. If you override this method, you must call super at some point in your implementation.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        easyTipView?.dismiss()
    }
    
    
    /// Set a gradient color to use in background buttons and views
    /// - Parameters:
    ///   - colors: Multiple colors can be declared inside colors
    ///   - locations: From value of 0 - 1 to set the position of colors
    ///   - size: set the coolor for width and height for any of the view
    /// - Returns: It returns the UIColor to set on the view or buttons
    func linearGradientColor(from colors: [UIColor], locations: [CGFloat], size: CGSize) -> UIColor {
        let image = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height)).image { context in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: locations
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: 0, y:size.width),
                options:[]
            )
        }
        return UIColor(patternImage: image)
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
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
                containerViewHeightConstraint?.constant = 0
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
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
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

extension PostedTagViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
   
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: The number of items in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        postedTagArray?.count ?? 0
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postedTagCell", for: indexPath as IndexPath) as? postedTagCell
        
        cell?.bgView.backgroundColor = self.linearGradientColor(
            from: [UIColor.splashStartColor, UIColor.splashEndColor],
            locations: [0, 1],
            size: CGSize(width: 50, height:50)
        )
        cell?.tagNameBtn?.backgroundColor = UIColor.clear
        cell?.tagNameBtn?.tag = indexPath.row
        cell?.tagNameBtn.setImage(#imageLiteral(resourceName: "spark_logo"), for: .normal)
        cell?.tagNameBtn.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 0)
        cell?.tagNameBtn.setTitle(postedTagArray?[indexPath.row].name, for: .normal)
        cell?.tagNameBtn.setTitleColor(UIColor.white, for: .normal)
        cell?.clapCountBtn.setTitle("\(postedTagArray?[indexPath.row].clapCounts ?? 0)", for: .normal)
        cell?.seenCountBtn.setTitle("\(postedTagArray?[indexPath.row].viewCounts ?? 0)", for: .normal)
        cell?.tagNameBtn?.addTarget(self, action: #selector(tagButtonTapped(sender:)), for: .touchUpInside)
        
        return cell ?? UICollectionViewCell()
    }
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - indexPath: The index path of the item.
    /// - Returns: The width and height of the specified item. Both values must be greater than 0.
    /// - If you do not implement this method, the flow layout uses the values in its itemSize property to set the size of items instead. Your implementation of this method can return a fixed set of sizes or dynamically adjust the sizes based on the cell’s content.
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width / 3 - 20 , height: 68)
    }

    /// Asks the delegate for the margins to apply to content in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view object displaying the flow layout.
    ///   - collectionViewLayout: The layout object requesting the information.
    ///   - section: The index number of the section whose insets are needed.
    /// - Returns: The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        return UIEdgeInsets(top: 5,left: 3,bottom: 5,right: 3)
    }
    
    @IBAction func closeButtonTapped(sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
   
    @objc func tagButtonTapped(sender:UIButton) {
        
        easyTipView?.dismiss()
        
        easyTipView = EasyTipView(text: postedTagArray?[sender.tag].name ?? "", preferences: preferences)
        easyTipView?.show(forView: sender, withinSuperview: self.navigationController?.view!)
        
    }
}

//#MARK: Collectionview Cell Class - Tag Cell
class postedTagCell: UICollectionViewCell {
    
    @IBOutlet weak var tagNameBtn: UIButton!
    @IBOutlet weak var clapCountBtn: UIButton!
    @IBOutlet weak var seenCountBtn: UIButton!
    @IBOutlet weak var bgView: CardView!
    @IBOutlet weak var bgBottomView: UIView!
    
    

}
