//
//  Path.swift
//  Squadix
//
//  Created by Illia Romanenko on 29.01.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation

struct Path {
    static let baseUrl = "https://prod.squadix.co/"
    static let baseDevUrl = "https://api.squadix.co/"
    static let youtube = "https://www.googleapis.com"
    static let nbrb = "https://www.nbrb.by"
    
    struct Users {
        static let path = "users"
        static let login = "signin"
        static let current = path + "/me"
        static let userByID = path + "/"
        static let uploadAvatar = current + "/avatar"
        static let resetPassword = "reset"
        static let resetPasswordConfirmation = "reset-confirmation"
        static let deleteAvatar = current + "/avatar"
        static let block = current + "/ignore"
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
        static let promoPath = "promo-products"
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
    
    struct Comments {
        static func comments(postType: NewsType, postID: Int) -> String {
            switch postType {
            case .event:
                return Path.Events.path + "/\(postID)/comments"
            case .feed:
                return Path.Posts.path + "/\(postID)/comments"
            default:
                return ""
            }
        }
        
        static func likeComment(postType: NewsType, commentID: Int) -> String {
            switch postType {
            case .event:
                return Path.Events.path + "/comments/\(commentID)/like"
            case .feed:
                return Path.Posts.path + "/comments/\(commentID)/like"
            default:
                return ""
            }
        }
        
        static func deleteComment(postType: NewsType, commentID: Int) -> String {
            switch postType {
            case .event:
                return Path.Events.path + "/comments/\(commentID)"
            case .feed:
                return Path.Posts.path + "/comments/\(commentID)"
            default:
                return ""
            }
        }
        
    
    }
    
    struct Additional {
        static let nbrb = "/api/exrates/rates/145"
        static let youtube = "/youtube/v3/videos"
    }
    
    struct Report {
        static let path = "reports/"
    }
    struct Device {
        static let path = "devices"
    }
    
    struct Like {
        static let path = "like"
    }
    
    struct Version {
        static let path = "versions"
        static let actual = Version.path + "/recent"
    }
    
    struct Notifications {
        static let path = "notifications"
        static let notifications = path + "/me"
    }
    
    struct Team {
        static let path = "teams"
        static let myTeams = path + "/my"
        
        static func findByID(_ teamID: Int) -> String {
            return path + "/\(teamID)/"
        }
        
        static func uploadTeamAvatar(_ teamID: Int) -> String {
            return path + "/\(teamID)/images"
        }
    }
    
    struct Invation {
        static let path = "invitations"
    }
}
