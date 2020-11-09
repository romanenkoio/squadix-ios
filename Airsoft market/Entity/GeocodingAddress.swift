//
//  GeocodingAddress.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/17/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper

class GeocodingAddress: Mappable {
    var houseNumber: String?
    var street: String?
    var cityDistrict: String?
    var city: String?
    var country: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        houseNumber     <- map["address.house_number"]
        street          <- map["address.road"]
        cityDistrict    <- map["address.city_district"]
        city            <- map["address.city"]
        country         <- map["address.country"]
    }
    
    func getAddressString() -> String {
        var address = ""
        
        if let street = street {
            address += street
        }
        
        if let number = houseNumber {
            address += ", \(number)"
        }
        
        if let city = city {
            address += ", \(city)"
        }
        
        return address
    }
}
