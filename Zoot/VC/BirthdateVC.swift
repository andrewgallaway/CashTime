//
//  BirthdateVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/8/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class BirthdateVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    
    fileprivate var birthday: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initUI() {
        progressView.progress = 0.4
        birthdayTextField.attributedPlaceholder = NSAttributedString(string:"MM/DD/YYYY", attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        birthdayTextField.setInputViewDatePicker(target: self, selector: #selector(tapDone))
    }
    
    @objc func tapDone() {
        if let datepicker = self.birthdayTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            birthday = datepicker.date
            self.birthdayTextField.text = dateformatter.string(from: datepicker.date)
        }
        self.birthdayTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NameVC" {
            
        }
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        guard let birthday = self.birthday else {
            showAlertViewController(message: "Birthday cannot be empty!")
            return
        }
        
        CTUser.current.birthday = birthday
        performSegue(withIdentifier: "UsernameVC", sender: nil)
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}
