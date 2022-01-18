//
//  GlobalFFZEmotes.swift
//  YEP Chat
//
//  Created by Darren Key on 6/8/21.
//

import Foundation

struct GlobalFFZ: Decodable {
    let sets: [String: Sets]
    let default_sets: [Int]
}
