//
//  ChatMessage.swift
//  YEP Chat
//
//  Created by Darren Key on 6/10/21.
//

import UIKit
import BSText
import YYImage

class ChatMessage: UITableViewCell {

    @IBOutlet weak var chatmsg: BSLabel!
    
    
    ///delete animated image views that are the subview
    override func prepareForReuse() {
        chatmsg.attributedText = NSAttributedString(string: "")
//        for subview in chatmsg.subviews{
//            if type(of: subview) == type(of: YYAnimatedImageView()){
//                subview.removeFromSuperview()
//            }
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
