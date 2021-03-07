//
//  UserProfile.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

struct Profile: Mappable {

    var id: Int!
    var profileName: String!
    var email: String!
    var profilePictureUrl: String?
    var country: String?
    var city: String?
    var profileDescription: String?
    var phone: String?
    var birthday: Date?
    var roles: [Common.Roles]!
    var isBlocked: Bool = false
    
    init() {
    }
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id                      <- map["id"]
        profileName             <- map["displayName"]
        email                   <- map["email"]
        profilePictureUrl       <- map["profilePictureUrl"]
        country                 <- map["country"]
        city                    <- map["city"]
        profileDescription      <- map["description"]
        phone                   <- map["phone"]
        isBlocked               <- map["isBlocked"]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let localDate = map["birthday"].currentValue as? String, let date = formatter.date(from: localDate) {
            birthday = date
        } else {
            self.birthday = nil
        }
        
        if let currentRole = map["roles"].currentValue as? [String] {
            self.roles = currentRole.map({Common.shared.role(role: $0) })
        }
    }
    
    func asParams() -> [String: Any] {
        var params = [String: Any]()
        if birthday != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let birthday = birthday {
                params["birthday"] =  dateFormatter.string(from: birthday)
            }
        }
        
        if city  != "" {
            params["city"] = city
        }
        
        if country != "" {
            params["country"] = country
        }
        
        if profileDescription != "" {
            params["description"] = profileDescription
        }
        
        if profileName != "" {
            params["displayName"] = profileName
        }
        
        if phone != "" {
            params["phone"] = phone
        }
        
        return params
    }
}

