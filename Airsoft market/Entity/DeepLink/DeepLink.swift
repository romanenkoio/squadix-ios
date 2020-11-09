//
//  DeepLink.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

class Deeplink: NSObject {
    var url: URL?
    
    var prefferedPresentationStyle: PresentationStyle?
    var reuseController: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(url: URL) {
        self.init()
        self.url = url
    }
    
    enum PresentationStyle {
        case modal
        case push
        case tabBar
        case updateCurrent
    }

    enum Source {
        case tabBar
        case navigationBar
        case storyboard
    }


    enum DeeplinkType {
        case post
        case product
        case event
        case unknow
        
        static func checkLinkType(url: URL) -> DeeplinkType {
            if url.path.contains("/products/") {
                return .product
            }
            if url.path.contains("/events/") {
                return .event
            }
            if url.path.contains("/news/") {
                return .post
            }
            return unknow
        }
    }
}



