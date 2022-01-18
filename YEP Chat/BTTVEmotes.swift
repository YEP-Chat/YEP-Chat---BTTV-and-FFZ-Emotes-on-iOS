//
//  BTTVEmotes.swift
//  YEP Chat
//
//  Created by Darren Key on 5/25/21.
//

import Foundation

struct BTTVEmotes: Decodable{
    let name: String
    let id: String
    let imageType: String
    
    enum CodingKeys: String, CodingKey {
        case name = "code"
        case id = "id"
        case imageType = "imageType"
      }
}
