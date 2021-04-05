//
//  Team.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class Team: Mappable {
    var name = "Ромашки"
    var city = "Минск"
    var country = "Буларусь"
    var people: [Profile] = []
    var description = "Наша команда состоит преимущественно из снайперов (марксменов). Соответственно основные задачи нашей команды на играх это разведка, охрана объектов, засадные действия. На крупных играх нашей команде дают отмашку на свободную охоту"
    var id = 0
    var teamAvatar = ""
    var smallTeamAvatar = ""
    var ownerID = 0
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        name                <- map["name"]
        city                <- map["city"]
        country             <- map["country"]
        people              <- map["people"]
        description         <- map["description"]
        id                  <- map["id"]
        teamAvatar          <- map["teamAvatar"]
        smallTeamAvatar     <- map["smallTeamAvatar"]
        ownerID             <- map["ownerID"]
    }
}

extension Team: Creatable {
    func asParams() -> [String : Any] {
        var params = [String: Any]()
        params["name"] = name
        params["city"] = city
        params["country"] = country
        params["description"] = description
        
        return params
    }
}
