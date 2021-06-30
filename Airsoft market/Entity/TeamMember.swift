//
//  TeamMember.swift
//  Squadix
//
//  Created by Illia Romanenko on 30.06.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

struct TeamMember: Mappable {
    var id: Int!
    var profileName: String!
    var avatar: String?

    
    init() {
    }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id                      <- map["userId"]
        profileName             <- map["name"]
        avatar                  <- map["avatar"]
    }
}
    
