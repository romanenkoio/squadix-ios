//
//  Places.swift
//  Squadix
//
//  Created by Illia Romanenko on 14.05.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class City: Mappable {
    var city: String?
    var name: String?
    var countryCode: String?
    var region: String?
   
    func mapping(map: Map) {
        city            <- map["city"]
        name            <- map["name"]
        countryCode     <- map["countryCode"]
        region          <- map["region"]
    }
        
    required init?(map: Map) {
        mapping(map: map)
    }
}

class Places: Mappable {
    var data: [City] = []
    
    func mapping(map: Map) {
        data    <- map["data"]
    }
        
    required init?(map: Map) {
        mapping(map: map)
    }
}
