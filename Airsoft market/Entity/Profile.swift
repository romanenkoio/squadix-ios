//
//  UserProfile.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

struct Contact: Decodable {
    var method: Methods = .error
    var contact: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case method = "method"
        case contact = "contact"
    }
    
    init(method: String, contact: String) {
        self.method = Methods.checkMethod(method)
        self.contact = contact
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let method = try container.decodeIfPresent(String.self, forKey: .method) {
            self.method = Methods.checkMethod(method)
        }
        contact = try container.decode(String.self, forKey: .contact)
    }
}

struct Profile: Decodable {
    var id: Int!
    var profileName: String!
    var email: String!
    var profilePictureUrl: String?
    var contacts: [Contact]?
    var country: String?
    var city: String?
    var profileDescription: String?
    var phone: String?
    var birthday: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case profileName = "displayName"
        case email = "email"
        case profilePictureUrl = "profilePictureUrl"
        case contacts = "contacts"
        case country = "country"
        case city = "city"
        case description = "description"
        case birthday = "birthday"
        case phone = "phone"
    }
    
    init() {
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        profileName = try container.decode(String.self, forKey: .profileName)
        email = try container.decode(String.self, forKey: .email)
        if let profilePictureUrl = try container.decodeIfPresent(String.self, forKey: .profilePictureUrl) {
            self.profilePictureUrl = profilePictureUrl
        }
        if let contacts = try container.decodeIfPresent([Contact].self, forKey: .contacts) {
            self.contacts = contacts
        }
        if let country = try container.decodeIfPresent(String.self, forKey: .country) {
            self.country = country
        }
        if let city = try container.decodeIfPresent(String.self, forKey: .city) {
            self.city = city
        }
        if let description = try container.decodeIfPresent(String.self, forKey: .description) {
            self.profileDescription = description
        }
        if let stringBirthday = try container.decodeIfPresent(String.self, forKey: .birthday) {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let localDate = formatter.date(from: stringBirthday) {
                self.birthday = localDate
            } else {
                self.birthday = nil
            }
            
        }
        if let phone = try container.decodeIfPresent(String.self, forKey: .phone) {
            self.phone = phone
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
        
        return params
    }
}
