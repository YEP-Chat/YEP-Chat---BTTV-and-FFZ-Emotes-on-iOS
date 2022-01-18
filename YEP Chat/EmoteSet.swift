//
//  EmoteSet.swift
//  YEP Chat
//
//  Created by Darren Key on 5/24/21.
//

import Foundation

struct EmoteSet: Decodable {
    let emoticons : [Emote]
    enum CodingKeys: String, CodingKey {
        case emoticons = "emoticons"
      }
}
