//
//  EmailVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/18/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class EmailVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initUI() {
        continueButton.layer.borderColor = UIColor.white.cgColor
        
        emailTextField.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSAttributedString.Key.font : emailTextField.font!, NSAttributedString.Key.foregroundColor: UIColor.lightText])
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSAttributedString.Key.font : passwordTextField.font!, NSAttributedString.Key.foregroundColor: UIColor.lightText])
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        guard let email = emailTextField.text else { return }
        if email.count == 0 || isValidEmail(email) == false {
            showAlertViewController(message: "Please enter valid email!")
            return
        }
        
        guard let password = passwordTextField.text else { return }
        if password.count < 6 {
            showAlertViewController(message: "Password requires at least 6 characters!")
            return
        }
        CTUser.current.email = email
        CTUser.current.password = password
        performSegue(withIdentifier: "WelcomeVC", sender: nil)
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        
    }
}
