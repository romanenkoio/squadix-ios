//
//  General.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/9/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

class Common {
    static let shared = Common()
    
    enum CoordinatesType {
        case startCoordinate
        case gameCoordinate
    }
    
    enum Roles: String {
        case admin
        case moderator
        case user
        case unknow
    }
    
    func role(role: String) -> Common.Roles {
        switch role {
        case "admin":
            return .admin
        case "moderator":
            return .moderator
        case "user":
            return .user
        default:
            return .unknow
        }
    }
}

