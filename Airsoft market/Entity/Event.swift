//
//  Event.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/27/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class Event: BasePost {
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
    
    required init?(map: Map) {
        super.init(map: map)
        mapping(map: map)
    }
    
    override init() {
        super.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        let formatter = ISO8601DateFormatter()
        eventAdress             <- map["eventAddress"]
        region                  <- map["country"]
        eventStartAdress        <- map["eventStartAddress"]
        eventStartLatitude      <- map["eventStartLatitude"]
        eventStartLongitude     <- map["eventStartLongitude"]
        eventLatitude           <- map["eventLatitude"]
        eventLongitude          <- map["eventLongitude"]
        
        
        if let created = map["eventDate"].currentValue as? String {
            if let localDate = formatter.date(from: created) {
                self.eventDate = localDate
            } else {
                self.eventDate = nil
            }
        }
        
        if let created = map["startTime"].currentValue as? String {
            if let localDate = formatter.date(from: created) {
                self.startTime = localDate
            } else {
                self.startTime = nil
            }
        }
        
        if let created = map["createdAt"].currentValue as? String {
            let eventFormatter = DateFormatter()
            eventFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let localDate = eventFormatter.date(from: created) {
                self.createdAt = localDate
            } else {
                self.createdAt = nil
            }
        }
    }
    
    func asParams(with images: [UIImage]) -> [String: Any] {
        var params = [String: Any]()
        
        var imagedata: [String] = []
        for image in images {
            if let codedImage = image.toBase64() {
                imagedata.append(codedImage)
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
}

class Events: Mappable {
    var content: [Event]!
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
