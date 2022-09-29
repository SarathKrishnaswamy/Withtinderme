//
//  UserGroupTableViewCell.swift
//  Spark me
//
//  Created by adhash on 17/09/21.
//

import UIKit
import Kingfisher
import UIView_Shimmer

class UserGroupTableViewCell: UITableViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var Dummy_1: UIView!
    @IBOutlet weak var Dummy_2: UIView!
    @IBOutlet weak var Dummy_3: UIView!
    @IBOutlet weak var Dummy_4: UIView!
    
    var viewModelCell:UserGroupTableViewCellModel? {
        
        didSet {
            displayName.text = viewModelCell?.displayName
            createdDate.text = viewModelCell?.getVisibleDate
            userImgView.setImage(
                url: URL.init(string: viewModelCell?.getConversationImage ?? "") ?? URL(fileURLWithPath: ""),
                placeholder: #imageLiteral(resourceName: viewModelCell?.gender == 1 ?  "no_profile_image_male" : viewModelCell?.gender == 2 ? "no_profile_image_female" : "others"))
//
            
        }
    }
    
    var shimmeringAnimatedItems: [UIView] {
           [
            Dummy_1,
            Dummy_2,
            Dummy_3,
            Dummy_4
           ]
       }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImgView.layer.borderWidth = 1.0
        userImgView.layer.masksToBounds = false
        userImgView.layer.borderColor = UIColor.clear.cgColor
        userImgView.layer.cornerRadius = 6.0
        userImgView.clipsToBounds = true
    }
    
    func hideDummy(){
        self.Dummy_1.isHidden = true
        self.Dummy_2.isHidden = true
        self.Dummy_3.isHidden = true
        self.Dummy_4.isHidden = true
    }
    
    func showDummy()
    {
        self.Dummy_1.isHidden = false
        self.Dummy_2.isHidden = false
        self.Dummy_3.isHidden = false
        self.Dummy_4.isHidden = false
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
