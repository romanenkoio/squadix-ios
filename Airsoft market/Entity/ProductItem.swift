//
//  ProductItem.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

enum ProductStatus: String {
    case moderating = "MODERATING"
    case deleted = "DELETED"
    case active = "ACTIVE"
    case unknown = "UNKNOWN"
}


class MarketProduct: Mappable {
    var picturesUrl: [String]!
    var images: [UIImage]?
    var productName: String!
    var price: Int!
    var productRegion: String!
    var productCategory: String!
    var createdAt: String!
    var authorID: Int!
    var postID: Int = 0
    var postAvalible = false
    var description: String!
    var isPreview = false
    var authorAvatarURL: String?
    var authorName: String?
    var phone: String?
    var status: ProductStatus? = .unknown
    var upTime: String!
    var reserved: Bool = false
    var authorPhone: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        picturesUrl      <- map["imageUrls"]
        productName      <- map["name"]
        price            <- map["price"]
        productRegion    <- map["region"]
        productCategory  <- map["category"]
        createdAt        <- map["createdAt"]
        authorID         <- map["authorId"]
        postID           <- map["id"]
        postAvalible     <- map["postalDeliveryAvailable"]
        description      <- map["description"]
        authorAvatarURL  <- map["authorAvatarUrl"]
        authorName       <- map["authorName"]
        upTime           <- map["upTime"]
        reserved         <- map["reserved"]
        authorPhone      <- map["authorPhone"]
        
        if let tempStatus = map["status"].currentValue as? String {
            switch tempStatus {
            case ProductStatus.active.rawValue:
                status = .active
            case ProductStatus.deleted.rawValue:
                status = .deleted
            case ProductStatus.moderating.rawValue:
                status = .moderating
            default:
                status = .unknown
            }
        }
    }
    
    func asParams(isEdit: Bool = false, with images: [UIImage])  -> [String: Any] {
        var params = [String: Any]()
        
        if !isEdit {
            var imagedata: [String] = []
            for image in images {
                if let codedImage = image.toBase64() {
                    imagedata.append(codedImage)
                }
            }
            params["images"] = imagedata
        }
        
        params["category"] = productCategory
        params["description"] = description
        params["name"] = productName
        params["price"] = price
        params["region"] = productRegion
        params["reserved"] = reserved
        params["postalDeliveryAvailable"] = postAvalible
        return params
    }
}

class Products: Mappable {
    var content: [MarketProduct]!
    var totalPages: Int!
    var totalElements: Int!
    
    required init?(map: Map) {
           mapping(map: map)
       }
       
       init() {
       }
       
       func mapping(map: Map) {
          content         <- map["content"]
          totalPages      <- map["totalPages"]
          totalElements   <- map["totalElements"]
       }
}
