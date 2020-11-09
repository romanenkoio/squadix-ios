//
//  Filters.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 11/1/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation

struct Filter: Equatable {
    let category: String!
    var status: Bool!

    
    init(category: String, status: Bool = true) {
        self.category = category
        self.status = true
    }
    
    init(filter: SavedFilter) {
        self.category = filter.category
        self.status = filter.state
    }
    
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        if lhs.category == rhs.category && lhs.status == rhs.status {
            return true
        }
        return false
    }
    
    func asParams() -> String {
        return self.category
    }
}

extension Array where Element == Filter {
    func asParams() -> String {
        var querryString = ""
        let activeFilters = self.filter({$0.status == true})
        
        for filter in activeFilters {
            if let item = filter.category {
                querryString += "\(item),"
            }
           
        }
        return querryString
        
    }
}
