//
//  BubbleView.swift
//  Zoot
//
//  Created by LoveMobile on 9/19/20.
//  Copyright © 2020 LoveMobile. All rights reserved.
//

import UIKit

class BubbleView: UIView {

    fileprivate var leftImageView = UIImageView()
    fileprivate var middleImageView = UIImageView()
    fileprivate var rightImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.backgroundColor = .clear
        
        let bubbleImage = UIImage(named: "Bubble")
        leftImageView.image = bubbleImage
        self.addSubview(leftImageView)
        
        middleImageView.backgroundColor = UIColor("#E5E5EA")
        self.addSubview(middleImageView)
        
        rightImageView.image = bubbleImage
        self.addSubview(rightImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bubbleImage = UIImage(named: "Bubble")!
        leftImageView.frame = CGRect(x: 0, y: 0, width: bubbleImage.size.width, height: bubbleImage.size.height)
        middleImageView.frame = CGRect(x: bubbleImage.size.width / 2.0, y: 0, width: self.bounds.size.width - bubbleImage.size.width, height: bubbleImage.size.height)
        rightImageView.frame = CGRect(x: self.bounds.width - bubbleImage.size.width, y: 0, width: bubbleImage.size.width, height: bubbleImage.size.height)
        
        for view in self.subviews {
            if view is UILabel || view is UIButton {
                self.bringSubviewToFront(view)
            }
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

}
