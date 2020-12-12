//
//  UtilitesManager.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/17/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import Moya_ObjectMapper

final class UtilitesManager {
    let provider = MoyaProvider<UtilitesService>(plugins: [NetworkLoggerPlugin()])
    
    func getAdress(lat: Double, long: Double, completion: @escaping (GeocodingAddress) -> Void, failure: ((String?) -> Void)? = nil) {
        provider.request(.getAdress(lat: lat, long: long)) { result in
            switch result {
            case let .success(response):
                guard let address = try? response.mapObject(GeocodingAddress.self) else {
                    failure?("Cannot parse address responce")
                    return
                }
                ResponceHandler.handle(responce: response)
                completion(address)
            case .failure(let error):
                failure?(error.errorDescription)
            }
        }
    }
    
    func sendNotifications(message: String, url: String, completion: @escaping VoidBlock, failure: ((String?) -> Void)? = nil) {
        provider.request(.createNotification(message: message, url: url)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                failure?(error.errorDescription)
            }
        }
    }
}
