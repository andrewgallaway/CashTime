//
//  PhoneVC.swift
//  Zoot
//
//  Created by LoveMobile on 8/24/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import SVPinView
import FirebaseAuth

class PhoneVC: UIViewController {

    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneTextField: FPNTextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var smsLabel: UILabel!
    
    fileprivate let leftImageView = UIImageView()
    fileprivate let rightImageView = UIImageView()
    
    var myPreferredFocusedView:UIView?
    var verificationID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        getIPaddress()
        
        CTUser.current.isLoggedIn = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let view = phoneTextField.leftView {
            leftImageView.backgroundColor = .white
            rightImageView.backgroundColor = .white
            view.addSubview(leftImageView)
            view.addSubview(rightImageView)
            leftImageView.frame = CGRect(x: 0, y: view.frame.height + 4, width: view.frame.width + 4, height: 1)
            let rect = phoneTextField.editingRect(forBounds: phoneTextField.bounds)
            rightImageView.frame = CGRect(x: rect.origin.x + 32, y: view.frame.height + 4, width: rect.width - 32, height: 1)
        }
    }
    
    func initUI() {
        
        continueButton.layer.borderColor = UIColor.white.cgColor
        
        phoneTextField.delegate = self
        phoneTextField.textColor = .white
        phoneTextField.flagButtonSize = CGSize(width: 35, height: 35)
        phoneTextField.flagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        phoneTextField.textAlignment = .center
        phoneTextField.becomeFirstResponder()
   }
    
    func signinwithPhone(verficationCode: String) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationID!,
        verificationCode: verficationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { authData, error in
            if (error != nil) {
                    // Handles error
                    print(error)
                    return
            }
            let userInfo = authData!.user
            print("success")
        }
    }
    
    func getIPaddress() {
        getIpLocation(){ response,error  in
           
            if error == nil {
                let responseData = response as! [String: Any]
                let countryCode = responseData["countryCode"] as! String
                self.phoneTextField.setFlag(countryCode: FPNCountryCode.init(rawValue: countryCode)!)
                print(responseData)
            } else {
                print(error!)
            }
        }
    }
    func getIpLocation(completion: @escaping(NSDictionary?, Error?) -> Void) {
        let url     = URL(string: "http://ip-api.com/json")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request as URLRequest, completionHandler:
        { (data, response, error) in
            DispatchQueue.main.async
            {
                if let content = data
                {
                    do
                    {
                        if let object = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as? NSDictionary
                        {
                            completion(object, error)
                        }
                        else
                        {
                            // TODO: Create custom error.
                            completion(nil, nil)
                        }
                    }
                    catch
                    {
                        // TODO: Create custom error.
                        completion(nil, nil)
                    }
                }
                else
                {
                    completion(nil, error)
                }
            }
        }).resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PincodeVC" {
            let controller = segue.destination as! PincodeVC
            controller.phoneNumber = sender as! String
        }
    }
    // MARK: - IBAction
    @objc @IBAction func sendSMSAction() {
        self.view.endEditing(true)
        // here is test signup informatoin for Aws auth...
        guard let phone = phoneTextField.getRawPhoneNumber() else {
            showAlertViewController(message: "Please enter valid phone number!")
            return
        }
        CTUser.current.phone = phoneTextField.text!
        CTUser.current.phone_code = phoneTextField.selectedCountry!.phoneCode
        performSegue(withIdentifier: "PincodeVC", sender: phone)
    }
    
    func signUp(username: String, password: String, email: String, phonenumber: String) {
            PhoneAuthProvider.provider().verifyPhoneNumber(phonenumber, uiDelegate: nil) { (verificationID, error) in
              if let error = error {
                print(error)
                return
              }
              self.verificationID = verificationID
               
              // Sign in using the verificationID and the code sent to the user
              // ...
            }
    }
    
    override var preferredFocusedView: UIView? {
        return myPreferredFocusedView
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}
extension PhoneVC: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        print(isValid)
    }
    
    func fpnDisplayCountryList() {
        
    }
    
    
}

