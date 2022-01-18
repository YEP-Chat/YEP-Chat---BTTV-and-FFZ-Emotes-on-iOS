//
//  GetGlobalEmotes.swift
//  YEP Chat
//
//  Created by Darren Key on 6/8/21.
//

import Foundation

struct DataGlobalBadges: Decodable {
    let data: [SetsGlobalBadge]
    
    
}

struct SetsGlobalBadge: Decodable {
    let set_id: String
    let versions: [[String:String]]
    
}

