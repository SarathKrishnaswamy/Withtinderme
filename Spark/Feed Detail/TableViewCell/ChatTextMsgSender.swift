//
//  ChatTextMsgSender.swift
//  Spark me
//
//  Created by Gowthaman P on 17/08/21.
//

import UIKit

/**
 This cell is used to send message the from own user
 */
class ChatTextMsgSender: UITableViewCell {
    
    @IBOutlet weak var bgView:UIView?
    @IBOutlet weak var profileImgView:UIImageView?
    @IBOutlet weak var messageLbl:UITextView?
    @IBOutlet weak var dateLabel:UILabel?
    @IBOutlet weak var nameLbl:UILabel?
    
    @IBOutlet weak var txtViewHeightConstraints: NSLayoutConstraint?
    
    
    ///Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    /// - The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
    ///  - You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView?.layer.cornerRadius = 6.0
        bgView?.clipsToBounds = true
        
        profileImgView?.layer.cornerRadius = 6.0
        profileImgView?.clipsToBounds = true
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor.blue]
//
//
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

  
}
