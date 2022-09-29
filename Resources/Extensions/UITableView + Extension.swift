//
//  UITableView + Extension.swift
//  MRM
//
//  Created by Waseem Akram on 19/10/20.
//  Copyright © 2020 pooja athawale. All rights reserved.
//

import UIKit


extension UITableView {
    
    
    
    func registerNib(_ cell: UITableViewCell.Type){
        register(cell.nib, forCellReuseIdentifier: cell.identifier)
        
    }
    
    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        if let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T {
            return cell
        }
        
        fatalError("[\(#function)] Cant find Cell with Identifier \(T.identifier)")
    }
    
    func dequeueReusableCell<T>() -> T where T: UITableViewCell {
        if let cell = dequeueReusableCell(withIdentifier: T.identifier) as? T {
            return cell
        }
        
        fatalError("[\(#function)] Cant find Cell with Identifier \(T.identifier)")
    }
    
    //TableView bottom to top animation
  
        func reloadWithAnimation() {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.fillMode = CAMediaTimingFillMode.forwards
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            self.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
            self.reloadData()
        }
    
    
}

