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
        searchPage.tabBarItem = UITabBarItem(title: "Поиск", image: UIImage(named: "search"), tag: 3)
        let searchNav = BaseNavigationController(rootViewController: searchPage)
        controllers.append(searchNav)
        
        let profilePage = ProfilePage()
        profilePage.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "profile"), tag: 4)
        let profileNav = BaseNavigationController(rootViewController: profilePage)
        controllers.append(profileNav)
        
        return controllers
    }
    
    static func getRegistrationPage() -> RegistrationPage {
        return RegistrationPage(nibName: String(describing: RegistrationPage.self), bundle: nil)
    }
    
    static func getLoginPage() -> LoginPage {
        return LoginPage(nibName: String(describing: LoginPage.self), bundle: nil)
    }
    
    static func getNewsPage(type: NewsType, for id: Int? = nil) -> NewsPage {
        let vc = NewsPage(nibName: String(describing: NewsPage.self), bundle: nil)
        vc.contentType = type
        vc.feedProfileID = id
        return vc
    }
    
    static func getMarketPage(for id: Int? = nil) -> MarketPage {
        let vc = MarketPage(nibName: String(describing: MarketPage.self), bundle: nil)
        vc.profileID = id
        return vc
    }
    
    static func getProductPage(product: MarketProduct) -> ProductPage {
        let vc = ProductPage(nibName: String(describing: ProductPage.self), bundle: nil)
        vc.product = product
        return vc
    }
    
    static func getAddProductPage(categories: [String]) -> AddProductPage {
        let vc = AddProductPage(nibName: String(describing: AddProductPage.self), bundle: nil)
        vc.categories = categories
        return vc
    }
    
    static func getProfilePage() -> ProfilePage {
        return ProfilePage(nibName: String(describing: ProfilePage.self), bundle: nil)
    }
    
    static func getProfilePage(for id: Int) -> ProfilePage {
        let vc = ProfilePage(nibName: String(describing: ProfilePage.self), bundle: nil)
        vc.profileID = id
        return vc
    }

    static func getNewsShowPage(post: Post) -> NewsShowPage {
        let vc = NewsShowPage(nibName: String(describing: NewsShowPage.self), bundle: nil)
        vc.post = post
        return vc
    }

    static func getEventShowPage(event: Event, isPreview: Bool = false, images: [UIImage] = []) -> EventShowPage {
        let vc = EventShowPage(nibName: String(describing: EventShowPage.self), bundle: nil)
        vc.event = event
        vc.previewImages = images
        vc.isPreview = isPreview
        return vc
    }
    
    static func getMapPage(isEventCheck: Bool = false) -> MapPage {
        let vc = MapPage(nibName: String(describing: MapPage.self), bundle: nil)
        vc.isEventCheck = isEventCheck
        return vc
    }
    
    static func getFilterPage() -> FilterPage {
        return FilterPage(nibName: String(describing: FilterPage.self), bundle: nil)
    }
    
    static func getSettingsPage() -> SettingsPage {
        return SettingsPage(nibName: String(describing: SettingsPage.self), bundle: nil)
    }
    
    static func getPicturePage() -> SelectPickPage {
        return SelectPickPage(nibName: String(describing: SelectPickPage.self), bundle: nil)
    }
    
    static func getDebugPage() -> DebugPage {
        return DebugPage(nibName: String(describing: DebugPage.self), bundle: nil)
    }
    
    static func fullPicture(with url: String) -> FullPicturePage {
        let vc = FullPicturePage(nibName: String(describing: FullPicturePage.self), bundle: nil)
        vc.url = url
        return vc
    }
    
    static func getNewPostPage() -> AddPostPage {
        return AddPostPage(nibName: String(describing: AddPostPage.self), bundle: nil)
    }
    
    static func getNewPostPage(post: Post) -> AddPostPage {
        let vc = AddPostPage(nibName: String(describing: AddPostPage.self), bundle: nil)
        vc.post = post
        return vc
    }
    
    static func getUserEditPage(isEdit: Bool, profile: Profile? = nil) -> EditPage {
        let vc = EditPage(nibName: String(describing: EditPage.self), bundle: nil)
        vc.isEdit = isEdit
        vc.profile = profile
        return vc
    }
    
    static func addEventPage() -> AddEventPage {
        return AddEventPage(nibName: String(describing: AddEventPage.self), bundle: nil)
    }
    
    static func adminPage() -> AdminPage {
        return AdminPage(nibName: String(describing: AdminPage.self), bundle: nil)
    }
    
    static func addTextPostPage() -> AddTextPostPage {
         return AddTextPostPage(nibName: String(describing: AddTextPostPage.self), bundle: nil)
    }
    
    static func imagePreview() -> ImagePreviewPage {
        return ImagePreviewPage(nibName: String(describing: ImagePreviewPage.self), bundle: nil)
    }
    
    static func getBookmarkPage(type: Common.CoordinatesType? = nil, delegate: UpdateEventDelegate? = nil) -> BookmarkPage {
        let vc = BookmarkPage(nibName: String(describing: BookmarkPage.self), bundle: nil)
        vc.type = type
        if let sDelegate = delegate  {
            vc.delegate = sDelegate
        }
       
        return vc
    }
}
