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
            case .failure:
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
            case .failure:
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
            case .failure:
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
            case .failure:
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
                
                guard let posts = try? response.mapObject(Posts.self) else {
                    failure("Cannot load user posts")
                    return
                }
                ResponceHandler.handle(responce: response)
                completion(posts)
            case .failure(let error):
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
                guard let events = try? response.map(Events.self) else {
                    failure("Cannot load events feed")
                    return
                }
                completion(events)
            case .failure:
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
            case .failure:
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
            case .failure:
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
                guard let products = try? response.mapObject(Products.self) else {
                    failure("Cannot load user posts")
                    return
                }
                ResponceHandler.handle(responce: response)
                completion(products.content)
            case .failure(let error):
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func getAllUsers(completion: @escaping ([Profile]) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.getAllUsers) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let users = try? response.mapArray(Profile.self) else {
                    failure("Cannot load user posts")
                    return
                }
                completion(users)
            case .failure(let error):
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure(err.message)
            }
        }
    }
    
    func updateProductStatus(productID: Int, status: ProductStatus, completion: @escaping (Bool) -> Void, failure: @escaping (String) -> Void  ) {
        provider.request(.updateProductStatus(prodictID: productID, status: status)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let _ = try? response.mapObject(MarketProduct.self) else {
                    failure("Cannot load user posts")
                    return
                }
                completion(true)
            case .failure(let error):
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
                var err = NetworkError()
                err.message = error.errorDescription ?? "Unknown"
                failure?(err.message)
            }
        }
    }
    
    func getCategories(completion: (([String]) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getCategories) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let categories = try? response.mapArray(ProductCategories.self) else {
                    failure?("Cannot load categories")
                    return
                }
                completion?(categories.map({$0.name}).sorted(by: {$0 > $1}))
            case .failure(let error):
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
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func getEventByID(postID: Int, completion: ((Event) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.getEventById(id: postID)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                guard let post = try? response.map(Event.self) else {
                    failure?("Cannot load event")
                    return
                }
                completion?(post)
            case .failure(let error):
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
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
    
    func createCategory(with name: String, completion: ((String) -> Void)?, failure: ((String) -> Void)? = nil) {
        provider.request(.createCategory(name: name)) { result in
            switch result {
            case let .success(response):
                ResponceHandler.handle(responce: response)
                completion?("\(response.statusCode)")
            case .failure(let error):
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
                failure?(error.errorDescription ?? "Unknow")
            }
        }
    }
}

