//
//  UsernameVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/8/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
    
    func verifyUsername(_ username: String) {
        let query = Firestore.firestore().collection("users").whereField("username", in: [username]).limit(to: 1)
        query.getDocuments(completion: { (snapshot, error) in
            if let snapshot = snapshot, snapshot.count > 0 {
                self.usernameCheckMarkerImageView.isHidden = true
            } else {
                self.usernameCheckMarkerImageView.isHidden = false
            }
        })
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        guard let username = usernameTextField.text else { return }
        if username.count == 0 {
            showAlertViewController(message: "Username cannot be empty!")
            return
        }
        
        CTUser.current.username = username
        
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let store = Firestore.firestore().collection("users").document(uid)
            store.setData(["email" : CTUser.current.email, "name" : CTUser.current.name, "birthday" : CTUser.current.birthday, "username" : CTUser.current.username], merge: true)
        }
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
            verifyUsername(username)
        }
        
    }
}

extension UsernameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        verifyUsername(newText)
        return true
    }
}
