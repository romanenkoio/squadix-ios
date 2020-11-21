//
//  Event.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

class Event: Decodable {
    var shortDescription: String!
    var description: String!
    var authorID: Int!
    var imageUrls: [String]!
    var createdAt: Date!
    var eventAdress: String?
    var region: String?
    var eventStartAdress: String!
    var eventStartLatitude: Double?
    var eventStartLongitude: Double?
    var eventLatitude: Double?
    var eventLongitude: Double?
    var eventDate: Date!
    var startTime: Date!
    var id: Int = 0
    var authorName: String!
    var authorAvatarUrl: String?
    var likesCount: Int = 0
    var isLiked = false
    var isPreview = false
    
    func asParams(with images: [UIImage]) -> [String: Any] {
        var params = [String: Any]()
        
        var imagedata: [String] = []
        for image in images {
            if let im = image.jpegData(compressionQuality: 0.4) {
                if let compressedImage = UIImage(data: im) {
                    if let codedImage = compressedImage.toBase64() {
                        imagedata.append(codedImage)
                    }
                }
            }
        }
        
        params["images"] = imagedata
        params["description"] = self.description
        params["eventAddress"] = self.eventAdress
        params["eventLatitude"] = self.eventLatitude
        params["eventLongitude"] = self.eventLongitude
        params["eventStartAddress"] = self.eventStartAdress
        params["eventStartLatitude"] = self.eventStartLatitude
        params["eventStartLongitude"] = self.eventStartLongitude
        params["shortDescription"] = self.shortDescription
        
        if eventDate != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = eventDate {
                params["eventDate"] =  dateFormatter.string(from: date)
            }
        }
        
        if startTime != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = startTime {
                params["startTime"] =  dateFormatter.string(from: date)
            }
        }
        
        return params
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case shortDescription
        case description
        case authorId
        case imageUrls
        case createdAt
        case eventAddress
        case country
        case eventStartAddress
        case eventStartLatitude
        case eventStartLongitude
        case eventLatitude
        case eventLongitude
        case eventDate
        case contacts
        case startTime
        case id
        case authorName
        case authorAvatarUrl
        case likesCount
        case liked
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let formatter = ISO8601DateFormatter()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.description = try container.decode(String.self, forKey: .description)
        authorID = try container.decode(Int.self, forKey: .authorId)
        imageUrls = try container.decode([String].self, forKey: .imageUrls)
        
        if let created = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            let eventFormatter = DateFormatter()
            eventFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let localDate = eventFormatter.date(from: created) {
                self.createdAt = localDate
            } else {
                self.createdAt = nil
            }
        }
        
        eventAdress = try container.decode(String.self, forKey: .eventAddress)
        region = try container.decode(String.self, forKey: .country)
        eventStartAdress = try container.decode(String.self, forKey: .eventStartAddress)
        eventStartLatitude = try container.decode(Double.self, forKey: .eventStartLatitude)
        eventStartLongitude = try container.decode(Double.self, forKey: .eventStartLongitude)
        eventLatitude = try container.decode(Double.self, forKey: .eventLatitude)
        eventLongitude = try container.decode(Double.self, forKey: .eventLongitude)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        isLiked = try container.decode(Bool.self, forKey: .liked)
        
        
        if let created = try container.decodeIfPresent(String.self, forKey: .eventDate) {
          
            if let localDate = formatter.date(from: created) {
                self.eventDate = localDate
            } else {
                self.eventDate = nil
            }
        }
        
        
        if let start = try container.decodeIfPresent(String.self, forKey: .startTime) {
            if let localDate = formatter.date(from: start) {
                self.startTime = localDate
            } else {
                self.startTime = nil
            }
        }
        
        id = try container.decode(Int.self, forKey: .id)
        authorName = try container.decode(String.self, forKey: .authorName)
        
        if let authorAvatarUrl = try container.decodeIfPresent(String.self, forKey: .authorAvatarUrl) {
            self.authorAvatarUrl = authorAvatarUrl
        }
    }
}


class Events: Decodable {
    var content: [Event]!
    var totalElements: Int!
    var totalPages: Int!
    
    private enum CodingKeys: String, CodingKey {
         case content
         case totalElements
         case totalPages
     }
    
    required init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           content = try container.decode([Event].self, forKey: .content)
           totalElements = try container.decode(Int.self, forKey: .totalElements)
           totalPages = try container.decode(Int.self, forKey: .totalPages)
    }
}
