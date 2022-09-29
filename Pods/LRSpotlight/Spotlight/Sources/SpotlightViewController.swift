//
//  SpotlightViewController.swift
//  Spotlight
//
//  Created by Lekshmi Raveendranathapanicker on 2/5/18.
//  Copyright © 2018 Lekshmi Raveendranathapanicker. All rights reserved.
//

import Foundation
import UIKit

final class SpotlightViewController: UIViewController {
    var spotlightNodes: [SpotlightNode] = []
    weak var delegate: SpotlightDelegate?
    var backButton: UIButton!
    var nextButton: UIButton!

    // MARK: - View Controller Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpotlightView()
        setupInfoView()
        setupTapGestureRecognizer()
        createSkip()
       
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if spotlightNodes.count == 1 {
            backButton.isHidden = true
            nextButton.isHidden = true
        }
    }
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextSpotlight()

        timer = Timer.scheduledTimer(timeInterval: Spotlight.delay, target: self, selector: #selector(nextSpotlight), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spotlightView.isHidden = true
        timer.invalidate()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Redraw spotlight for the new dimention
        spotlightView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        showSpotlight()
    }
    
   
    
    
    func createSkip(){
        
//        return UIColor.init(red: 61.0/255.0, green: 64.0/255.0, blue: 110.0/255.0, alpha: 1.0)
//        }
//
//    static var splashEndColor : UIColor {
//        return UIColor.init(red: 54.0/255.0, green: 133.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        let button:UIButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-170, y: UIScreen.main.bounds.height-140, width: 80, height: 30))
        button.applyGradient(colors:  [UIColor.init(red: 61.0/255.0, green: 64.0/255.0, blue: 110.0/255.0, alpha: 1.0).cgColor, UIColor.init(red: 54.0/255.0, green: 133.0/255.0, blue: 132.0/255.0, alpha: 1.0).cgColor]) //= UIColor.init(red: 54.0/255.0, green: 133.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)

      
    }

    @objc func buttonClicked() {
        dismissSpotlight()
    }

    let spotlightView = SpotlightView()
    var infoLabel: UILabel!
    var infoStackView: UIStackView!
    var infoStackTopConstraint: NSLayoutConstraint!
    var infoStackBottomConstraint: NSLayoutConstraint!
    var imgView = UIImageView()
    fileprivate var timer = Timer()
    fileprivate var currentNodeIndex: Int = -1
}

// MARK: - User Actions

extension SpotlightViewController {
    @objc func buttonPressed(_ button: UIButton) {
        timer.invalidate()
        let title = button.titleLabel?.text ?? ""
        switch title {
        case Spotlight.nextButtonTitle:
            break
            //nextSpotlight()
        case Spotlight.backButtonTitle:
            break
            //previousSpotlight()
        default:
            dismissSpotlight()
        }
    }

    @objc func viewTapped(_: UITapGestureRecognizer) {
        timer.invalidate()
        nextSpotlight()
    }

    @objc func nextSpotlight() {
        if currentNodeIndex == spotlightNodes.count - 1 {
            dismissSpotlight()
            return
        }
        currentNodeIndex += 1
        showSpotlight()
    }

    func previousSpotlight() {
        if currentNodeIndex == 0 {
            dismissSpotlight()
            return
        }
        currentNodeIndex -= 1
        showSpotlight()
    }

    func showSpotlight() {
        var node = spotlightNodes[currentNodeIndex]

        nextButton.isHidden = (currentNodeIndex == spotlightNodes.count - 1)
        backButton.isHidden = (currentNodeIndex == 0)

        let targetRect: CGRect
        switch currentNodeIndex {
        case 0:
            targetRect = spotlightView.appear(node)
        case let index where index == spotlightNodes.count:
            targetRect = spotlightView.disappear(node)
        default:
            targetRect = spotlightView.move(node)
        }

        let newNodeIndex = currentNodeIndex + 1
        delegate?.didAdvance(to: newNodeIndex, of: spotlightNodes.count)

        infoLabel.text = node.text
        
        //11
        

        
        imgView.removeFromSuperview()
        imgView.frame = CGRect(x: infoStackView.center.x-20, y: infoStackView.frame.origin.y - 90, width: 80, height: 80)
        imgView.image = UIImage(named: node.imageName)//Assign image to ImageView
        imgView.tintColor = .white
        //imgView.imgViewCorners()
        spotlightView.addSubview(imgView)
       

        // Animate the info box around if intersects with spotlight
        view.layoutIfNeeded()
        UIView.animate(withDuration: Spotlight.animationDuration, animations: { [weak self] in
            guard let this = self else { return }
            if targetRect.intersects(this.infoStackView.frame) {
                if this.infoStackTopConstraint.priority == .defaultLow {
                    this.infoStackTopConstraint.priority = .defaultHigh
                    this.infoStackBottomConstraint.priority = .defaultLow
                } else {
                    this.infoStackTopConstraint.priority = .defaultLow
                    this.infoStackBottomConstraint.priority = .defaultHigh
                }
            }
            this.view.layoutIfNeeded()
        })
        
    }

    func dismissSpotlight() {
        dismiss(animated: true, completion: nil)
        delegate?.didDismiss()
    }
}


extension UIButton
{
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]
        //gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        //gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
