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
        
        var displayRoleName: String {
            switch self {
            case .admin:
                return "Администратор"
            case .moderator:
                return "Модератор"
            default:
                return ""
            }
        }
    }
    
    func role(role: String) -> Common.Roles {
        switch role {
        case "ADMIN":
            return .admin
        case "MODERATOR":
            return .moderator
        case "USER":
            return .user
        default:
            return .unknow
        }
    }
}

