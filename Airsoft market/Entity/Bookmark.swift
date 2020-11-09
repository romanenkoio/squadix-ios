//
//  Bookmark.swift
//  Squadix
//
//  Created by Illia Romanenko on 11/8/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

class Bookmark {
    var note: String!
    var coordinate: String!
    
    init() {
    }
    
    init(note: String, coordinate: String) {
        self.note = note
        self.coordinate = coordinate
    }
}
