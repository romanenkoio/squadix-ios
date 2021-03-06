//
//  AppDelegate.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/21/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import UIKit
import GoogleMaps
import IQKeyboardManagerSwift
import LocalAuthentication
import UserNotifications
import Sentry
import Firebase
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var currentViewController: UIViewController? {
        return findTopController()
    }
    
    var mainTabBar: BaseTabBarViewController? {
        return currentViewController?.tabBarController as? BaseTabBarViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        KeychainManager.accessToken == nil ? showLogin() : showMainMenu()
        setupServices()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    func showLogin() {
        window?.rootViewController = BaseNavigationController(rootViewController: LoginPage.loadFromNib())
    }
    
    func logout() {
        showLogin()
        KeychainManager.clearAll()
    }
    
    func showMainMenu() {
        registerForPushNotifications()
        window?.rootViewController  = BaseTabBarViewController()
        
        if UsersData.shared.isUSDCurrencyEnabled {
            NetworkManager.shared.currency { (result, error) in
                
                if let error = error {
                    print(error)
                } else if let currency = result {
                    if let usdCurrency = currency.rate {
                        UsersData.shared.currency = usdCurrency
                    }
                }
            }
        }
        
        NetworkManager.shared.getCurrentUser { [weak self] (profile, _, status) in
            if status != 200, status != nil {
                self?.logout()
            }
        }
    }
    
    func setupServices() {
        NetworkMonitor.shared.startListner()
        GMSServices.provideAPIKey(AppConstatns.googleServicesKey)
        IQKeyboardManager.shared.enable = true
        SentrySDK.start { options in
            options.dsn = "https://be2b52d8a54a43db975e7a690059a819@o484042.ingest.sentry.io/5536840"
            options.debug = false
        }
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        FirebaseApp.configure()
        ImageCache.default.memoryStorage.config.totalCostLimit = 1
        ImageCache.default.diskStorage.config.sizeLimit = 100 * 1024 * 1024
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }
    
    private func findTopController(from _vc: UIViewController? = nil) -> UIViewController? {
        var vc: UIViewController! = _vc ?? window?.rootViewController
        if let navigationController = vc as? UINavigationController {
            vc = navigationController.visibleViewController
            if vc is UIAlertController {
                vc = navigationController.topViewController
            }
        }
        if let tabBarController = vc as? UITabBarController {
            vc = tabBarController.selectedViewController
            if let navigationController = vc as? UINavigationController {
                vc = navigationController.visibleViewController
                if vc is UIAlertController {
                    vc = navigationController.topViewController
                }
            }
        }
    
        if vc == nil {
            vc = window?.rootViewController?.presentedViewController
        }
        
        return vc
    }
}


