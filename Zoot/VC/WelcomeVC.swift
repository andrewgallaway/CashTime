//
//  WelcomeVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/18/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var bottomView: ArcView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bottomView.arcColor = UIColor("#2FAC70")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func continueAction(_ sender: UIButton?) {
        performSegue(withIdentifier: "NameVC", sender: nil)
    }
}
