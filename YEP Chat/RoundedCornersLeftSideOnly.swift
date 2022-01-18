//
//  RoundedCornersLeftSideOnly.swift
//  YEP Chat
//
//  Created by Darren Key on 1/12/22.
//

import UIKit
import Starscream

class RoundedCornersLeftSideOnly: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var cornerRadius : CGFloat = 10
    
    func roundCorners(){
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        print("Should round")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
