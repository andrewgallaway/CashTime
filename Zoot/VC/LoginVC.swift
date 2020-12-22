//
//  LoginVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/17/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class LoginVC: UIViewController {

    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    func initUI() {
        navigationController?.isNavigationBarHidden = true
        
        signinButton.layer.borderColor = UIColor("#2FAC70").cgColor
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PhoneVC" {
            let controller = segue.destination as! PhoneVC
            controller.isSignin = sender as! Bool
        }
    }

    // MARK: - IBAction
    @IBAction func createAction(_ sender: UIButton?) {
        performSegue(withIdentifier: "PhoneVC", sender: false)
    }
    
    @IBAction func signinAction(_ sender: UIButton?) {
        performSegue(withIdentifier: "PhoneVC", sender: true)
    }
}
