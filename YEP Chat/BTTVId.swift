//
//  BTTVId.swift
//  YEP Chat
//
//  Created by Darren Key on 5/25/21.
//

import Foundation

struct BTTVId: Decodable {
    let id : String
    var BTTVEmotes : [BTTVEmotes]
    let sharedEmotes: [BTTVEmotes]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case BTTVEmotes = "channelEmotes"
        case sharedEmotes = "sharedEmotes"
      }
}

