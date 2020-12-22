//
//  CTMedia.swift
//  Zoot
//
//  Created by WMaster on 9/29/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class CTMedia: NSObject {
    var mediaId: Int = 0
    var mediaType: Int = 0
    var userId: Int = 0
    var isProfile: Bool = false
    var path: String = ""
    
    override init() {
        super.init()
    }
    
    init(dictionary: [String : Any]) {
        super.init()
    }
}
