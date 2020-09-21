//
//  ArcView.swift
//  Zoot
//
//  Created by LoveMobile on 9/17/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class ArcView: UIView {

    public var arcColor = UIColor.white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(arcColor.cgColor)
            let radius = rect.width * 1.2
            let angle: CGFloat = .pi / 18.0
            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: radius / 2.4, y: radius), radius: radius, startAngle: -angle, endAngle: angle, clockwise: false)
            context.addPath(path.cgPath)
            context.fillPath()
        }
    }

}
