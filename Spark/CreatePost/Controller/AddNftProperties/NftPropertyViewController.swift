//
//  NftPropertyViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 17/03/22.
//

import UIKit
import IQKeyboardManagerSwift

protocol attributeDelegate:AnyObject{
    
    /// Attribute Delegate is used to pass the values between NFT Property controller to attachgment view controller
    /// - Parameter attribute: Pass all the values as dictionary to send in api
    func passAttribute(attribute:[[String:Any]])
}

/**
 This class is used to set all the properties for NFT items which have value and date
 */
class NftPropertyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var isKeyboardRise = false
    var myArray = [[String:Any]]()
    
    var charPro0 = String()
    var charPro1 = String()
    var charPro2 = String()
    
    var valPro0 = String()
    var valPro1 = String()
    var valPro2 = String()
    
    var charBoost0 = String()
    var charBoost1 = String()
    var charBoost2 = String()
    
    var valBoost0 = String()
    var valBoost1 = String()
    var valBoost2 = String()
    
    var charDate0 = String()
    
    var valDate0 = String()
    var attributeDelegate : attributeDelegate?
    
    var isSaved : Bool? = false
    var isDate : Bool? = false
    
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //slideIdicator.roundCorners(.allCorners, radius: 10)
        //self.saveBtn.layer.cornerRadius = self.saveBtn.frame.height/2
        IQKeyboardManager.shared.enable = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(NftDetailTableViewCell.self)
       
        saveBtn.setGradientBackgroundColors([UIColor.splashStartColor,UIColor.splashEndColor], direction: .toRight, for: .normal)
        saveBtn?.layer.cornerRadius = 8
        saveBtn?.clipsToBounds = true
        
        self.tableView.reloadData()
        
        self.isSaved = UserDefaults.standard.bool(forKey: "isSaved")
        
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        if isSaved ?? false {
            self.charPro0 = UserDefaults.standard.string(forKey: "charPro0") ?? ""
            self.charPro1 = UserDefaults.standard.string(forKey: "charPro1") ?? ""
            self.charPro2 = UserDefaults.standard.string(forKey: "charPro2") ?? ""
            
            self.valPro0 = UserDefaults.standard.string(forKey: "valPro0") ?? ""
            self.valPro1 = UserDefaults.standard.string(forKey: "valPro1") ?? ""
            self.valPro2 = UserDefaults.standard.string(forKey: "valPro2") ?? ""
            
            self.charBoost0 = UserDefaults.standard.string(forKey: "charBoost0") ?? ""
            self.charBoost1 = UserDefaults.standard.string(forKey: "charBoost1") ?? ""
            self.charBoost2 = UserDefaults.standard.string(forKey: "charBoost2") ?? ""
            
            self.valBoost0 = UserDefaults.standard.string(forKey: "valBoost0") ?? ""
            self.valBoost1 = UserDefaults.standard.string(forKey: "valBoost1") ?? ""
            self.valBoost2 = UserDefaults.standard.string(forKey: "valBoost2") ?? ""
            
            self.charDate0 = UserDefaults.standard.string(forKey: "charDate0") ?? ""
            self.valDate0 = UserDefaults.standard.string(forKey: "valDate0") ?? ""
            

            
            cell?.characterPro1TF.text = charPro0
            cell?.characterPro2TF.text = charPro1
            cell?.characterPro3TF.text = charPro2
            
            cell?.valuePro1TF.text = valPro0
            cell?.valuePro2TF.text = valPro1
            cell?.valuePro3TF.text = valPro2
            
            cell?.characterBoost1TF.text = charBoost0
            cell?.characterBoost2TF.text = charBoost1
            cell?.characterBoost3TF.text = charBoost2
            
            cell?.valueBoosts1TF.text = valBoost0
            cell?.valueBoosts2TF.text = valBoost1
            cell?.valueBoosts3TF.text = valBoost2
            
            cell?.characterDates1TF.text = charDate0
            cell?.valueDates1TF.text = valDate0
        }
        else{
            cell?.characterPro1TF.text = ""
            cell?.characterPro2TF.text = ""
            cell?.characterPro3TF.text = ""
            
            cell?.valuePro1TF.text = ""
            cell?.valuePro2TF.text = ""
            cell?.valuePro3TF.text = ""
            
            cell?.characterBoost1TF.text = ""
            cell?.characterBoost2TF.text = ""
            cell?.characterBoost3TF.text = ""
            
            cell?.valueBoosts1TF.text = ""
            cell?.valueBoosts2TF.text = ""
            cell?.valueBoosts3TF.text = ""
            
            cell?.characterDates1TF.text = ""
            cell?.valueDates1TF.text = ""
        }
       
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
           // if isKeyboardRise == false{
                self.view.frame.origin.y -= keyboardSize.height
                self.isKeyboardRise = true
            //}
                
                
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        //
        self.isKeyboardRise = false
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
            //if isKeyboardRise == false{
                self.view.frame.origin.y += keyboardSize.height
            //}
                
            }
        }
        //}
    }
    
    @IBAction func closeBtnOnPressed(_ sender: Any) {
       
            self.dismiss(animated: true, completion: nil)
       
        
    }
   
    
    
    ///Called to notify the view controller that its view has just laid out its subviews.
    /// - When the bounds change for a view controller's view, the view adjusts the positions of its subviews and then the system calls this method. However, this method being called does not indicate that the individual layouts of the view's subviews have been adjusted. Each subview is responsible for adjusting its own layout.
    /// - Your view controller can override this method to make changes after the view lays out its subviews. The default implementation of this method does nothing.

    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    
    

    @IBAction func saveBtnOnPressed(_ sender: Any) {
        
        checkValidation()
    }
    
    func checkValidation(){
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        
        if cell?.characterPro1TF.text?.isEmpty ?? Bool() && cell?.valuePro1TF.text?.isEmpty ?? Bool() && cell?.characterPro2TF.text?.isEmpty ?? Bool() && cell?.valuePro2TF.text?.isEmpty ?? Bool() && cell?.characterPro3TF.text?.isEmpty ?? Bool() && cell?.valuePro3TF.text?.isEmpty ?? Bool() && cell?.characterBoost1TF.text?.isEmpty ?? Bool() && cell?.valueBoosts1TF.text?.isEmpty ?? Bool() && cell?.characterBoost2TF.text?.isEmpty ?? Bool() && cell?.valueBoosts2TF.text?.isEmpty ?? Bool() && cell?.characterBoost3TF.text?.isEmpty ?? Bool() && cell?.valueBoosts3TF.text?.isEmpty ?? Bool() && cell?.characterDates1TF.text?.isEmpty ?? Bool() && cell?.valueDates1TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Empty fields are not accepted")
            self.isSaved = false
        }
        
        
       else if !(cell?.characterPro1TF.text?.isEmpty ?? Bool()) && cell?.valuePro1TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the property name 1")
        }
        else if (cell?.characterPro1TF.text?.isEmpty ?? Bool()) && !(cell?.valuePro1TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the property type 1")
        }
     
        else if !(cell?.characterPro2TF.text?.isEmpty ?? Bool()) && cell?.valuePro2TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the property name 2")
        }
        else if (cell?.characterPro2TF.text?.isEmpty ?? Bool()) && !(cell?.valuePro2TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kinldy enter the property type 2")
        }
        
        else if !(cell?.characterPro3TF.text?.isEmpty ?? Bool()) && cell?.valuePro3TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the property name 3")
        }
        else if (cell?.characterPro3TF.text?.isEmpty ?? Bool()) && !(cell?.valuePro3TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the property type 3")
        }
        
        
        else if !(cell?.characterBoost1TF.text?.isEmpty ?? Bool()) && cell?.valueBoosts1TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the boost percentage 1")
        }
        else if (cell?.characterBoost1TF.text?.isEmpty ?? Bool()) && !(cell?.valueBoosts1TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the boost type 1")
        }
        
        else if !(cell?.characterBoost2TF.text?.isEmpty ?? Bool()) && cell?.valueBoosts2TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the boost percentage 2")
        }
        else if (cell?.characterBoost2TF.text?.isEmpty ?? Bool()) && !(cell?.valueBoosts2TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the boost type 2")
        }
        
        else if !(cell?.characterBoost3TF.text?.isEmpty ?? Bool()) && cell?.valueBoosts3TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly enter the boost percentage 3")
        }
        else if (cell?.characterBoost3TF.text?.isEmpty ?? Bool()) && !(cell?.valueBoosts3TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the boost type 3")
        }
        
        else if !(cell?.characterDates1TF.text?.isEmpty ?? Bool()) && cell?.valueDates1TF.text?.isEmpty ?? Bool(){
            self.showErrorAlert(error: "Kindly choose the date")
        }
        else if (cell?.characterDates1TF.text?.isEmpty ?? Bool()) && !(cell?.valueDates1TF.text?.isEmpty ?? Bool()){
            self.showErrorAlert(error:"Kindly enter the date type")
        }
        else{
            //call api
            if !(cell?.characterPro1TF.text?.isEmpty ?? Bool() ) && !(cell?.valuePro1TF.text?.isEmpty ?? Bool()){
                self.charPro0 = cell?.characterPro1TF.text ?? String()
                self.valPro0 = cell?.valuePro1TF.text ?? String()
                UserDefaults.standard.set(self.charPro0, forKey: "charPro0")
                UserDefaults.standard.set(self.valPro0, forKey: "valPro0")
                let data_1 = UserDefaults.standard.string(forKey: "charPro0") ?? ""
                let data_2 = UserDefaults.standard.string(forKey: "valPro0") ?? ""
                print("trait_type:\(data_1),value:\(data_2)")
                let add = ["trait_type":data_1,"value":data_2]
                //self.myArray = []
                self.myArray = [add]//.append(add)
            }else{
                UserDefaults.standard.set("", forKey: "charPro0")
                UserDefaults.standard.set("", forKey: "valPro0")
            }
            
            if !(cell?.characterPro2TF.text?.isEmpty ?? Bool() ) && !(cell?.valuePro2TF.text?.isEmpty ?? Bool()){
                self.charPro1 = cell?.characterPro2TF.text ?? String()
                self.valPro1 = cell?.valuePro2TF.text ?? String()
                UserDefaults.standard.set(self.charPro1, forKey: "charPro1")
                UserDefaults.standard.set(self.valPro1, forKey: "valPro1")
                let add = ["trait_type":charPro1,"value":valPro1]
               // self.myArray = []
                self.myArray.append(add)
                
                print("trait_type:\(charPro1),value:\(self.valPro1)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charPro1")
                UserDefaults.standard.set("", forKey: "valPro1")
            }
            
            if !(cell?.characterPro3TF.text?.isEmpty ?? Bool() ) && !(cell?.valuePro3TF.text?.isEmpty ?? Bool()){
                self.charPro2 = cell?.characterPro3TF.text ?? String()
                self.valPro2 = cell?.valuePro3TF.text ?? String()
                UserDefaults.standard.set(self.charPro2, forKey: "charPro2")
                UserDefaults.standard.set(self.valPro2, forKey: "valPro2")
                let add = ["trait_type":charPro2,"value":valPro2]
                //self.myArray = []
                self.myArray.append(add)
                print("trait_type:\(charPro2),value:\(self.valPro2)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charPro2")
                UserDefaults.standard.set("", forKey: "valPro2")
            }
            if !(cell?.characterBoost1TF.text?.isEmpty ?? Bool() ) && !(cell?.valueBoosts1TF.text?.isEmpty ?? Bool()){
                self.charBoost0 = cell?.characterBoost1TF.text ?? String()
                self.valBoost0 = cell?.valueBoosts1TF.text ?? String()
                UserDefaults.standard.set(self.charBoost0, forKey: "charBoost0")
                UserDefaults.standard.set(self.valBoost0, forKey: "valBoost0")
                let add = ["display_type":"boost_percentage","trait_type":charBoost0,"value":Int(valBoost0) as Any] as [String : Any]
                //self.myArray = []
                self.myArray.append(add)
                print("trait_type:\(charBoost0),value:\(self.valBoost0)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charBoost0")
                UserDefaults.standard.set("", forKey: "valBoost0")
            }
            
            if !(cell?.characterBoost2TF.text?.isEmpty ?? Bool() ) && !(cell?.valueBoosts2TF.text?.isEmpty ?? Bool()){
                self.charBoost1 = cell?.characterBoost2TF.text ?? String()
                self.valBoost1 = cell?.valueBoosts2TF.text ?? String()
                UserDefaults.standard.set(self.charBoost1, forKey: "charBoost1")
                UserDefaults.standard.set(self.valBoost1, forKey: "valBoost1")
                let add = ["display_type":"boost_percentage","trait_type":charBoost1,"value":Int(valBoost1) as Any] as [String : Any]
                //self.myArray = []
                self.myArray.append(add)
                print("trait_type:\(charBoost1),value:\(self.valBoost1)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charBoost1")
                UserDefaults.standard.set("", forKey: "valBoost1")
            }
            
            if !(cell?.characterBoost3TF.text?.isEmpty ?? Bool() ) && !(cell?.valueBoosts3TF.text?.isEmpty ?? Bool()){
                self.charBoost2 = cell?.characterBoost3TF.text ?? String()
                self.valBoost2 = cell?.valueBoosts3TF.text ?? String()
                UserDefaults.standard.set(self.charBoost2, forKey: "charBoost2")
                UserDefaults.standard.set(self.valBoost2, forKey: "valBoost2")
                let add = ["display_type":"boost_percentage","trait_type":charBoost2,"value":Int(valBoost2) as Any] as [String : Any]
                //self.myArray = []
                self.myArray.append(add)
                print("trait_type:\(charBoost2),value:\(self.valBoost2)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charBoost2")
                UserDefaults.standard.set("", forKey: "valBoost2")
            }
            
            if !(cell?.characterDates1TF.text?.isEmpty ?? Bool() ) && !(cell?.valueDates1TF.text?.isEmpty ?? Bool()){
                self.charDate0 = cell?.characterDates1TF.text ?? String()
                self.valDate0 = cell?.valueDates1TF.text ?? String()//String(Int(convertDOBtoTimeStamp(dateStr: cell?.valueDates1TF.text ?? String())))//
            
                UserDefaults.standard.set(self.charDate0, forKey: "charDate0")
                UserDefaults.standard.set(self.valDate0, forKey: "valDate0")
                let add = ["display_type":"date","trait_type":charDate0,"value":convertDOBtoTimeStamp(dateStr: cell?.valueDates1TF.text ?? String())] as [String : Any]
                //self.myArray = []
                self.myArray.append(add)
                print("trait_type:\(charDate0),value:\(self.valDate0)")
            }
            else{
                UserDefaults.standard.set("", forKey: "charDate0")
                UserDefaults.standard.set("", forKey: "valDate0")
            }
            self.isSaved = true
            print(self.myArray)
            if isSaved ?? false{
                attributeDelegate?.passAttribute(attribute: self.myArray)
                self.dismiss(animated: true, completion: nil)
            }
            UserDefaults.standard.set(isSaved, forKey: "isSaved")
            UserDefaults.standard.synchronize()
           // print("call api")
        }
    }
    
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
       if textField == cell?.valueDates1TF{
           cell?.characterDates1TF.resignFirstResponder()
           cell?.valueDates1TF.resignFirstResponder()
           let slideVC = DateViewController()
           slideVC.modalPresentationStyle = .custom
           slideVC.transitioningDelegate = self
           slideVC.delegate = self
           slideVC.isFromNFTtraits = true
           slideVC.selectedSetDate = cell?.valueDates1TF.text ?? ""
           self.present(slideVC, animated: true, completion: nil)
           isDate = false
       }
       return true

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        if textField == cell?.valueDates1TF{
            cell?.characterDates1TF.resignFirstResponder()
            cell?.valueDates1TF.resignFirstResponder()
           
        }
        if textField == cell?.valueDates1TF{
            
            cell?.valueDates1TF.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        if textField == cell?.valueBoosts1TF{
            if cell?.valueBoosts1TF.text?.toInt() ?? Int() < 1 || cell?.valueBoosts1TF.text?.toInt() ?? Int() > 100 {
                //Here you can present an alert, change the input or clear the field.
                self.showErrorAlert(error: "kindly enter the value from 1 to 100 in boost percentage 1")
                cell?.valueBoosts1TF.text = ""
            }
        }
        else if textField == cell?.valueBoosts2TF{
            if cell?.valueBoosts2TF.text?.toInt() ?? Int() < 1 || cell?.valueBoosts2TF.text?.toInt() ?? Int() > 100 {
                //Here you can present an alert, change the input or clear the field.
                self.showErrorAlert(error: "kindly enter the value from 1 to 100 in boost percentage 2")
                cell?.valueBoosts2TF.text = ""
            }
            
        }
        else if textField == cell?.valueBoosts3TF{
            if cell?.valueBoosts3TF.text?.toInt() ?? Int() < 1 || cell?.valueBoosts3TF.text?.toInt() ?? Int() > 100 {
                //Here you can present an alert, change the input or clear the field.
                self.showErrorAlert(error: "kindly enter the value from 1 to 100 in boost percentage 3")
                cell?.valueBoosts3TF.text = ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        if textField == cell?.characterPro1TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterPro2TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterPro3TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valuePro1TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valuePro2TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valuePro3TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterBoost1TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterBoost2TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterBoost3TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valueBoosts1TF{
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valueBoosts2TF{
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.valueBoosts3TF{
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else if textField == cell?.characterDates1TF{
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
        else{
            return true && newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
       
    }
    
}


extension NftPropertyViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    ///  - In your implementation, create and configure an appropriate cell for the given index path. Create your cell using the table view’s dequeueReusableCell(withIdentifier:for:) method, which recycles or creates the cell for you. After creating the cell, update the properties of the cell with appropriate data values.
    /// - Never call this method yourself. If you want to retrieve cells from your table, call the table view’s cellForRow(at:) method instead.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NftDetailTableViewCell", for: indexPath) as! NftDetailTableViewCell
        cell.DateBtn.addTarget(self, action: #selector(addDate(_:)), for: .touchUpInside)
        cell.DateBtn.tag = indexPath.item
        cell.calendarImage.image = UIImage(named: "calendarIcon")
        cell.characterPro1TF.delegate = self
        cell.characterPro2TF.delegate = self
        cell.characterPro3TF.delegate = self
        
        cell.valuePro1TF.delegate = self
        cell.valuePro2TF.delegate = self
        cell.valuePro3TF.delegate = self
        
        cell.characterBoost1TF.delegate = self
        cell.characterBoost2TF.delegate = self
        cell.characterBoost3TF.delegate = self
        
        cell.characterDates1TF.delegate = self
        
        
        cell.valueDates1TF.delegate = self
        cell.valueBoosts1TF.delegate = self
        cell.valueBoosts2TF.delegate = self
        cell.valueBoosts3TF.delegate = self
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 783
    }
    
    @objc func addDate(_ sender:UIButton){
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        if isDate ?? false{
            
            let slideVC = DateViewController()
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            slideVC.delegate = self
            slideVC.isFromNFTtraits = true
            slideVC.selectedSetDate = cell?.valueDates1TF.text ?? ""
            self.present(slideVC, animated: true, completion: nil)
            isDate = false
        }else{
            isDate = true
            cell?.calendarImage.image = UIImage(named: "calendarIcon")
            cell?.valueDates1TF.text = ""
            
            
        }
       
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        if cell?.characterPro1TF.text?.isEmpty ?? false || cell?.valuePro1TF.text?.isEmpty ?? false || cell?.characterPro2TF.text?.isEmpty ?? false || cell?.valuePro2TF.text?.isEmpty
            ?? false || cell?.characterPro3TF.text?.isEmpty ?? false || cell?.valuePro3TF.text?.isEmpty ?? false || cell?.characterBoost1TF.text?.isEmpty ?? false || cell?.valueBoosts1TF.text?.isEmpty ?? false || cell?.characterBoost2TF.text?.isEmpty ?? false || cell?.valueBoosts2TF.text?.isEmpty ?? false || cell?.characterBoost3TF.text?.isEmpty ?? false || cell?.valueBoosts3TF.text?.isEmpty ?? false || cell?.characterDates1TF.text?.isEmpty ?? false || cell?.valueDates1TF.text?.isEmpty ?? false{
            //Disable button
            self.saveBtn.isEnabled = false
        } else {
            //Enable button
            self.saveBtn.isEnabled = true
        }
    }
    
}

extension NftPropertyViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension NftPropertyViewController : DatePickerValueDelegate {
    func DatePickerSelectedDate(dateStr: String) {
        let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? NftDetailTableViewCell
        cell?.valueDates1TF.text = dateStr
        cell?.calendarImage.image = UIImage(systemName: "xmark.circle")
    }
}

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        NSOrderedSet(array: self as! [Any]).array as! [Element]
    }
}


extension String {
        //Converts String to Int
        public func toInt() -> Int? {
            if let num = NumberFormatter().number(from: self) {
                return num.intValue
            } else {
                return nil
            }
        }

        //Converts String to Double
        public func toDouble() -> Double? {
            if let num = NumberFormatter().number(from: self) {
                return num.doubleValue
            } else {
                return nil
            }
        }

        /// EZSE: Converts String to Float
        public func toFloat() -> Float? {
            if let num = NumberFormatter().number(from: self) {
                return num.floatValue
            } else {
                return nil
            }
        }

        //Converts String to Bool
        public func toBool() -> Bool? {
            return (self as NSString).boolValue
        }
    }
