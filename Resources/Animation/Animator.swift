//
//  Animator.swift
//  We4G
//
//  Created by aviv-inmanage on 15/08/2019.
//  Copyright © 2019 Inmanage. All rights reserved.
//

import UIKit

/**
 This class is used to set the animation of the cells in tableview
 */
class Animator: NSObject {
    typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void
    private var hasAnimatedAllCells = false
    private let animation: Animation
    
    init(animation: @escaping Animation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }
        
        animation(cell, indexPath, tableView)
        if let last = tableView.visibleCells.last {
            self.hasAnimatedAllCells = true
        }
    }
}
