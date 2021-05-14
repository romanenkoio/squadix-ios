//
//  UtilitesAPI.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/17/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Moya

enum UtilitesService {
    case getAdress(lat: Double, long: Double)
    case createNotification(message: String, url: String)
    case getWeather(lat: Double, long: Double)
    case getCityList(prefix: String?)
}

extension UtilitesService: TargetType {
    var baseURL: URL {
        switch self {
        case .getAdress:
            return URL(string: "https://locationiq.com")!
        case .getWeather:
            return URL(string: "https://api.openweathermap.org")!
        case .getCityList:
//            https://rapidapi.com/wirefreethought/api/geodb-cities/pricing
            return URL(string: "https://wft-geo-db.p.rapidapi.com")!
        default:
            #if DEBUG
            return URL(string: "https://18.158.147.66")!
            #else
            return URL(string: "https://18.158.147.66")!
            #endif
        }
    }
    
    var path: String {
        switch self {
        case .getAdress:
            return "/v1/reverse.php"
        case .createNotification:
            return "/notifications/"
        case .getWeather:
            return "/data/2.5/onecall"
        case .getCityList:
            return "/v1/geo/cities"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAdress, .getWeather, .getCityList:
            return .get
        case .createNotification:
            return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        default:
            guard let params = parameters else {
                return .requestPlain
            }
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        }
    }
    
    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .getAdress(let lat, let long):
            params["key"] = AppConstatns.geocodingApiKey
            params["lat"] = lat
            params["lon"] = long
            params["format"] = "json"
            params["addressdetails"] = 1
            params["accept_language"] = "ru"
        case .createNotification(let message, let url):
            params["message"] = message
            params["url"] = url
        case .getWeather(let lat, let long):
            params["appid"] = AppConstatns.weatherKey
            params["lat"] = lat
            params["lon"] = long
            params["exclude"] = "minutely,hourly,alerts,current"
            params["lang"] = "ru"
            params["units"] = "metric"
        case .getCityList(let prefix):
            params["countryIds"] = "BY"
            params["languageCode"] = "RU"
            if prefix != nil && !(prefix?.isEmpty ?? false) {
                params["namePrefix"] = prefix
            }
            params["limit"] = 10
            params["types"] = "CITY"
            params["sort"] = "name"
            params["minPopulation"] = 100
        }
        print(params)
        
        return params
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAdress, .getWeather:
            return nil
        case .getCityList:
            var headers: [String: String] = [:]
            headers["x-rapidapi-key"] = "ac1d352f36mshf8f3c5ada27e7c4p1ab2c5jsn402ce21901b1"
            headers["x-rapidapi-host"] = "wft-geo-db.p.rapidapi.com"
            return headers
        default:
            return ["Authorization" : "Bearer " + (KeychainManager.accessToken ?? "")]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.queryString
        }
    }
}
