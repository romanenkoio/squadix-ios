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
    case getAllUsers(page: Int?, querry: String?)
    case moderatingProducts(page: Int?)
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
    case resetPassword(email: String)
    case resetConfirmation(newPassword: String, resetToken: String)
    case deleteAvatar
    case markNotificationsAsRead
    case blockUser(id: Int)
    case unblockUser(id: Int)
    case getComments(postType: NewsType, postID: Int)
    case postComment(postType: NewsType, postID: Int, text: String, images: [UIImage])
    case likeComment(postType: NewsType, commentID: Int)
    case deleteComment(postType: NewsType, commentID: Int)
    case report(link: String)
    case editProduct(product: MarketProduct)
    case version
    case createTeam(team: Team)
    case editTeam(team: Team)
    case getMyTeams
    case getTeamById(teamID: Int)
    case inviteToTeam(userID: Int)
    case addPhotoToTeam(image: UIImage, teamID: Int)
    case getAllTeams(page: Int?, querry: String?)
    case leaveTeam
    case deleteNotification(id: Int)
    case acceptInvition(id: Int)
    case declineInvition(id: Int)
    case getBlackList
}

extension StrikeServise: TargetType {
    var sampleData: Data {
        Data()
    }
    
    var baseURL: URL {
        switch self {
        case .currency:
            return URL(string: Path.nbrb)!
        case .youtubeInfo:
            return URL(string: Path.youtube)!
        default:
            #if DEBUG
            return URL(string: Path.baseDevUrl)!
            #else
            return URL(string: Path.baseUrl)!
            #endif
        }
    }
    
    var path: String {
        switch self {
        case .blockUser, .unblockUser, .getBlackList:
            return Path.Users.block
        case .login:
            return Path.Users.login
        case .registration:
            return Path.Users.path
        case .currency:
            return Path.Additional.nbrb
        case .currentUser:
            return Path.Users.current
        case .posts:
            return Path.Posts.path
        case .userById(let id):
            return Path.Users.path + "/\(id)"
        case .youtubeInfo:
            return Path.Additional.youtube
        case .createPost:
            return Path.Posts.path
        case .deletePost(let id):
            return Path.Posts.path + "/\(id)"
        case .editPost(let post):
            return Path.Posts.path + "/\(post.id)"
        case .uploadAvatar:
            return Path.Users.uploadAvatar
        case .editProfile:
            return Path.Users.current
        case .createEvent:
            return Path.Events.path
        case .getUserPosts:
            return Path.Posts.userPost
        case .events:
            return Path.Events.path
        case .deleteEvent(let id):
            return Path.Events.path + "/\(id)"
        case .activeProductsWithFilters:
            return Path.Products.filters
        case .deleteProduct(let id):
            return Path.Products.path + "/\(id)"
        case .saveProduct(let product, _):
            return product.promoUrl == nil ? Path.Products.path : Path.Products.promoPath
        case .getProductByUser:
            return Path.Products.path + "/"
        case .getAllUsers:
            return Path.Users.path
        case .moderatingProducts:
            return Path.Products.moderating
        case .updateProductStatus(let productID, _, _):
            return Path.Products.updateStatus(productID)
        case .getCategories:
            return Path.Categories.path
        case .toggleLike(let postID, let type):
            switch type {
            case .event:
                return Path.Events.toogleEventLike(postID)
            case .feed:
                return Path.Posts.tooglePostLike(postID)
            default:
                return "error"
            }
        case .getPostById(let id):
            return Path.Posts.path + "/\(id)"
        case .getEventById(let id):
            return Path.Events.path + "/\(id)"
        case .getProductById(let id):
            return Path.Products.path + "/\(id)"
        case .createCategory:
            return Path.Categories.path
        case .registerToken:
            return Path.Device.path
        case .getNotifications, .markNotificationsAsRead:
            return Path.Notifications.notifications
        case .deleteCategory(let id):
            return Path.Categories.path + "/\(id)"
        case .deleteToken:
            return Path.Device.path
        case .upProduct(let id):
            return Path.Products.upProduct(id)
        case .changePassword(_, _):
            return Path.Users.current
        case .resetPassword:
            return Path.Users.resetPassword
        case .resetConfirmation:
            return Path.Users.resetPasswordConfirmation
        case .deleteAvatar:
            return Path.Users.deleteAvatar
        case .getComments(let postType, let postID), .postComment(let postType, let postID, _, _):
            return Path.Comments.comments(postType: postType, postID: postID)
        case .likeComment(let postType, let commentID):
            return Path.Comments.likeComment(postType: postType, commentID: commentID)
        case .deleteComment(let postType, let commentID):
            return Path.Comments.deleteComment(postType: postType, commentID: commentID)
        case .report:
            return Path.Report.path
        case .editProduct(let product):
            return Path.Products.path + "/\(product.postID)"
        case .version:
            return Path.Version.actual
        case .createTeam:
            return Path.Team.path
        case .getMyTeams:
            return Path.Team.myTeams
        case .getTeamById(let teamID):
            return Path.Team.findByID(teamID)
        case .editTeam(let team):
            return Path.Team.findByID(team.id)
        case .inviteToTeam:
            return Path.Invation.path
        case .addPhotoToTeam( _, let teamID):
            return Path.Team.uploadTeamGallery(teamID)
        case .getAllTeams:
            return Path.Team.path
        case .leaveTeam:
            return Path.Team.leaveTeam
        case .deleteNotification(let id):
            return Path.Notifications.delete(id: id)
        case .acceptInvition(let id), .declineInvition(let id):
            return Path.Invation.invitionAction(id: id)
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .registration, .login, .createPost, .uploadAvatar, .createEvent, .saveProduct, .updateProductStatus, .createCategory, .registerToken, .resetPassword, .resetConfirmation, .blockUser, .postComment, .report, .createTeam, .inviteToTeam, .addPhotoToTeam, .leaveTeam:
            return .post
        case .deletePost, .deleteEvent, .deleteProduct, .deleteCategory, .deleteAvatar, .unblockUser, .deleteComment, .deleteNotification, .declineInvition:
            return .delete
        case .editPost, .editProfile, .toggleLike, .deleteToken, .markNotificationsAsRead, .likeComment, .editProduct, .acceptInvition, .editTeam:
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
        case .login, .registration, .currency, .youtubeInfo, .resetPassword, .resetConfirmation:
            return nil
        default:
            return ["Authorization" : "Bearer " + (KeychainManager.accessToken ?? "")]
        }
    }
    
    var multipartBody: [Moya.MultipartFormData] {
        switch self {
        case .uploadAvatar(let image):
            guard let compImage = image.jpegData(compressionQuality: 1) else { return [] }
            let image = Moya.MultipartFormData(provider: MultipartFormData.FormDataProvider.data(compImage), name: "file", fileName: "photo.jpg", mimeType: "image/jpeg")
            return [image]
        default:
            return []
        }
    }
    
    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .addPhotoToTeam(let image, _):
            var imagedata: [String] = []
            if let im = image.toBase64() {
                imagedata.append(im)
                params["images"] = imagedata
            }
        case .inviteToTeam(let userID):
            params["userId"] = userID
        case .createTeam(let team):
            params = team.asParams()
        case .editTeam(let team):
            params = team.asParams()
        case  .activeProductsWithFilters(let page, let filters):
            if page != nil {
                params["page"] = page
            }
            if filters.count > 0 {
                params["categories"] = filters.asParams()
            }
            switch Common.Sorting.reverse(raw: UsersData.shared.savedSorting) {
            case .priceASC:
                params["sortField"] = "price"
                params["sortDir"] = "ASC"
            case .priceDESC:
                params["sortField"] = "price"
                params["sortDir"] = "DESC"
            case .standart:
                params["sortField"] = "upTime"
                params["sortDir"] = "DESC"
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
        case .resetPassword(let email):
            params["email"] = email
        case .resetConfirmation(let newPassword, let resetToken):
            params["newPassword"] = newPassword
            params["resetPasswordToken"] = resetToken
        case .blockUser(let id), .unblockUser(let id):
            params["id"] = id
        case .postComment(_, _, let text, let images):
            params["text"] = text
            if images.count > 0 {
                var sendData: [String] = []
                for image in images {
                    if let codedImage = image.toBase64() {
                        sendData.append(codedImage)
                    }
                }
                params["imageUrls"] = sendData
            }
        case .report(let link):
            params["url"] = link
        case .editProduct(let product):
            params = product.asParams(isEdit: true, with: [])
        case .getAllUsers(let page, let querry), .getAllTeams(let page, let querry):
            params["page"] = page
            params["name"] = querry
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
        case .youtubeInfo, .getUserPosts, .getProductByUser, .posts, .events, .activeProductsWithFilters, .moderatingProducts, .getAllUsers, .getTeamById, .getAllTeams:
            return URLEncoding.queryString
        default:
            return JSONEncoding.prettyPrinted
        }
    }
    
    var validationType: ValidationType {
        switch self {
        case .registration, .getComments:
            return .none
        default:
            return .successAndRedirectCodes
        }
    }
}
