//
//  Message.swift
//  Squadix
//
//  Created by Illia Romanenko on 19.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class Message: Mappable {
    var message: String?
    var ownerID: Int?
    var createdAt: String!
    var authorAvatarUrl: String?
    var conservationID: Int!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        ownerID             <- map["ownerID"]
        authorAvatarUrl     <- map["authorAvatarUrl"]
        message             <- map["message"]
        createdAt           <- map["createdAt"]
        conservationID      <- map["conservationID"]
    }
    
    func asParams() -> [String: Any] {
        var params = [String: Any]()
        
        params["authorId"] = KeychainManager.profileID
        params["message"] = self.message
        params["conservationID"] = self.conservationID
        
        return params
    }
}
