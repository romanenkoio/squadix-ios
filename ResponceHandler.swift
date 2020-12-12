//
//  ResponceHandler.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 8/4/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import Moya

final class ResponceHandler {
    private enum statusCodes: Int {
        case unautorized = 401
        case forbidden   = 403
    }
    
    static func handle(responce: Moya.Response) {
        print("Status: \(responce.statusCode)")
        guard let data = try? responce.mapJSON() else {
            print("Error")
            return
        }
        print(data)
        
        switch responce.statusCode {
        case 401:
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.showLogin()
        case 500:
            PopupView(title: "", subtitle: "Ошибка сервера", image: UIImage(named: "cancel")).show()
        default:
           break
        }
    }
    
    static func handleError(error: MoyaError) {
        PopupView(title: "", subtitle: "Не удалось подключиться к серверу", image: UIImage(named: "cancel")).show()
    }
}
