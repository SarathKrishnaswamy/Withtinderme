//
//  DateViewController.swift
//  Spark me
//
//  Created by adhash on 20/09/21.
//

import UIKit

protocol DatePickerValueDelegate: AnyObject {
    func DatePickerSelectedDate(dateStr:String)
}

/** Date view controller is used pick the date from the ui date picker*/
class DateViewController: UIViewController {
    

    var selectedSetDate = ""
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DatePickerValueDelegate?
    
    var selectedDate = ""
    var isFromNFTtraits : Bool? = false
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.layer.masksToBounds = true
        doneButton.frame = CGRect(x: view.frame.width - 130, y: 26, width: 75, height: 35)
        doneButton.addTarget(self, action: #selector(doneButtonpressed), for: .touchUpInside)
        view.addSubview(doneButton)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        selectedDate = formatter.string(from: Date())
        if isFromNFTtraits ?? Bool(){
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
            datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        }
        else{
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
            datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
        }
        
       
        
        datePicker.setDate(from: selectedSetDate, format: "dd/MM/yyyy")

}
    /// Done button pressed to select the date as
    @objc func doneButtonpressed() {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        selectedDate = formatter.string(from: datePicker.date)
        
        delegate?.DatePickerSelectedDate(dateStr: selectedDate)
        
        dismiss(animated: true, completion: nil)
    }
}

extension UIDatePicker {
    
    /// Set the date using the date formatter
    /// - Parameters:
    ///   - string: Send the date as string format
    ///   - format: set the the format as string
    ///   - animated: Its need to be animated or not using bool value
   func setDate(from string: String, format: String, animated: Bool = true) {

      let formater = DateFormatter()

      formater.dateFormat = format

      let date = formater.date(from: string) ?? Date()

      setDate(date, animated: animated)
   }
}
