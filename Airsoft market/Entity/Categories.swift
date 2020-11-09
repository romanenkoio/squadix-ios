//
//  Categories.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 11/1/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class ProductCategories: Mappable {
    var id: Int!
    var name: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        id      <- map["id"]
        name    <- map["name"]
    }
}
