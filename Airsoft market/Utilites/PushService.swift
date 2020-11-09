//
//  PushService.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/5/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

class PushService {
    private let service = NetworkManager()
    
    static let shared = PushService()

    private enum Push: String {
        case adminUpdate
        case productAprooved
        case producDeclined
        case systemInformation
    }
    
    func handlePush(event: String)  {
        switch event {
        case Push.adminUpdate.rawValue:
            print("Push handled")
        default:
            print("Push recived")
        }
    }
    
    
    
}
