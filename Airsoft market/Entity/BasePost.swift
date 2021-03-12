//
//  BasePost.swift
//  Squadix
//
//  Created by Illia Romanenko on 29.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class BasePost: Mappable {
    var authorAvatarURL: String?
    var authorID: Int!
    var shortDescription: String = ""
    var description: String = ""
    var imageUrls: [String]!
    var authorName: String = ""
    var likesCount: Int = 0
    var isLiked = false
    var isPreview = false
    var id: Int = 0
    var commentsCount: Int = 0
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        shortDescription        <- map["shortDescription"]
        description             <- map["description"]
        authorID                <- map["authorId"]
        imageUrls               <- map["imageUrls"]
        likesCount              <- map["likesCount"]
        isLiked                 <- map["liked"]
        authorName              <- map["authorName"]
        authorAvatarURL         <- map["authorAvatarUrl"]
        id                      <- map["id"]
        commentsCount           <- map["commentsCount"]
    }
}
