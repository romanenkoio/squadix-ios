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
        let networkManager = NetworkManager()
        networkManager.subscribeToNotification(pushToken: token) {
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
//        Deeplink.Handler.shared.handle(deeplink: Deeplink(url: URL(string: "squadix.co/notifications")!))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Deeplink.Handler.shared.handle(deeplink: Deeplink(url: URL(string: "squadix.co/notifications")!))
    }
}
