//
//  Game.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 02/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import UIKit

struct Games: Codable {
    let next: String?
    let games: [Game]
    
    enum CodingKeys: String, CodingKey {
        case next
        case games = "results"
    }
}

class Game: Codable {
    let id: Int
    let name: String?
    let backgroundImage: String?
    let released: Date?
    let rating: Double?
    
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case backgroundImage = "background_image"
        case rating
        case released = "released"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        backgroundImage = try container.decode(String.self, forKey: .backgroundImage)
        rating = try container.decode(Double.self, forKey: .rating)
        
        let releasedString = try container.decode(String.self, forKey: .released)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let releasedDate = dateFormatter.date(from: releasedString)!
        released = releasedDate
    }
    
}

class PendingOperations {
    lazy var downloadInProgress: [IndexPath : Operation] = [:]
 
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.cesa.imagedownload"
        queue.maxConcurrentOperationCount = 2
        return queue
    }()
}
