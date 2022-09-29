//
//  UICollectionView + Extension.swift
//  MRM
//
//  Created by Waseem Akram on 19/10/20.
//  Copyright © 2020 pooja athawale. All rights reserved.
//

import UIKit.UITableView

/**
 The ui collectionview register nib is to be identified with reusable cell and identify the cell
 */
extension UICollectionView {

    
    func registerNib(_ nibType: UICollectionViewCell.Type){
        register(nibType.nib, forCellWithReuseIdentifier: nibType.identifier)
        
    }
    
    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UICollectionViewCell{
        if let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T {
            return cell
        }
        
        fatalError("[\(#function)] Cant find Cell with Identifier \(T.identifier)")
    }
    
    
    
}
