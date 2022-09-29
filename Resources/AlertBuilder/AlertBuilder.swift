//
//  AlertBuilder.swift
//  NTrust
//
//  Created by Waseem Akram on 25/11/20.
//

import UIKit


/// Set the common alert builder to show in all methods of actions to build and present the alert
class AlertBuilder {
    
    var title: String?
    var message: String?
    var alertStyle: UIAlertController.Style = .alert
    
    
    init(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert) {
        self.title = title
        self.message = message
        self.alertStyle = style
    }
    
    private var actions = [UIAlertAction]()
    
    @discardableResult
    func addButton(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction)->Void)? = nil) -> AlertBuilder {
        actions.append(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func build() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        actions.forEach { (action) in
            alert.addAction(action)
        }
        return alert
    }
    
    func present(context: UIViewController, animated: Bool = true, completion: (()->Void)?=nil){
        context.present(build(), animated: animated, completion: completion)
    }
    
}
