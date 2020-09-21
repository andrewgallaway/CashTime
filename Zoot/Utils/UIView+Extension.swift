//
//  UIView+Extension.swift
//  Zoot
//
//  Created by LoveMobile on 9/17/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

extension UIView {
    func round(_ cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
