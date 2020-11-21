//
//  Validator.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/8/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation



class Validator {
    static let shared = Validator()
    
    enum Regexp: String {
        case coordinates = "[0-9]{1,4}\\.[0-9]{3,30}\\, [0-9]{1,4}\\.[0-9]{3,30}"
        case phone = "^(\\+375|375)(29|25|44|33)(\\d{3})(\\d{2})(\\d{2})$"
        case password = "[\\S]{8,25}"
        case email = "^[A-z0-9_.+-]+@[A-z0-9-]+(\\.[A-z0-9-]{2,})+$"
    }
    
    func validate(string: String, pattern: String) -> Bool {
        let passPred = NSPredicate(format:"SELF MATCHES %@", pattern)
        return passPred.evaluate(with: string)
    }
}
