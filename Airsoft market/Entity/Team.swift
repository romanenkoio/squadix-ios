//
//  Team.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class TeamObject: Mappable, PaginableObject {
    var totalElements: Int = 0
    var totalPages: Int = 0
    var content: [Team] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        content                   <- map["content"]
        totalPages                <- map["totalPages"]
        totalElements             <- map["totalElements"]
    }
}

class Team: Mappable {
    var name: String!
    var city: String!
    var country: String!
    var people: [TeamMember] = []
    var description: String!
    var id = 0
    var teamAvatar = ""
    var ownerID = 0
    var photos: [TeamImage] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(name: String, city: String, description: String) {
        self.name = name
        self.city = city
        self.description = description
        self.country = "Беларусь"
    }
    
    func mapping(map: Map) {
        name                <- map["name"]
        city                <- map["city"]
        country             <- map["country"]
        people              <- map["members"]
        description         <- map["description"]
        id                  <- map["id"]
        teamAvatar          <- map["logoUrl"]
        ownerID             <- map["ownerId"]
        photos              <- map["images"]
    }
}

extension Team: Convertable {
    func asParams() -> [String : Any] {
        var params = [String: Any]()
        params["name"] = name
        params["city"] = city
        params["country"] = country
        params["description"] = description
        
        return params
    }
}


class TeamImage: Mappable {
    var id = 0
    var url = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    

    func mapping(map: Map) {
        id         <- map["id"]
        url        <- map["url"]
    }
}

//"id": 1,
//      "url": "https://strike-nonprod.s3.eu-central-1.amazonaws.com/2021-06-30T21:41:41.455879Z_0bb5d280-bb73-4222-a89c-8a375873fabd.png",
//      "createdByUserId": "1",
//      "createdByUserName": "Илья Романенко",
//      "createdByUserAvatar": "https://strike-nonprod.s3.eu-central-1.amazonaws.com/2021-04-02T15:50:31.234530Z_photo.jpg",
//      "createdAt": "2021-06-30T21:41:43.583929Z"
