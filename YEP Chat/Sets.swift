//
//  Sets.swift
//  YEP Chat
//
//  Created by Darren Key on 5/24/21.
//

import Foundation

struct Sets: Decodable {
    var emotes: [Emote]
    enum CodingKeys: String, CodingKey {
        case emotes = "emoticons"
  }
}
