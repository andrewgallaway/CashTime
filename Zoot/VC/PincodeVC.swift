//
//  PincodeVC.swift
//  
//
//  Created by LoveMobile on 9/18/20.
//

import UIKit
import SVPinView
import FirebaseAuth
import SVProgressHUD

class PincodeVC: UIViewController {

    @IBOutlet weak var pincodeView: SVPinView!
    @IBOutlet weak var phoneLabel: UILabel!
    
    public var phoneNumber: String!
    public var verificationID: String!
    public var isSignin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        phoneLabel.text = phoneNumber
        
        pincodeView.font = UIFont(name: "Montserrat-Bold", size: 18)!
        pincodeView.style = .none
        pincodeView.pinLength = 6
        pincodeView.shouldSecureText = false
        pincodeView.fieldBackgroundColor = .white
        pincodeView.fieldCornerRadius = 8
        pincodeView.activeFieldBackgroundColor = .white
        pincodeView.activeFieldCornerRadius = 8
        pincodeView.didFinishCallback = { pin in
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID, verificationCode: pin)
            SVProgressHUD.show()
            Auth.auth().signIn(with: credential) { (authResult, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    showAlertViewController(title: "Error", message: error.localizedDescription)
                } else {
                    CTUser.current.authDataResult = authResult
                    if self.isSignin {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.performSegue(withIdentifier: "EmailVC", sender: nil)
                    }
                }
            }
        }
        pincodeView.didChangeCallback = { pin in
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc @IBAction func sendSMSAction() {
        // self.view.endEditing(true)
        // here is test signup informatoin for Aws auth...
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "birthdateVC") as! BirthdateVC
        self.navigationController?.pushViewController(vc, animated: true)
        // self.signUp(username: "demotest3", password: "'demotest1234", email: "demotest@dev.com", phonenumber: "+15518047124")
    }
}
