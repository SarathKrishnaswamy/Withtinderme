//
//  ReportViewController.swift
//  Spark me
//
//  Created by Satheesh on 19/09/22.
//

import UIKit
import IQKeyboardManagerSwift

class ReportViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var reportTableView:UITableView?
    @IBOutlet weak var bgBlurView: UIVisualEffectView!
    @IBOutlet weak var contentNameLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var reportTextField: UITextField!
    @IBOutlet weak var reportPostBg: UIView!
    
    var problem : [[String:Any]]?
    var userId = ""
    var displayName = ""
    var postId = ""
    var report_Id = ""
    var report_Name = ""
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reLoadUI()
        IQKeyboardManager.shared.enable = true
    }
    
    func reLoadUI() {
        self.bgBlurView.isHidden = true
        self.reportPostBg.isHidden = true
        self.submitBtn.layer.cornerRadius = 4.0
        self.reportPostBg.layer.cornerRadius = 7.0
        self.reportTableView?.register(UINib(nibName: "ReportTableViewCell", bundle: nil), forCellReuseIdentifier: "ReportTableViewCell")
        let str = SessionManager.sharedInstance.settingData?.data?.nFTInfo?.ReportList ?? ""
        problem = try! JSONSerialization.jsonObject(with: str.data(using:.utf8)!, options: []) as? [[String:Any]]
        reportTableView?.reloadData()
        self.reportTextField.delegate = self
        addDoneButtonOnKeyboard()
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if reportPostBg.frame.origin.y == 0 {
                self.reportPostBg.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if reportPostBg.frame.origin.y != 0 {
            self.reportPostBg.frame.origin.y = 0
        }
    }
    
    func reportPostAPICall(reportId:String, reportName:String) {
        
        let param = ["postId":postId,"userId":userId,"displayName":displayName, "reportId":reportId, "reportName":reportName] as [String : Any]
        FeedDetailsViewModel.instance.reporstPostApiCall(postDict: param)
    }
    
    func setupDeletebserver() {
        
        FeedDetailsViewModel.instance.reportPostModel.observeError = { [weak self] error in
            guard let self = self else { return }
            //Show alert here
            self.showErrorAlert(error: error.localizedDescription)
            if statusHttpCode.statusCode == 400{
                self.bgBlurView.isHidden = true
                self.reportPostBg.isHidden = true
            }
            
        }
        FeedDetailsViewModel.instance.reportPostModel.observeValue = { [weak self] value in
            guard let self = self else { return }
            
            if value.data?.status == 1{
                self.showErrorAlert(error: "\(value.data?.message ?? "")")
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        reportTextField.inputAccessoryView = doneToolbar
        
        
    }
    
    
    @objc func doneButtonAction(){
        reportTextField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 180
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        let new_String = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered) && newString.count <= maxLength && new_String.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    
    func showAlert(alertName:String){
        self.bgBlurView.isHidden = false
        self.reportPostBg.isHidden = false
        self.contentNameLbl.text = alertName
    }
    
    @IBAction func backButtonAction(sender:UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submitBtnOnPressed(_ sender: Any) {
        self.setupDeletebserver()
        self.reportPostAPICall(reportId: self.report_Id, reportName: self.report_Name)
    }
    
    
    @IBAction func closeBtnOnPressed(_ sender: Any) {
        self.bgBlurView.isHidden = true
        self.reportPostBg.isHidden = true
        self.reportTextField.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return problem?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell", for: indexPath) as? ReportTableViewCell
        else { preconditionFailure("Failed to load collection view cell") }
        cell.reportNameLabel.text = problem?[indexPath.row]["problem"] as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAlert(alertName: problem?[indexPath.row]["problem"] as? String ?? "")
        self.report_Id = "\(problem?[indexPath.row]["Id"] as? String ?? "")"
        self.report_Name = "\(problem?[indexPath.row]["problem"] as? String ?? "")"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
