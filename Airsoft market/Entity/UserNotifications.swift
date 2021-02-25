//
//  UserNotifications.swift
//  Squadix
//
//  Created by Illia Romanenko on 7.12.20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class DasboardNotification: Mappable {
    var message: String!
    var profileId: Int?
    var time: String!
    var url: String?
    var type: Common.NotificationType!
    var isReaded: Bool = false
    
    init() { }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        message        <- map["message"]
        profileId      <- map["profileId"]
        time           <- map["createdAt"]
        url            <- map["url"]
        isReaded       <- map["readed"]
        
        if let type =  map["type"].currentValue as? String {
            self.type = Common.shared.notificationType(type: type)
        }
    }
}

class DashboardContent: Mappable {
    var content: [DasboardNotification]!
    var totalElements: Int!
    var totalPages: Int!
    var newCount: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        content             <- map["content"]
        totalElements       <- map["totalElements"]
        totalPages          <- map["totalPages"]
    }
}
