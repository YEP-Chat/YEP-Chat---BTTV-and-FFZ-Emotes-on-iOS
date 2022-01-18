//
//  RoundedCorners.swift
//  YEP Chat
//
//  Created by Darren Key on 1/12/22.
//

import UIKit

class RoundedCorners: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layer.cornerRadius = 10
    }

}
