//
//  BubbleCollectionViewCell.swift
//  Spark me
//
//  Created by adhash on 17/08/21.
//

import UIKit
import VariousViewsEffects
import UIView_Shimmer

protocol bubbleListUpdateDelegate : AnyObject {
    
    func bubbleListUpdatedFunction(senderTag:Int)
}

    /**
     This cell is used to set the bubble collection view cell for accepting the user
     */
class BubbleCollectionViewCell: UICollectionViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var imageCornerView: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var bubbleNameLbl: UILabel!
    
    weak var delegate : bubbleListUpdateDelegate?
    
//    var shimmeringAnimatedItems: [UIView] {
//        [
//            imgBgView
//            
//        ]
//    }
    
    
    /// It is used to set the bubbleview model cell with the profile image and name will be loaded in each index
    var viewModelCell:BubbleCellViewModel? {
        
        didSet {
            
            if viewModelCell!.isAnonymousUser {
                userProfileImgView.image = #imageLiteral(resourceName: "ananomous_user")
                bubbleNameLbl.text = "Anonymous User"
            }else{
                userProfileImgView.setImage(
                    url: URL.init(string: viewModelCell?.getBubbleImage ?? "") ?? URL(fileURLWithPath: ""),
                    placeholder: #imageLiteral(resourceName: viewModelCell?.getGender == 1 ?  "no_profile_image_male" : viewModelCell?.getGender == 2 ? "no_profile_image_female" : "others"))
                bubbleNameLbl.text = viewModelCell?.getBubbleName ?? ""
                
                
            }
            
            let start = Date(timeIntervalSince1970: TimeInterval(Int(viewModelCell?.getVisibleDate ?? 0)))
            let end = Date()
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([ .second])
            let datecomponents = calendar.dateComponents(unitFlags, from: start, to: end)
//            let seconds = datecomponents.second
//            print(String(describing: seconds))
//
//            let bubbleDestroyValue = 5//SessionManager.sharedInstance.settingData?.data?.BubbleDestroyTime ?? 0
//
//            if seconds ?? 0 > bubbleDestroyValue {
//                DispatchQueue.main.asyncAfter(deadline: .now()) {
//                    self.imgBgView?.breakGlass(size: GridSize(columns: 15, rows: 21), completion: {
//                        self.reshowImage()
//                    })
//                }
//            }
        }
    }
    
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let myView = View(frame: CGRect(x: 0, y: 0, width: imageCornerView.frame.width, height: imageCornerView.frame.height), cornerRadius: 6, colors: [UIColor.init(hexString: "ee657a"),UIColor.init(hexString: "33beb8"),UIColor.init(hexString: "b2c225"),UIColor.init(hexString: "fecc2f"),UIColor.init(hexString: "db3838"),UIColor.init(hexString: "a363d9")], lineWidth: 2, direction: .horizontal)
        imageCornerView.addSubview(myView)
        
        userProfileImgView.backgroundColor = .clear
        userProfileImgView.layer.cornerRadius = 6
        userProfileImgView.layer.borderWidth = 1
        userProfileImgView.clipsToBounds = true
        userProfileImgView.layer.borderColor = UIColor.clear.cgColor
        
        
    }
    
    
    
    /// Setup the bubble view model with updating the image with observing the function
    func setUpBubbleDeleteViewModel() {
        viewModelCell?.bubbleDeleteModel.observeError = { [weak self] error in
            guard let self = self else { return }
            
            //Show alert here
            //self.showError(error: error.localizedDescription)
        }
        viewModelCell?.bubbleDeleteModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            if value.isOk ?? false {
                
                if value.data?.id == self.viewModelCell?.getBubbleId {
                    self.delegate?.bubbleListUpdatedFunction(senderTag: self.userProfileImgView.tag)
                }
            }
        }
    }
    
    
    /// It is used delete the the bubble view which is  call the delete api
    private func reshowImage() {
        self.imgBgView?.alpha = 0
        self.imgBgView?.isHidden = false
        
        UIView.animate(withDuration: 1, animations: {
            self.imgBgView?.alpha = 1
            self.setUpBubbleDeleteViewModel()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.viewModelCell?.bubbleDeleteApiCall(postDict: ["Id":self.viewModelCell?.getBubbleId ?? 0])
            }
        })
    }
}

/// Set the enum direction here to set the value need to horizontal or vertical
enum Direction {
    case horizontal
    case vertical
}

/// Set the view here as corner radius and colours linewidth
class View: UIView {
    
    init(frame: CGRect, cornerRadius: CGFloat, colors: [UIColor], lineWidth: CGFloat = 5, direction: Direction = .horizontal) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colors.map({ (color) -> CGColor in
            color.cgColor
        })
        
        switch direction {
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
        }
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: lineWidth,
                                                                   dy: lineWidth), cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: lineWidth,
                                                                   dy: lineWidth), cornerRadius: cornerRadius).cgPath
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

