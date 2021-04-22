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
}

extension UtilitesService: TargetType {
    var baseURL: URL {
        switch self {
        case .getAdress:
            return URL(string: "https://locationiq.com")!
        case .getWeather:
            return URL(string: "https://api.openweathermap.org")!
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAdress, .getWeather:
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
        }
        print(params)
        
        return params
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAdress, .getWeather:
            return nil
        default:
            return ["Authorization" : "Bearer " + (KeychainManager.accessToken ?? "")]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getAdress, .createNotification, .getWeather:
            return URLEncoding.queryString
        }
    }
}
