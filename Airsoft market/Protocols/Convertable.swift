//
//  Creatable.swift
//  Squadix
//
//  Created by Illia Romanenko on 2.04.21.
//  Copyright © 2021 Illia Romanenko. All rights reserved.
//

import Foundation

protocol Convertable {
    func asParams() -> [String: Any] 
}
