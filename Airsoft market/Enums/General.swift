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
    
    enum ImageQuality: Float {
        case high = 1.0
        case normal = 0.75
        case medium = 0.5
        case low = 0.25
        
        var settingName: String {
            switch self {
            case .high:
                return "Высокое"
            case .low:
                return "Низкое"
            case .normal:
                return "Нормальное"
            case .medium:
                return "Среднее"
            }
        }

    }
    
    enum Roles: String {
        case admin
        case moderator
        case user
        case organizer
        case partner
        case unknow
        
        var displayRoleName: String {
            switch self {
            case .admin:
                return "Администратор"
            case .moderator:
                return "Модератор"
            case .organizer:
                return "Организатор"
            case .partner:
                return "Партнёр"
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
        case report
        case none
        case comment
        case invite
    }
    
    func notificationType(type: String) -> Common.NotificationType {
        switch type {
        case "LIKE":
            return .like
        case "APPROVE":
            return .aprooved
        case "DECLINE":
            return .decline
        case "SYSTEM":
            return .system
        case "REPORT":
            return .report
        case "COMMENT":
            return .comment
        case "INVITE":
            return .invite
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
        case "PARTNER":
            return .partner
        default:
            return .unknow
        }
    }
    
    enum Sorting: String {
        case standart = "По дате апа"
        case priceASC = "Начать с дешевых"
        case priceDESC = "Начать с дорогих"
        
        var sortingKey: String {
            switch self {
            case .standart:
                return "DEFAULT"
            case .priceASC:
                return "PRICE_ASC"
            case .priceDESC:
                return "PRICE_DESC"
            }
        }
        
        static func getSorting() -> [Sorting] {
            return [.standart, .priceASC, .priceDESC]
        }
        
        static func reverse(raw: String) -> Sorting {
            if raw == "По дате апа" {
                return .standart
            } else if raw == "Начать с дешевых" {
                return .priceASC
            } else if raw == "Начать с дорогих" {
                return .priceDESC
            }
            return .standart
        }
    }
}

