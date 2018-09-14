//
//  Comment.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    
    let id: String
    let text: String
    let episodeId: String
    let userEmail: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case episodeId
        case userEmail
    }
    
}
