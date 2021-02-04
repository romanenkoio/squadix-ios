//
//  VCFabric.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/22/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit

class VCFabric {
    static func loadTabBarItems() -> [UIViewController] {
        var controllers = [UIViewController]()
        
        let newsPage = NewsPage()
        newsPage.tabBarItem = UITabBarItem(title: "Лента", image: UIImage(named: "feed"), tag: 0)
        let newsNav = BaseNavigationController(rootViewController: newsPage)
        controllers.append(newsNav)
        
        let marketPage = MarketPage()
        marketPage.tabBarItem = UITabBarItem(title: "Барахолка", image: UIImage(named: "contact"), tag: 1)
        let marketNav = BaseNavigationController(rootViewController: marketPage)
        controllers.append(marketNav)
        
        let gameMapPage = GameMapPage()
        gameMapPage.tabBarItem = UITabBarItem(title: "Карта игр", image: UIImage(named: "map"), tag: 2)
        let gameMapNav = BaseNavigationController(rootViewController: gameMapPage)
        controllers.append(gameMapNav)
        
        let searchPage = SearchPage()
        searchPage.tabBarItem = UITabBarItem(title: "Люди", image: UIImage(named: "people_search"), tag: 3)
        let searchNav = BaseNavigationController(rootViewController: searchPage)
        controllers.append(searchNav)
        
        let profilePage = ProfilePage()
        profilePage.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "profile"), tag: 4)
        let profileNav = BaseNavigationController(rootViewController: profilePage)
        controllers.append(profileNav)
        
        return controllers
    }
    
    static func getNewsPage(type: NewsType, for id: Int? = nil) -> NewsPage {
        let vc = NewsPage.loadFromNib()
        vc.contentType = type
        vc.feedProfileID = id
        return vc
    }
    
    static func getMarketPage(for id: Int? = nil) -> MarketPage {
        let vc = MarketPage.loadFromNib()
        vc.profileID = id
        return vc
    }
    
    static func getProductPage(product: MarketProduct) -> ProductPage {
        let vc = ProductPage.loadFromNib()
        vc.product = product
        return vc
    }
    
    static func getAddProductPage(categories: [String], delegate: Updatable) -> AddProductPage {
        let vc = AddProductPage.loadFromNib()
        vc.delegate = delegate
        vc.categories = categories
        return vc
    }
    
    static func getProfilePage(for id: Int) -> ProfilePage {
        let vc = ProfilePage.loadFromNib()
        vc.profileID = id
        return vc
    }

    static func getNewsShowPage(post: Post) -> NewsShowPage {
        let vc = NewsShowPage.loadFromNib()
        vc.post = post
        return vc
    }

    static func getEventShowPage(event: Event, isPreview: Bool = false, images: [UIImage] = []) -> EventShowPage {
        let vc = EventShowPage.loadFromNib()
        vc.event = event
        vc.previewImages = images
        vc.isPreview = isPreview
        return vc
    }
    
    static func getMapPage(isEventCheck: Bool = false) -> MapPage {
        let vc = MapPage.loadFromNib()
        vc.isEventCheck = isEventCheck
        return vc
    }
    
    static func fullPicture(with url: String) -> FullPicturePage {
        let vc = FullPicturePage.loadFromNib()
        vc.url = url
        return vc
    }
    
    static func getNewPostPage(post: Post) -> AddPostPage {
        let vc = AddPostPage.loadFromNib()
        vc.post = post
        return vc
    }
    
    static func getUserEditPage(isEdit: Bool, profile: Profile? = nil) -> EditPage {
        let vc = EditPage.loadFromNib()
        vc.isEdit = isEdit
        vc.profile = profile
        return vc
    }
    
    static func getBookmarkPage(type: Common.CoordinatesType? = nil, delegate: UpdateEventDelegate? = nil) -> BookmarkPage {
        let vc = BookmarkPage.loadFromNib()
        vc.type = type
        if let sDelegate = delegate  {
            vc.delegate = sDelegate
        }
       
        return vc
    }
}
