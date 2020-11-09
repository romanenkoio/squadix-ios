//
//  AppDelegate+DeepLinks.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            return handleUniversalLink(userActivity)
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handle(url: url)
    }
    
    @discardableResult
    func handleUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        var handled = false
        guard let url = userActivity.webpageURL else {
            print("Try to handle WebPage Activity, but the actual URL is nil")
            return handled
        }
        
        handled = handle(url: url)
        return handled
    }
    
    @discardableResult
    func handle(url: URL) -> Bool {
        var handled = false
        let urlDeeplink = Deeplink(url: url)
        if Deeplink.Handler.shared.canHandle(deepLink: urlDeeplink) {
            handled = true
            let completion: VoidBlock = {
                Deeplink.Handler.shared.handle(deeplink: urlDeeplink)
            }
            
            if KeychainManager.accessToken == nil {
              return false
            } else {
                completion()
            }
        } else if UIApplication.shared.canOpenURL(url) {
            print("DeepLink.Handler can't handle deeplink url: \(url.absoluteString). Redirect to Safari")
            UIApplication.shared.open(url, options: [:])
        }
        
        return handled
    }
}






