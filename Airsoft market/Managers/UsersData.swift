//
//  DefaultsManager.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/31/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

final class UsersData {    
    static let shared: UsersData = {
        return UsersData()
    }()
    
    var isUSDCurrencyEnabled: Bool {
        get {
            let isEnabled = UserDefaults.standard.value(forKey: #function) as? Bool
            return isEnabled ?? false
        }
        set {
            if !isUSDCurrencyEnabled {
                let networkManager = NetworkManager()
                networkManager.currency { [weak self] (result, error) in
                    if let error = error {
                        print(error)
                    } else if let currency = result {
                        if let usdCurrency = currency.rate {
                            UserDefaults.standard.setValue(newValue, forKey: #function)
                            self?.currency = usdCurrency
                        } else {
                            self?.isUSDCurrencyEnabled = false
                        }
                    }
                }
            } else {
                UserDefaults.standard.setValue(newValue, forKey: #function)
            }
        }
    }
    
    var currency: Double {
        get {
            let currency = UserDefaults.standard.value(forKey: #function) as? Double
            return currency ?? 0
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }

    
    var useBiometric: Bool {
        get {
            let isEnabled = UserDefaults.standard.value(forKey: #function) as? Bool
            return isEnabled ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    var informNevVersion: Bool {
        get {
            let isEnabled = UserDefaults.standard.value(forKey: #function) as? Bool
            return isEnabled ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    var quality: Float {
        get {
            let savedQuality = UserDefaults.standard.value(forKey: #function) as? Float
            return savedQuality ?? Common.ImageQuality.normal.rawValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
    
    var savedSorting: String {
        get {
            let savedSorting = UserDefaults.standard.value(forKey: #function) as? String
            return savedSorting ?? Common.Sorting.upDate.rawValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
}
