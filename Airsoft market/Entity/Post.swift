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

class Post: BasePost {
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


    required init?(map: Map) {
        super.init(map: map)
        mapping(map: map)
    }
    
    override init() {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        videoUrl            <- map["videoUrl"]
        postDate            <- map["createdAt"]
        source              <- map["source"]
        rawContentType      <- map["contentType"]
        region              <- map["region"]
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

