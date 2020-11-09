//
//  DeepLinkRoutable.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

@objc protocol DeeplinkRoutable where Self: UIViewController {
    static func initControllerFromStoryboard() -> DeeplinkRoutable?
    static func canHandle(_ deeplink: Deeplink) -> Bool
    static func reuseExistingController(_ deeplink: Deeplink) -> Bool
    func handle(_ deeplink: Deeplink)
}
