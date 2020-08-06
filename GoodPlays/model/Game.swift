//
//  Game.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 02/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import UIKit

struct Games: Codable {
    let games: [Game]
    
    enum CodingKeys: String, CodingKey {
        case games = "results"
    }
}

class Game: Codable {
    let id: Int
    let name: String?
    let backgroundImage: String?
    let released: Date?
    let rating: Double?
    let description: String?
    let parentPlatform: [ParentPlatform]?
    
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case backgroundImage = "background_image"
        case rating
        case description
        case released = "released"
        case parentPlatform = "platforms"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "NA"
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage) ?? ""
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0.0
        
        parentPlatform = try container.decodeIfPresent([ParentPlatform].self, forKey: .parentPlatform) ?? [ParentPlatform]()
        
        if let releasedString = try container.decodeIfPresent(String.self, forKey: .released) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let releasedDate = dateFormatter.date(from: releasedString)!
            released = releasedDate
        } else {
            released = Date()
        }
        
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
    
}

class ParentPlatform: Codable {
    let platform: Platform
    
    enum CodingKeys: String, CodingKey {
        case platform
    }
}

class Platform: Codable {
    let id: Int
    let name: String
    let slug: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
    }
}
