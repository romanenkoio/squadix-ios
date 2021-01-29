//
//  NetwokrLayer.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/30/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum StrikeServise{
    case login(loginCredentials: ProfileRequest)
    case currency
    case registration(loginCredentials: ProfileRequest)
    case currentUser
    case posts(page: Int?)
    case userById(id: Int)
    case youtubeInfo(id: String)
    case createPost(post: Post)
    case deletePost(id: Int)
    case editPost(post: Post)
    case uploadAvatar(image: UIImage)
    case editProfile(profile: Profile)
    case createEvent(event: Event, images: [UIImage])
    case getUserPosts(id: Int, page: Int?)
    case events(page: Int?)
    case deleteEvent(id: Int)
    case activeProductsWithFilters(page: Int? = nil, filters: [Filter])
    case deleteProduct(id: Int)
    case saveProduct(product: MarketProduct,  images: [UIImage])
    case getProductByUser(id: Int, page: Int?)
    case getAllUsers
    case moderatingProducts(page: Int? = nil)
    case updateProductStatus(prodictID: Int, status: ProductStatus, reason: String? = nil)
    case toggleLike(postID: Int, type: NewsType)
    case getCategories
    case getPostById(id: Int)
    case getEventById(id: Int)
    case getProductById(id: Int)
    case createCategory(name: String)
    case getNotifications
    case deleteCategory(id: Int)
    case registerToken(pushToken: String)
    case deleteToken
    case upProduct(id: Int)
    case changePassword(oldPassword: String, newPassword: String)
}

extension StrikeServise: TargetType {
    var sampleData: Data {
        Data()
    }
    
    var baseURL: URL {
        switch self {
        case .currency:
            return URL(string: "https://www.nbrb.by")!
        case .youtubeInfo:
            return URL(string: "https://www.googleapis.com")!
        default:
            #if DEBUG
            return URL(string: "https://api.squadix.co")!
            #else
            return URL(string: "https://api.squadix.co")!
            #endif

        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/signin"
        case .registration:
            return "/users"
        case .currency:
            return "/api/exrates/rates/145"
        case .currentUser:
            return "/users/me"
        case .posts:
            return "/posts"
        case .userById(let id):
            return "/users/\(id)"
        case .youtubeInfo:
            return "/youtube/v3/videos"
        case .createPost:
            return "/posts"
        case .deletePost(let id):
            return "/posts/\(id)"
        case .editPost(let post):
            return "/posts/\(post.id)"
        case .uploadAvatar:
            return "/users/me/avatar"
        case .editProfile:
            return "/users/me"
        case .createEvent:
            return "/events"
        case .getUserPosts:
            return "/posts/"
        case .events:
            return "/events"
        case .deleteEvent(let id):
            return "/events/\(id)"
        case .activeProductsWithFilters:
            return "/products/filter"
//            return "/products/active"
        case .deleteProduct(let id):
            return "/products/\(id)"
        case .saveProduct:
            return "/products"
        case .getProductByUser:
            return "/products/"
        case .getAllUsers:
            return "/users"
        case .moderatingProducts:
            return "/products/moderating"
        case .updateProductStatus(let productID, _, _):
            return "/products/\(productID)/status"
        case .getCategories:
            return "/categories"
        case .toggleLike(let postID, let type):
            switch type {
            case .event:
                return "/events/\(postID)/like"
            case .feed:
                return "/posts/\(postID)/like"
            default:
                return "error"
            }
        case .getPostById(let id):
            return "/posts/\(id)"
        case .getEventById(let id):
            return "/events/\(id)"
        case .getProductById(let id):
            return "/products/\(id)"
        case .createCategory:
            return "/categories"
        case .registerToken:
            return "/devices"
        case .getNotifications:
            return "/notifications/me"
        case .deleteCategory(let id):
            return "/categories/\(id)"
        case .deleteToken:
            return "/devices"
        case .upProduct(let id):
            return "/products/\(id)/up"
        case .changePassword(_, _):
            return "/users/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .registration, .login, .createPost, .uploadAvatar, .createEvent, .saveProduct, .updateProductStatus, .createCategory, .registerToken:
            return .post
        case .deletePost, .deleteEvent, .deleteProduct, .deleteCategory:
            return .delete
        case .editPost, .editProfile, .toggleLike, .deleteToken:
            return .put
        case .upProduct, .changePassword:
            return .patch
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .uploadAvatar:
            return .uploadMultipart(multipartBody)
        default:
            guard let params = parameters else {
                return .requestPlain
            }
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login, .registration, .currency, .youtubeInfo:
            return nil
        default:
            return ["Authorization" : "Bearer " + (KeychainManager.accessToken ?? "")]
        }
    }
    
    var multipartBody: [Moya.MultipartFormData] {
        switch self {
        case .uploadAvatar(let image):
            guard let compImage = image.jpegData(compressionQuality: 0.5) else { return [] }
            let image = Moya.MultipartFormData(provider: MultipartFormData.FormDataProvider.data(compImage), name: "file", fileName: "photo.jpg", mimeType: "image/jpeg")
            return [image]
        default:
            return []
        }
    }
    
    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case  .activeProductsWithFilters(let page, let filters):
            if page != nil {
                params["page"] = page
            }
            if filters.count > 0 {
                params["categories"] = filters.asParams()
            }
        case  .moderatingProducts(let page):
            params["page"] = page
        case .events(let page), .posts(let page):
            params["page"] = page
        case .registration(let loginCredentials):
            params["email"] = loginCredentials.email
            params["displayName"] = loginCredentials.displayName
            params["password"] = loginCredentials.password
        case .login(let loginCredentials):
            params["password"] = loginCredentials.password
            params["email"] = loginCredentials.email
        case .youtubeInfo(let id):
            params["id"] = id
            params["key"] = AppConstatns.googleServicesKey
            params["fields"] = "items(snippet(title,description))"
            params["part"] = "snippet"
        case .createPost(let post), .editPost(let post):
            switch post.contentType {
            case .video:
                params = post.asVideoParams()
            case .image:
                params = post.asTextParams()
            case .none:
                return nil
            }
        case .editProfile(let profile):
            params = profile.asParams()
        case .getUserPosts(let id, let page), .getProductByUser(let id, let page):
            params["authorId"] = id
            params["page"] = page
        case .createEvent(let event, let images):
            params = event.asParams(with: images)
        case .saveProduct(let product, let images):
            params = product.asParams(with: images)
        case .updateProductStatus(_, let status, let reason):
            params["status"] = status.rawValue
            params["message"] = reason
        case .createCategory(let name):
            params["name"] = name
        case .registerToken(let pushToken):
            params["deviceToken"] = pushToken
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                params["deviceId"] = uuid
            }
            params["platform"] = "IOS"
        case .deleteToken:
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                params["deviceId"] = uuid
            }
        case .changePassword(let oldPassword, let newPassword):
            params["oldPassword"] = oldPassword
            params["newPassword"] = newPassword
        default:
            return nil
        }
        
        switch self {
        case .createEvent, .saveProduct:
            print("To large for print")
        default:
            print(params)
        }
        return params
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .youtubeInfo, .getUserPosts, .getProductByUser, .posts, .events, .activeProductsWithFilters, .moderatingProducts:
            return URLEncoding.queryString
        default:
            return JSONEncoding.prettyPrinted
        }
    }
    
    var validationType: ValidationType {
        switch self {
        default:
            return .successAndRedirectCodes
        }
    }
}
