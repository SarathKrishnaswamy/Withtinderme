//
//  ViewController.swift
//  MDatePickerViewDemo
//
//  Created by Matt on 2020/1/13.
//  Copyright © 2020 Matt. All rights reserved.
//

import UIKit
import MDatePickerView


protocol mDatePickerValueDelegate: AnyObject {
    func mDatePickerSelectedDate(dateStr:String)
}

/**
 This class is used to select the date from the date picker using date picker view
 */
class MDatePickerViewController: UIViewController {
    
    lazy var MDate : MDatePickerView = {
        let mdate = MDatePickerView()
        mdate.delegate = self
        mdate.Color = UIColor.splashStartColor
//        mdate.cornerRadius = 14
        mdate.translatesAutoresizingMaskIntoConstraints = false
//        mdate.from = 1920
//        mdate.to = Calendar.current.component(.year, from: Date())
        
        var Y = Calendar.current.component(.year, from: Date())
            var D = Calendar.current.component(.day, from: Date())
            var M = Calendar.current.component(.month, from: Date())
        
        mdate.minDate = DateComponents(calendar: Calendar.current, year: 1920, month: 1,day: 1).date!
        mdate.maxDate = DateComponents(calendar: Calendar.current, year: Y, month: M, day: D).date!
        return mdate
    }()
    
    weak var delegate : mDatePickerValueDelegate?
    
    var selectedDate = ""
    
    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(MDate)
        NSLayoutConstraint.activate([
            MDate.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            MDate.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            MDate.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            MDate.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setGradientBackgroundColors([UIColor.splashStartColor, UIColor.splashEndColor], direction: .toRight, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.layer.masksToBounds = true
        doneButton.frame = CGRect(x: view.frame.width - 110, y: 26, width: 75, height: 35)
        doneButton.addTarget(self, action: #selector(doneButtonpressed), for: .touchUpInside)
        view.addSubview(doneButton)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd - MM - yyyy"
        selectedDate = formatter.string(from: Date())
}
    
    @objc func doneButtonpressed() {
       
        delegate?.mDatePickerSelectedDate(dateStr: selectedDate)
        
        dismiss(animated: true, completion: nil)
    }
}

extension MDatePickerViewController : MDatePickerViewDelegate {
    func mdatePickerView(selectDate: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd - MM - yyyy"
        selectedDate = formatter.string(from: selectDate)
//        Label.text = date
    }
}
