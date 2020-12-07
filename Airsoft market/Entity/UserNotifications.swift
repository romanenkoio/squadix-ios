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
    
    init(type: Common.NotificationType) {
        switch type {
        case .aprooved:
            message = "Ваше объявление \"Электро глок\" опубликовано"
        case .decline:
            message = "Ваше объявление \"Страйкбольные гранаты\" отклонено."
        case .like:
            message = "Пользователь Михаил Кляшев поставил лайк вашему посту \"Лучшие гей-клубы города\""
        case .system:
            message = "Узнайте всё про последние обновления!"
        case .none:
            message = "Error"
        }
        
        time = Date().dateToHumanString()
        self.type = type
        profileId = 1
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        message        <- map["message"]
        profileId      <- map["profileId"]
        time           <- map["time"]
        url            <- map["url"]
        
        if let type =  map["type"].currentValue as? String {
            self.type = Common.shared.notificationType(type: type)
        }
    }
    
   
}
