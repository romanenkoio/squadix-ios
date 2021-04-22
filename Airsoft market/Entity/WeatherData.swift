//
//  WeatherData.swift
//  Squadix
//
//  Created by Illia Romanenko on 19.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper


class WeatherData: Mappable {
    var data: [DailyWeather] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        data <- map["daily"]
    }
}

class DailyWeather: Mappable {
    var date: Date?
    var cloud: Float?
    var temp: Temp!
    var windSpeed: Float?
    var weather: [Weather] = []
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        date        <- (map["dt"], DateTransform())
        cloud       <- map["clouds"]
        temp        <- map["temp"]
        windSpeed   <- map["wind_speed"]
        weather     <- map["weather"]
    }
}

class Temp: Mappable {
    var minTemp: Float?
    var maxTemp: Float?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        minTemp    <- map["min"]
        maxTemp    <- map["max"]
    }
}

class Weather: Mappable {
    var weatherDescription: String!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init() {}
    
    func mapping(map: Map) {
        weatherDescription    <- map["description"]
    }
}
