//
//  ContactHandler.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import UIKit

enum Methods: String {
    case tg
    case vk
    case viber
    case inst
    case phone
    case error
    
    var methodString: String  {
        switch self {
        case .tg:
            return "Telegram"
        case .inst:
            return "Instagram"
        case .phone:
            return "Телефон"
        case .viber:
            return "Viber"
        case .vk:
            return "VK"
        case .error:
            return "Unknown"
        }
    }
    
    static func checkMethod(_ method: String) -> Methods {
        switch method {
        case "tg":
            return .tg
        case "inst":
            return .inst
        case "phone":
            return .phone
        case "viber":
            return .viber
        case "vk":
            return .vk
        default:
            return .error
        }

    }
    
    static func handle(contact: Contact) {
        var url = ""
        switch contact.method {
        case .inst:
            url = "instagram://user?username=\(contact.contact)"
        case .tg:
            url = "tg://resolve?domain='\(contact.contact)'"
        case .phone:
            url = "tel://\(contact.contact)"
        case .viber:
            url = "viber://add?number=\(contact.contact)"
        case .vk:
            url = "vk://vk.com/\(contact.contact)"
          
        case .error:
         print("Contact handle error")
    
        }
        
        guard let contactUrl = URL.init(string: url) else { return }
        UIApplication.shared.open(contactUrl)
    }
}





