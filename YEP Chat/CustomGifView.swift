//
//  CustomGifView.swift
//  YEP Chat
//
//  Created by Darren Key on 6/14/21.
//

import UIKit
import Gifu
import YYImage

class CustomGifView: YYAnimatedImageView, GIFAnimatable {
    
    public lazy var animator: Animator? = {
      return Animator(withDelegate: self)
    }()

    override public func display(_ layer: CALayer) {
      updateImageIfNeeded()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
