//
//  AnimationFactory.swift
//  We4G
//
//  Created by aviv-inmanage on 15/08/2019.
//  Copyright © 2019 Inmanage. All rights reserved.
//

import Foundation
import UIKit

enum AnimationFactory {
    typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void
    
    /// function for moviing cell up with fade interval
    ///     let animation = AnimationFactory.makeFadeAnimation(duration: 0.5, delayFactor: 0.05)
    ///
    /// - Parameters:
    ///   - rowHeight: CGFloat responsible for the mobing height
    ///   - duration: TimeInterval responsible for the duration
    ///   - delayFactor: Double determing the time to start
    /// - Returns: return Animation which is typealias which animation need to to create the animation
    static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    /// function for moviing cell up with fade interval
    ///  let animation = AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.05)
    ///
    /// - Parameters:
    ///   - rowHeight: CGFloat responsible for the mobing height
    ///   - duration: TimeInterval responsible for the duration
    ///   - delayFactor: Double determing the time to start
    /// - Returns: return Animation which is typealias which animation need to to create the animation
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    /// function for moviing cell up with fade interval
    ///  expample: let animation = AnimationFactory.makeSlideIn(duration: 0.5, delayFactor: 0.05)
    ///
    /// - Parameters:
    ///   - rowHeight: CGFloat responsible for the mobing height
    ///   - duration: TimeInterval responsible for the duration
    ///   - delayFactor: Double determing the time to start
    /// - Returns: return Animation which is typealias which animation need to to create the animation
    static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
            })
        }
    }
    
    /// function for moviing cell up with fade interval
    ///  expample: let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
    ///
    /// - Parameters:
    ///   - rowHeight: CGFloat responsible for the mobing height
    ///   - duration: TimeInterval responsible for the duration
    ///   - delayFactor: Double determing the time to start
    /// - Returns: return Animation which is typealias which animation need to to create the animation
    static func makeSlideIn(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
}
