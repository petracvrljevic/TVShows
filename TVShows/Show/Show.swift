//
//  Show.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import Foundation

struct Show: Decodable {
    
    let id: String
    let title: String
    let imageUrl: String
    let likesCount: Int
    var description: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case imageUrl
        case likesCount
        case description
    }
    
}
