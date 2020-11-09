//
//  Validator.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/8/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

enum Regexp: String {
    case coordinates = "[0-9]{1,4}\\.[0-9]{3,10}\\, [0-9]{1,4}\\.[0-9]{3,10}"
}

class Validator {
    static let shared = Validator()
    
    
    func validate(string: String, pattern: String) -> Bool {
        let passPred = NSPredicate(format:"SELF MATCHES %@", pattern)
        return passPred.evaluate(with: string)
    }
}
