//
//  NameVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/17/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class NameVC: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    
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
        progressView.progress = 0.2
        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name", attributes:[NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white])
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - IBAction
    @objc @IBAction func nextAction() {
        guard let name = nameTextField.text else { return }
        if name.count == 0 {
            showAlertViewController(message: "Name cannot be empty!")
            return
        }
        
        CTUser.current.name = name
        performSegue(withIdentifier: "BirthdateVC", sender: nil)
    }
    
    @objc @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        
    }
}
