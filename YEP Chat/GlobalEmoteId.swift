//
//  GlobalEmoteId.swift
//  YEP Chat
//
//  Created by Darren Key on 5/26/21.
//

import Foundation

struct GlobalEmoteId: Decodable{
    let id : [GlobalEmote]
    
    enum CodingKeys: String, CodingKey {
        case id = "0"
      }
}
