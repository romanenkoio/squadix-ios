//
//  CacheManager.swift
//  Squadix
//
//  Created by Illia Romanenko on 26.02.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation
import Kingfisher

final class CacheManager {
    static let shared = CacheManager()
    private init() {}
    
    func cleanCache() {
//        KingfisherManager.shared.cache.clearMemoryCache()
//        KingfisherManager.shared.cache.clearDiskCache()
//        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }
}
