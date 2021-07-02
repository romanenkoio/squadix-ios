//
//  AppDelegate+Notifications.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/31/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//


import Foundation
import UIKit
import UserNotifications

extension AppDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        KeychainManager.store(value: token, for: .pushToken)
        NetworkManager.shared.subscribeToNotification(pushToken: token) {
            print("[PUSH] Subscribed")
        } failure: { error in
            print("[PUSH] Subscribed error. Reason: \(error)")
        }

    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        KeychainManager.clearPushToken()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? BaseTabBarViewController, let nav = tabBar.viewControllers?[0] as? UINavigationController, let tab = nav.viewControllers.first as? NewsPage  {
            NetworkManager.shared.getNotifications { notification in
                let count = notification.content.filter({$0.isReaded == false}).count
                tab.dashboardButton.badgeValue = "\(count)"
                UIApplication.shared.applicationIconBadgeNumber = count
            }
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Deeplink.Handler.shared.handle(deeplink: Deeplink(url: URL(string: "squadix.co/notifications")!))
    }
}
