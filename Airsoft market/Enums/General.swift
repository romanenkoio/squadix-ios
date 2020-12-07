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
        case organizer
        case unknow
        
        var displayRoleName: String {
            switch self {
            case .admin:
                return "Администратор"
            case .moderator:
                return "Модератор"
            case .organizer:
                return "Организатор"
            default:
                return ""
            }
        }
    }
    
    enum NotificationType: String {
        case like
        case aprooved
        case decline
        case system
        case none
    }
    
    func notificationType(type: String) -> Common.NotificationType {
        switch type {
        case "LIKE":
            return .like
        case "APROOVED":
            return .aprooved
        case "DECLINE":
            return .decline
        case "SYSTEM":
            return .system
        default:
            return .none
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
        case "ORGANIZER":
            return .organizer
        default:
            return .unknow
        }
    }
}

