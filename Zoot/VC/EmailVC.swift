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
        
        emailTextField.attributedPlaceholder = NSAttributedString(string:"Email", attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        performSegue(withIdentifier: "WelcomeVC", sender: nil)
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        
    }
}
