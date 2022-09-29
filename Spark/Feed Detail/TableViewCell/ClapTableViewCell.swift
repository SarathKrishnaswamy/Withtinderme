//
//  ClapTableViewCell.swift
//  Spark me
//
//  Created by Gowthaman P on 17/08/21.
//

import UIKit
import UIView_Shimmer

protocol clapDelegate:AnyObject {
    func clapFunction(sender:UIButton)
    func createSparkFunction(sender:UIButton)
   
    func BuyNowOrContinueFunction(sender:UIButton)
   // func threadRequestFunction(sender:UIButton)
}

class ClapTableViewCell: UITableViewCell,ShimmeringViewProtocol {
    
    @IBOutlet weak var clapBtn:UIButton?
    @IBOutlet weak var createSparkBtn:UIButton?
    @IBOutlet weak var cthreadRequestBtn:UIButton?
    @IBOutlet weak var descpLbl:UILabel?
    @IBOutlet weak var clapImgView: UIImageView!
    @IBOutlet weak var buyNowbtn: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var dummyView1: UIView!
    @IBOutlet weak var dummyView2: UIView!
    
    weak var clapDelegate:clapDelegate?

    
    var shimmeringAnimatedItems: [UIView] {
        [
            dummyView1,
            dummyView2
        ]
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clapBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        buyNowbtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        cthreadRequestBtn?.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)

        clapBtn?.layer.cornerRadius = 15
        clapBtn?.clipsToBounds = true
        
        cthreadRequestBtn?.layer.cornerRadius = 15
        cthreadRequestBtn?.clipsToBounds = true
        
        createSparkBtn?.layer.cornerRadius = 15
        createSparkBtn?.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: createSparkBtn?.frame.size ?? CGSize.init())
        gradient.colors =  [UIColor.splashStartColor.cgColor, UIColor.splashEndColor.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = 3

        shape.path = UIBezierPath(roundedRect: createSparkBtn?.bounds ?? CGRect.init(), cornerRadius: createSparkBtn?.layer.cornerRadius ?? 0).cgPath

        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        createSparkBtn?.layer.addSublayer(gradient)
        
        
        buyNowbtn?.layer.cornerRadius = 4
        buyNowbtn?.clipsToBounds = true
        
    }

    
    /// Sets the selected state of the cell, optionally animating the transition between states.
    /// - Parameters:
    ///   - selected: true to set the cell as selected, false to set it as unselected. The default is false.
    ///   - animated: true to animate the transition between selected states, false to make the transition immediate.
    ///    - The selection affects the appearance of labels, image, and background. When the selected state of a cell is true, it draws the background for selected cells (Reusing cells) with its title in white.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func showDummy(){
        
        dummyView1.isHidden = false
        dummyView2.isHidden = false
        clapBtn?.isHidden = true
        createSparkBtn?.isHidden = true
        cthreadRequestBtn?.isHidden = true
        descpLbl?.isHidden = true
        clapImgView?.isHidden = true
        self.priceLbl.isHidden = true
        self.buyNowbtn.isHidden = true
        
    }
    
    func hideDummy(){
        dummyView1.isHidden = true
        dummyView2.isHidden = true
        clapBtn?.isHidden = false
        createSparkBtn?.isHidden = false
        cthreadRequestBtn?.isHidden = false
        descpLbl?.isHidden = false
        clapImgView?.isHidden = false
        self.priceLbl.isHidden = true
        self.buyNowbtn.isHidden = true
    }
    
    /// Calp button tapped to clap the function inside loop
    @IBAction func clapButtonTapped(sender:UIButton) {
        clapDelegate?.clapFunction(sender: sender)
    }
    
    
    /// create spark button tapped to open the connect button to connect
    @IBAction func createSparkButtonTapped(sender:UIButton) {
        clapDelegate?.createSparkFunction(sender: sender)
    }
    
    /// Buy now button is used buy the monetize post
    @IBAction func buyNowBtnOnPressed(sender: UIButton) {
        clapDelegate?.BuyNowOrContinueFunction(sender: sender)
    }
    
    
//    @IBAction func threadRequestuttonTapped(sender:UIButton) {
//        clapDelegate?.threadRequestFunction(sender: sender)
//    }
    
}
