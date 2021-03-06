//
//  AuthResponce.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/15/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

struct AuthResponce: Decodable {
    let accessToken: String!
    let tokenType: String!
    
    func getFullToken() -> String {
        return tokenType + " " + accessToken
    }
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case tokenType = "tokenType"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
    }
}

struct NetworkError: Mappable {
    var timestamp: String = ""
    var status: Int = 0
    var error: String = ""
    var message: String = ""
    var path: String = ""
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    init() {
    }
    
    mutating func mapping(map: Map) {
        timestamp     <- map["timestamp"]
        status        <- map["status"]
        error         <- map["error"]
        message       <- map["message"]
        path          <- map["path"]
    }
}

struct Currency: Mappable {
    var curId: Int!
    var rate: Double!
    var date: String!
    var scale: Int!
    var name: String!
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
       curId    <- map["Cur_ID"]
       rate     <- map["Cur_OfficialRate"]
       date     <- map["Date"]
       scale    <- map["Cur_Scale"]
       name     <- map["Cur_Name"]
    }

}
