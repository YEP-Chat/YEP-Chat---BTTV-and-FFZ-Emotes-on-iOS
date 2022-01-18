//
//  Emote.swift
//  YEP Chat
//
//  Created by Darren Key on 5/24/21.
//

import Foundation

struct Emote: Decodable {
    
    let name : String
    var urls : [String: String]
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case urls = "urls"
      }
}
