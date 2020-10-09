//
//  Extension.swift
//  Zoot
//
//  Created by Adam Franklin on 9/12/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import Foundation
import UIKit
import UIColor_Hex_Swift

extension UITextField {
    func setInputViewDatePicker(target: Any, selector: Selector){
        let screenWidth = UIScreen.main.bounds.width
        let datepicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 210))
        datepicker.datePickerMode = .date
        //datepicker.setValue(UIColor.white, forKey: "textColor")
        //datepicker.backgroundColor = UIColor.init(red: 30/255, green: 40/255, blue: 38/255, alpha: 1.0)
        datepicker.backgroundColor = .white
        self.inputView = datepicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44.0))
        //toolbar.barTintColor = UIColor.init(red: 30/255, green: 40/255, blue: 38/255, alpha: 1.0)
        toolbar.tintColor = UIColor("#2FAC70")
        let flexible_space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        cancel.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 16)!], for: .normal)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 16)!], for: .normal)
        toolbar.setItems([cancel,flexible_space,doneButton], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    @objc func tapCancel(){
        
    }
}
