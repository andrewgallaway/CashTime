//
//  MoveandzoomVC.swift
//  Zoot
//
//  Created by LoveMobile on 9/8/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class MoveandzoomVC: UIViewController {

    @IBOutlet weak var backbtnImageView: UIImageView!
    @IBOutlet weak var imageView: BorderImageView!
    @IBOutlet weak var continueButton: UIView!
    
    public var image: UIImage?
    public var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initUI() {
        continueButton.layer.borderColor = UIColor.white.cgColor
        self.imageView.image = image
    }
    
    @objc @IBAction func nextAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc @IBAction func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setProfileAction(_ sender: Any?) {
        
    }
}
