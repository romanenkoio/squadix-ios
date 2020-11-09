//
//  Post.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

enum PostContentType: String {
    case video = "VIDEO"
    case image = "POST"
    case none = "none"
}

class Post: Mappable {

    var shortDescription: String = ""
    var description: String = ""
    var authorID: Int = 0
    var imageUrls: [String]!
    var previewImages: [UIImage] = []
    var videoUrl: String?
    var postDate: String?
    var source: String?
    var rawContentType: String? {
        didSet {
            switch rawContentType {
            case "POST":
                self.contentType = .image
            case "VIDEO":
                self.contentType = .video
            default:
                self.contentType = .none
            }
        }
    }
    var contentType: PostContentType = .none
    var region: String = ""
    var id: Int = 0
    var authorName: String = ""
    var authorAvatarUrl: String?
    var likesCount: Int = 0
    var isLiked = false
    var isPreview = false

    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        shortDescription    <- map["imageUrls"]
        description         <- map["description"]
        authorID            <- map["authorId"]
        imageUrls           <- map["imageUrls"]
        videoUrl            <- map["videoUrl"]
        postDate            <- map["createdAt"]
        source              <- map["source"]
        rawContentType      <- map["contentType"]
        region              <- map["region"]
        id                  <- map["id"]
        authorName          <- map["authorName"]
        authorAvatarUrl     <- map["authorAvatarUrl"]
        likesCount          <- map["likesCount"]
        isLiked             <- map["liked"]
    }
    
    func asVideoParams() -> [String: Any] {
        var params = [String: Any]()
        params["contentType"] = self.contentType.rawValue
        params["description"] = self.description
        params["shortDescription"] = self.shortDescription
        params["videoUrl"] = self.videoUrl
        params["images"] = []
        return params
    }
    
    func asTextParams() -> [String: Any] {
        var params = [String: Any]()
        params["contentType"] = self.contentType.rawValue
        params["description"] = self.description
        params["shortDescription"] = self.shortDescription
        params["images"] = self.imageUrls
        return params
    }
}


class Posts: Mappable {
    var content: [Post]!
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

