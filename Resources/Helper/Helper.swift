//
//  HelperViewController.swift
//  Life Hope
//
//  Created by Gowthaman P on 30/10/20.
//

import UIKit

/**
 Helper class is used to remove the user defaults and converting the timestamp to String
 */
class Helper: NSObject {
    
    static let sharedInstance = Helper()
    
    /// reset the user defaults
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    

    func convertTimeStampToDOBWithTimeReturnDate(timeStamp:String) -> Date {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        let date = dateFormater.string(from: dateFromServer as Date)
        return dateFormater.date(from: date) ?? Date()
    }
    
    
    func convertTimeStampToDate(timeStamp:String) -> Date {
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.date(from: timeStamp) ?? Date()
    }
    
    func convertTimeStampToDOBWithTime(timeStamp:String) -> String {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.string(from: dateFromServer as Date)
    }
    
    func convertTimeStampToHours(timeStamp:String) -> String {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "hh:mm a"
        return dateFormater.string(from: dateFromServer as Date)
    }
    
    
    func loadTextIntoCell(text:String,textColor:String,bgColor:String,label:UITextView,bgView:UIView) {
        
        label.text = text
        label.isEditable = false
        label.isSelectable = true
        label.textColor = UIColor.init(hexString: textColor)
        bgView.backgroundColor = UIColor.init(hexString: bgColor)
    }
    
    func loadTextIntoCells(text:String,textColor:String,bgColor:String,label:UITextView,bgView:UIView) {
        
        label.text = text
        label.textColor = UIColor.init(hexString: textColor)
        bgView.backgroundColor = UIColor.init(hexString: bgColor)
    }
    
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func convertTimeStampToDOB(timeStamp:String) -> String {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        return dateFormater.string(from: dateFromServer as Date)
    }
    
    func convertTimeStampToDOBMonth(timeStamp:String) -> String {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "EEEE, MMM dd, yyyy"
        return dateFormater.string(from: dateFromServer as Date)
    }
    
    func convertTimeStampToDOBWithTime(timeStamp:String) -> String {
        let timeinterval : TimeInterval = (timeStamp as NSString).doubleValue
        let dateFromServer = NSDate(timeIntervalSince1970:timeinterval)
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.string(from: dateFromServer as Date)
    }

    func convertDOBtoTimeStamp(dateStr:String) -> Int{
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "dd/MM/yyyy"
        let date = dfmatter.date(from: dateStr)
        let dateStamp:TimeInterval = date?.timeIntervalSince1970 ?? 0
        let timeStamp:Int = Int(dateStamp)
        return timeStamp
    }
    
    func convertTimeStampToDate(timeStamp:String) -> Date {
        let dateFormater : DateFormatter = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return dateFormater.date(from: timeStamp) ?? Date()
    }
    
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            
            CustomAlertView.shared.showCustomAlert(title: "Spark me",
                                                   message: error,
                                                   alertType: .oneButton(),
                                                   alertRadius: 30,
                                                   btnRadius: 20)
        }
    }
    
    fileprivate func updateAlert() {
        // create the alert
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let titleFont = [NSAttributedString.Key.font: UIFont.MontserratBold(.large)]
        let titleAttrString = NSMutableAttributedString(string: SessionManager.sharedInstance.settingData?.data?.versionInfo?.updateTitle ?? "", attributes: titleFont as [NSAttributedString.Key : Any])
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        
        let messageFont = [NSAttributedString.Key.font: UIFont.MontserratRegular(.normal)]
        let messageAttrString = NSMutableAttributedString(string: "\n\(SessionManager.sharedInstance.settingData?.data?.versionInfo?.updateMsg ?? "")", attributes: messageFont as [NSAttributedString.Key : Any])
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        if SessionManager.sharedInstance.settingData?.data?.versionInfo?.forceUpdate ?? false == false { //Optional Update
            alert.addAction(UIAlertAction(title: "Skip Now", style: .cancel, handler: { (_) in
                
            }))
        }
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (_) in
            if let url = URL(string: SessionManager.sharedInstance.settingData?.data?.versionInfo?.playStoreUrl ?? "") {
                UIApplication.shared.open(url)
            }
        }))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkAppUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let latestVersionStr = SessionManager.sharedInstance.settingData?.data?.versionInfo?.latestVersion
            if latestVersionStr != "\(Bundle.main.releaseVersionNumberPretty)" && SessionManager.sharedInstance.settingData?.data?.versionInfo?.isUpdate == 1 {
                self.updateAlert()
            }
        }
    }
}

///Called to fetch Application Build Version
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
