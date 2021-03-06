//
//  Comment.swift
//  Squadix
//
//  Created by Illia Romanenko on 12.03.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class Comment: Mappable {
    var id: Int!
    var userID: Int!
    var authorAvatarURL: String?
    var entityId: Int!
    var text: String!
    var likeCount: Int = 0
    var isLiked: Bool = false
    var authorName: String!
    var createdAt: Date?
    var updatedAt: String = ""
    var images: [String] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    init(isTest: Bool) {
        userID = 1
        isLiked = false
        authorName = "Илья Романенко"
        id = 10
        entityId = 5
        text = "Текст комментаия, тестовый, больше текста, что б поширше, поширше. Ещё больше, да, давай ещё. https://github.com"
        likeCount = 0
        createdAt = Date()
    }
    
    func mapping(map: Map) {
        userID                  <- map["userId"]
        isLiked                 <- map["liked"]
        authorName              <- map["userName"]
        authorAvatarURL         <- map["userAvatarUrl"]
        id                      <- map["id"]
        entityId                <- map["entityId"]
        text                    <- map["text"]
        likeCount               <- map["likesCount"]
        isLiked                 <- map["liked"]
        images                 <- map["imageUrls"]
        
        if let created = map["createdAt"].currentValue as? String {
            let eventFormatter = DateFormatter()
            eventFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let localDate = eventFormatter.date(from: created) {
                self.createdAt = localDate
            } else {
                self.createdAt = nil
            }
        }
    }
}


class CommentContent: Mappable {
    var content: [Comment]!
    var totalElements: Int!
    var totalPages: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        content         <- map["content"]
        totalElements   <- map["totalElements"]
        totalPages      <- map["totalPages"]
    }
}
