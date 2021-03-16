//
//  Reports.swift
//  Squadix
//
//  Created by Illia Romanenko on 16.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class Reports: Mappable {
    var link: String = ""
    var createdAt: Date!
    var reporterID: Int = 0
    var isReaded = false
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        link            <- map["link"]
        createdAt       <- map["createdAt"]
        reporterID      <- map["reporterID"]
        isReaded        <- map["isReaded"]
    }
}
