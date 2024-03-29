//
//  NetworkManager.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/31/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

final class NetworkManager {
    let provider = MoyaProvider<StrikeServise>(plugins: [NetworkLoggerPlugin()])
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func register(loginCredentials: ProfileRequest, completion: @escaping (AuthResponce) -> Void, failure: @escaping (NetworkError) -> Void ) {
        provider.request(.registration(loginCredentials: loginCredentials)) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                if response.statusCode == 201 {
                    guard let authData = try? response.map(AuthResponce.self) else {
                        var customError = NetworkError()
                        customError.message = "Unknow"
                        failure(customError)
                        return
                    }
                    completion(authData)
                } else {
                    guard let error = try? response.mapObject(NetworkError.self) else {
                        var customError = NetworkError()
                        customError.message = "Unknow error"
                        failure(customError)
                        return
                    }
                    failure(error)
                }
               
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var customError = NetworkError()
                customError.message = error.errorDescription ?? "Unknow"
                failure(customError)
            }
        }
    }
    
    func login (loginCredentials: ProfileRequest, completion: @escaping (AuthResponce) -> Void, failure: @escaping (String) -> Void )  {
        provider.request(.login(loginCredentials: loginCredentials)) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let authData = try? response.map(AuthResponce.self) else {
                    failure("Unknown")
                    return
                }
                completion(authData)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure(error.errorDescription ?? "Unknown")
            }
        }
    }
    
    func loadPosts(page: Int, completion: @escaping (Posts?, NetworkError?) -> Void) {
        provider.request(.posts(page: page)) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let posts = try? response.mapObject(Posts.self) else { return }
                completion(posts, nil)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                completion(nil, nil)
            }
        }
    }
    
    func currency(completion: @escaping (Currency?, Error?) -> Void) {
        provider.request(.currency) { (result) in
            switch result {
            case let .success(response):
                guard let currency = try? response.mapObject(Currency.self) else { return }
                completion(currency, nil)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                completion(nil, error)
            }
        }
    }
    
    func getCurrentUser(completion: @escaping (Profile?, Error?, Int?) -> Void) {
        provider.request(.currentUser) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let profile = try? response.mapObject(Profile.self) else { return }
                completion(profile, nil, response.statusCode)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                completion(nil, error, nil)
            }
        }
    }
    
    func getUserById(id: Int, completion: @escaping (Profile?, Error?) -> Void) {
        provider.request(.userById(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let profile = try? response.mapObject(Profile.self) else { return }
                completion(profile, nil)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                completion(nil, error)
            }
        }
    }
    
    func getYoutubeInfo(id: String, completion: @escaping (YoutubeInfo?) -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.youtubeInfo(id: id)) { result in
            switch result {
            case let .success(response):
                print(response)
                guard let info = try? JSONDecoder().decode(YoutubeInfo.self, from: response.data) else {
                    return
                }
                completion(info)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure("Eror")
            }
        }
    }
    
    func postVideo(post: Post, completion: (() -> Void)? = nil, failure: ((String) -> Void)? = nil) {
        provider.request(.createPost(post: post)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard response.statusCode == 201 else  {
                    failure?("Eror")
                    return
                }
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?("Save post feilure")
            }
        }
    }
    
    func editPost(post: Post,_ completion: @escaping (() -> Void), _ failure: @escaping (String?) -> Void  ) {
        provider.request(.editPost(post: post)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure("Edit post feilure")
            }
        }
    }
    
    func deletePost(id: Int, completion: @escaping () -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.deletePost(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
                
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func editProfile(profile: Profile, completion: @escaping () -> Void, failure: ((String) -> Void)? = nil  ) {
        provider.request(.editProfile(profile: profile)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure?(err.message)
            }
        }
    }
    
    func updloadAvatar(image: UIImage, completion: @escaping () -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.uploadAvatar(image: image)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func getPostsByUser(page: Int? = nil, id: Int, completion: @escaping (Posts) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.getUserPosts(id: id, page: page)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                
                guard let posts = try? response.mapObject(Posts.self), let _ = posts.content else {
                    failure("Cannot load user posts")
                    return
                }
                ResponceHandler.handle(responce: response)
                completion(posts)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func getEvents(page: Int? = nil, completion: @escaping (Events) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.events(page: page)) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let events = try? response.mapObject(Events.self) else {
                    failure("Cannot load events feed")
                    return
                }
                completion(events)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure("Cannot load events feed")
            }
        }
    }
    
    func deleteEvent(id: Int, completion: @escaping () -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.deleteEvent(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func createEvent(event: Event, images: [UIImage], completion: @escaping () -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.createEvent(event: event, images: images)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func createProduct(product: MarketProduct, images: [UIImage], completion: @escaping () -> Void, failure: @escaping (String?) -> Void  ) {
        provider.request(.saveProduct(product: product, images: images)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    @discardableResult
    func getActiveProductsWithFilters(page: Int? = nil, completion: @escaping ([MarketProduct]) -> Void, failure: @escaping (String) -> Void  ) -> Cancellable? {
        provider.request(.activeProductsWithFilters(page: page, filters: RealmService.readFilters(onlyActive: true))) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let products = try? response.mapObject(Products.self) else { return }
                completion(products.content)
            case .failure( _):
                failure("Cannot load products feed")
            }
        }
    }
    
    func getModeratingProducts(page: Int? = nil, completion: @escaping (Products) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.moderatingProducts(page: page)) { (result) in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let products = try? response.mapObject(Products.self) else { return }
                completion(products)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure("Cannot load products feed")
            }
        }
    }
    
    func deleteProduct(id: Int, completion: @escaping () -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.deleteProduct(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func getProductsByUser(page: Int? = nil, id: Int, completion: @escaping ([MarketProduct]) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.getProductByUser(id: id, page: page)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let products = try? response.mapObject(Products.self), let content = products.content else {
                    failure("Cannot load user posts")
                    return
                }
                ResponceHandler.handle(responce: response)
                completion(content)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    @discardableResult
    func getAllUsers(page: Int? = nil, querry: String? = nil, completion: @escaping (ProfileContent) -> Void, failure: @escaping (String) -> Void  ) -> Cancellable? {
        provider.request(.getAllUsers(page: page, querry: querry)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let usersContent = try? response.mapObject(ProfileContent.self) else {
                    failure("Cannot load users")
                    return
                }
                completion(usersContent)
            case .failure(let error):
            print(error)
            }
        }
    }
    
    func updateProductStatus(productID: Int, status: ProductStatus, reason: String? = nil, completion: @escaping (Bool) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.updateProductStatus(prodictID: productID, status: status, reason: reason)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let _ = try? response.mapObject(MarketProduct.self) else {
                    failure("Cannot load user posts")
                    return
                }
                completion(true)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func toggleLike(postID: Int, type: NewsType, completion: ((Post) -> Void)? = nil, failure: ((String) -> Void)? = nil) -> Cancellable? {
        provider.request(.toggleLike(postID: postID, type: type)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let post = try? response.mapObject(Post.self) else {
                    failure?("Cannot load post")
                    return
                }
                completion?(post)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure?(err.message)
            }
        }
    }
    
    func getCategories(completion: (([ProductCategories]) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getCategories) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let categories = try? response.mapArray(ProductCategories.self) else {
                    failure?("Cannot load categories")
                    return
                }
                completion?(categories)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func getPostByID(postID: Int, completion: ((Post) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getPostById(id: postID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let post = try? response.mapObject(Post.self), response.statusCode != 500 else {
                    failure?("Cannot load news")
                    return
                }
                completion?(post)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func getEventByID(postID: Int, completion: ((Event) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getEventById(id: postID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let post = try? response.mapObject(Event.self) else {
                    failure?("Cannot load event")
                    return
                }
                completion?(post)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func getProductByID(postID: Int, completion: ((MarketProduct) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getProductById(id: postID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let product = try? response.mapObject(MarketProduct.self), response.statusCode != 500 else {
                    failure?("Cannot load product")
                    return
                }
                completion?(product)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func createCategory(with name: String, completion: ((String) -> Void)? = nil, failure: ((String) -> Void)? = nil) {
        provider.request(.createCategory(name: name)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?("\(response.statusCode)")
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func subscribeToNotification(pushToken: String, completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.registerToken(pushToken: pushToken)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func unsubscribeNotification(completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.deleteToken) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func getNotifications(completion: ((DashboardContent) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getNotifications) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let notifications = try? response.mapObject(DashboardContent.self), let _ = notifications.content else {
                    failure?("Cannot load notifications")
                    return
                }
                completion?(notifications)
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func deleteCategory(id: Int, completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.deleteCategory(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func upProduct(id: Int, completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.upProduct(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.changePassword(oldPassword: currentPassword, newPassword: newPassword)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func resetPassword(email: String,  completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.resetPassword(email: email)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func resetPasswordConfirmation(newPassword: String, token: String, completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.resetConfirmation(newPassword: newPassword, resetToken: token)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func deleteAvater(completion: (() -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.deleteAvatar) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    
    func markNotificationsAsRead(completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.markNotificationsAsRead) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?()
            }
        }
    }
    
    func blockUser(id: Int, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.blockUser(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?()
            }
        }
    }
    
    func unblockUser(id: Int, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.unblockUser(id: id)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                ResponceHandler.handleError(error: error)
                failure?()
            }
        }
    }
    
    func getComment(postType: NewsType, postID: Int, completion: (([Comment]) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.getComments(postType: postType, postID: postID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let comments = try? response.mapObject(CommentContent.self) else { return }
                completion?(comments.content)
            case .failure(_):
                failure?()
            }
        }
    }
    
    func postComment(postType: NewsType, postID: Int, text: String, images: [UIImage], completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.postComment(postType: postType, postID: postID, text: text, images: images)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
               
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func likeComment(postType: NewsType, commentID: Int, completion: ((Comment) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.likeComment(postType: postType, commentID: commentID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let comment = try? response.mapObject(Comment.self) else { return }
                completion?(comment)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func deleteComment(postType: NewsType, commentID: Int, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.deleteComment(postType: postType, commentID: commentID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func report(link: String, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.report(link: link)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func editProduct(product: MarketProduct, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.editProduct(product: product)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func getVersion(completion: ((Int) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.version) { result in
            switch result {
            case let .success(response):
                guard let version = try? response.mapObject(Version.self), let build = version.buildVersion  else {
                    failure?()
                    return
                }
                completion?(build)
            case .failure( _):
                failure?()
            }
        }
    }
    
    func createTeam(team: Team, completion: ((Team) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.createTeam(team: team)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let team = try? response.mapObject(Team.self) else { return }
                completion?(team)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func editTeam(team: Team, completion: ((Team) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.editTeam(team: team)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let team = try? response.mapObject(Team.self) else { return }
                completion?(team)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func getMyTeam(completion: (([Team]) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.getMyTeams) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let teams = try? response.mapObject(TeamObject.self) else { return }
                completion?(teams.content)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }

    func getTeamById(teamID: Int, completion: ((Team) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.getTeamById(teamID: teamID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let teams = try? response.mapObject(Team.self) else { return }
                completion?(teams)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func inviteToTeam(userID: Int, completion: VoidBlock?, failure: VoidBlock? = nil) {
        provider.request(.inviteToTeam(userID: userID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func uploadPhotoToTeam(teamID: Int, image: UIImage, completion: VoidBlock?, failure: VoidBlock? = nil) {
        provider.request(.addPhotoToTeam(image: image, teamID: teamID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    @discardableResult
    func getAllTeams(page: Int? = nil, querry: String? = nil, completion: ((TeamObject) -> Void)?, failure: (() -> Void)? = nil) -> Cancellable? {
        provider.request(.getAllTeams(page: page, querry: querry)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let teams = try? response.mapObject(TeamObject.self) else { return }
                completion?(teams)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func leaveTeam(completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.leaveTeam) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func inviteAction(isAccept: Bool, invitionId: Int, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(isAccept ? .acceptInvition(id: invitionId) : .declineInvition(id: invitionId)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func deleteNotification(notificationId: Int, completion: (() -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.deleteNotification(id: notificationId)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?()
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
    
    func getBlackList(completion: (([Profile]) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.getBlackList) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let users = try? response.mapArray(Profile.self) else { return }
                completion?(users)
            case .failure(let error):
                failure?()
                ResponceHandler.handleError(error: error)
            }
        }
    }
}
