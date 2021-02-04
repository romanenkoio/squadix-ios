//
//  Path.swift
//  Squadix
//
//  Created by Illia Romanenko on 29.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation

struct Path {
    static let baseUrl = "https://api.squadix.co/"
    static let youtube = "https://www.googleapis.com"
    static let nbrb = "https://www.nbrb.by"
    
    struct Users {
        static let path = "users"
        static let login = "signin"
        static let current = path + "/me"
        static let userByID = path + "/"
        static let uploadAvatar = current + "/avatar"
    }
    
    struct Posts {
        static let path = "posts"
        static let userPost = path + "/"
        static func tooglePostLike(_ postID: Int) -> String {
            return path + "/\(postID)/" + Like.path
        }
    }
    
    struct Events {
        static let path = "events"
        static let userEvent = path + "/"
        static func toogleEventLike(_ eventID: Int) -> String {
            return userEvent + "\(eventID)/" + Like.path
        }
    }
    
    struct Products {
        static let path = "products"
        static let filters = path + "/filter"
        static let moderating = path + "/moderating"
        static let status = "status"
        
        static func upProduct(_ productID: Int) -> String {
            return path + "/\(productID)/up"
        }
        static func updateStatus(_ productID: Int) -> String {
            return path + "/\(productID)/" + status
        }
    
    }
    
    struct Categories {
        static let path = "categories"
    }
    
    struct Additional {
        static let nbrb = "/api/exrates/rates/145"
        static let youtube = "/youtube/v3/videos"
    }
    
    struct Device {
        static let path = "devices"
    }
    
    struct Like {
        static let path = "like"
    }
    
    struct Notifications {
        static let path = "notifications"
        static let notifications = path + "/me"
    }
}