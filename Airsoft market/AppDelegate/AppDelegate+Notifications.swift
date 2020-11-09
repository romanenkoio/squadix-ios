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

    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        KeychainManager.clearPushToken()
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        let push = Push(with: userInfo)
        
        // Doesn't use because bagde counter is updated by SSE handler
        // setDashboardBadge(push)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        let deeplink = Deeplink(push: Push(with: userInfo))
      
//            Deeplink.Handler.shared.handle(deeplink: deeplink)
        
    }
}
