//
//  CTUser.swift
//  Zoot
//
//  Created by LoveMobile on 9/22/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit
import FirebaseAuth

class CTUser: NSObject {
    var userId: Int = 0
    var email: String = ""
    var password: String = ""
    var username: String = ""
    var name: String = ""
    var phone: String = ""
    var phone_code: String = ""
    var birthday: Date = Date()
    var isLoggedIn: Bool = false
    
    var authDataResult: AuthDataResult? = nil
    
    static var current = CTUser()
    
    override init() {
        super.init()
    }
    
    init(dictionary: [String : Any]) {
        super.init()
    }
}
