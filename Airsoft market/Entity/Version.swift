//
//  Version.swift
//  Squadix
//
//  Created by Illia Romanenko on 30.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class Version: Mappable {
    var version: String!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        version      <- map["ios"]
    }
}
