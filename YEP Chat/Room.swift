//
//  Room.swift
//  YEP Chat
//
//  Created by Darren Key on 5/24/21.
//

import Foundation

struct Room: Decodable {
    let setID : Int
    let twitchID: Int
    enum CodingKeys: String, CodingKey {
        case setID = "set"
        case twitchID = "twitch_id"
  }
}
