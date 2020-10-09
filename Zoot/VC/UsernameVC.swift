//
//  UsernameVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/8/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class UsernameVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameCheckMarkerImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initUI() {
        progressView.progress = 0.6
        usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username", attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white])
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        usernameCheckMarkerImageView.isHidden = true
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        guard let username = usernameTextField.text else { return }
        if username.count == 0 {
            showAlertViewController(message: "Username cannot be empty!")
            return
        }
        
        CTUser.current.username = username
        performSegue(withIdentifier: "MediaVC", sender: nil)
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        let username = textField.text!
        if username.isEmpty {
            self.usernameCheckMarkerImageView.isHidden = true
        } else {
            APIManager.shared.cancelAllRequests()
            APIManager.shared.isExistUsername(username) { (response, error) in
                if let response = response, let exist = response["exist"] as? Bool, exist == false {
                    self.usernameCheckMarkerImageView.isHidden = false
                } else {
                    self.usernameCheckMarkerImageView.isHidden = true
                }
            }
        }
        
    }
}

extension UsernameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        APIManager.shared.cancelAllRequests()
        APIManager.shared.isExistUsername(newText) { (response, error) in
            if let response = response, let exist = response["exist"] as? Bool, exist == false {
                self.usernameCheckMarkerImageView.isHidden = false
            } else {
                self.usernameCheckMarkerImageView.isHidden = true
            }
        }
        return true
    }
}
