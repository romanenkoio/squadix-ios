//
//  KeychainManager.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 7/3/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainManager {
    
    private static var service: String = "com.airsoft.app"
    
    enum Keys: String, CaseIterable {
        case accessToken
        case refreshToken
        case profileID
        case pushToken
        case isAdmin
    }
    
    
    // MARK: - Accessors
    
    static func value(for key: Keys) -> Any? {
        if let data = try? Keychain(service: service).getData(key.rawValue) {
            let object = NSKeyedUnarchiver.unarchiveObject(with: data)
            return object
        }
        return nil
    }
    
    static func store(value: Any?, for key: Keys) {
        if value == nil {
            try? Keychain(service: service).remove(key.rawValue)
        } else {
            guard let value = value else { return }
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            try? Keychain(service: service).set(data, key: key.rawValue)
        }
    }
    
    // MARK: - Tokens
    
    static var accessToken: String? {
        get {
            return value(for: .accessToken) as? String ?? nil
            
        }
    }
    
    static var isAdmin: Bool {
        get {
            return value(for: .isAdmin) as? Bool ?? false
        }
    }
    
    static var refreshToken: String? {
        get {
            return value(for: .refreshToken) as? String ?? nil
        }
    }
    
    static var profileID: Int? {
        get {
            return value(for: .profileID) as? Int ?? nil
        }
    }
    
    static var pushToken: String? {
        get {
            return value(for: .pushToken) as? String ?? nil
        }
    }
    
    static func clearTokens() {
        clearAccessToken()
        clearRefreshToken()
    }
    
    static func clearAccessToken() {
        store(value: nil, for: .accessToken)
    }
    
    static func clearPushToken() {
        store(value: nil, for: .pushToken)
    }
    
    static func clearRefreshToken() {
        store(value: nil, for: .refreshToken)
    }
    
    static func clearpPofile() {
        store(value: nil, for: .profileID)
    }
    
    static func clearAll() {
        Keys.allCases.forEach {
            store(value: nil, for: $0)
        }
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
