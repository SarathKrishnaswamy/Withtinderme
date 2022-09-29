//
//  ATableView.swift
//  We4G
//
//  Created by aviv-inmanage on 17/08/2019.
//  Copyright © 2019 Inmanage. All rights reserved.
//

import UIKit

extension UITableView {

    
    /// a func which should be called at willDisplay cell UITableView function
    /// this func will create animation for all the cells in the tableview in initialization
    /// and every time you reload a cell
    ///
    /// - Parameters:
    ///   - animationFactory: Animation object which is needed for the animate function
    ///   - tableView: UITableView
    ///   - cell: UITableViewCell which is being animated
    ///   - indexPath: IndexPath of the animated cell
    func animateCells(_ animationFactory: @escaping Animator.Animation, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath ) {
        let animation = animationFactory
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }

    //EXAMPLE: paste the commented code below into a conntroller which conforms UITableViewDelegate
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableView.animateCells(AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05), tableView: tableView, cell: cell, indexPath: indexPath)
//    }
    
}
