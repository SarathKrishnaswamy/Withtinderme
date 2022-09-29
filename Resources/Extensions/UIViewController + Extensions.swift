//
//  UIViewController + Extensions.swift
//  NTrust
//
//  Created by Waseem Akram on 26/11/20.
//

import UIKit

extension UIViewController {
    
    
    func enableCloseKeyboardOnBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTaped))
        view.addGestureRecognizer(tap)
    }
    
    func disableCloseKeyboardOnBackgroundTap() {
    
        if let tapGesture = view.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer }) {
            view.removeGestureRecognizer(tapGesture)
        }
        
    }
    
    @objc func backgroundTaped(){
        view.endEditing(true)
    }
}
