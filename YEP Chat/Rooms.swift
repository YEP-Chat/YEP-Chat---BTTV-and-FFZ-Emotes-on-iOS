//
//  Rooms.swift
//  YEP Chat
//
//  Created by Darren Key on 5/24/21.
//

import Foundation

struct Rooms: Decodable {
    let sets: [String: Sets]
    let room: Room
}
