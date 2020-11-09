//
//  AuthResponce.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/15/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

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

struct NetworkError: Decodable {
    var timestamp: String = ""
    var status: Int = 0
    var error: String = ""
    var message: String = ""
    var path: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case timestamp
        case status
        case error
        case message
        case path
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        status = try container.decode(Int.self, forKey: .status)
        error = try container.decode(String.self, forKey: .error)
        message = try container.decode(String.self, forKey: .message)
        path = try container.decode(String.self, forKey: .path)
    }
    
    init() {
    }
}

struct Currency: Decodable {
    var curId: Int!
    var rate: Double!
    var date: String!
    var scale: Int!
    var name: String!
    
    private enum CodingKeys: String, CodingKey {
        case curId = "Cur_ID"
        case rate = "Cur_OfficialRate"
        case date = "Date"
        case name = "Cur_Name"
        case scale = "Cur_Scale"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        curId = try container.decode(Int.self, forKey: .curId)
        rate = try container.decode(Double.self, forKey: .rate)
        date = try container.decode(String.self, forKey: .date)
        scale = try container.decode(Int.self, forKey: .scale)
        name = try container.decode(String.self, forKey: .name)
    }
}
