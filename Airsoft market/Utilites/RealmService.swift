//
//  RealmService.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/28/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import RealmSwift

class SavedFilter: Object {
    @objc dynamic var state = true
    @objc dynamic var category = ""
}

class SavedBookmarks: Object {
    @objc dynamic var note = ""
    @objc dynamic var coordinate = ""
}


class RealmService {
    static let realm = try! Realm()
    
    static func updateFilters(complition: (() -> Void)? = nil) {
        NetworkManager.shared.getCategories(completion: { newCategories in
            var currentCategories = readFilters()
            var filetrsForUpdate: [Filter] = []
            let filteredNewCategory: [String] = newCategories.map({$0.name}).sorted(by: {$0 > $1})
            for category in filteredNewCategory {
                if currentCategories.filter({$0.category == category}).count == 0 {
                    filetrsForUpdate.append(Filter(category: category))
                }
            }
            currentCategories += filetrsForUpdate
            writeFilters(currentCategories.sorted(by: {$0.category > $1.category}))
            complition?()
        }, failure: { error in
            print(error)
            print("[NETWORK] Failed update categories")
        })
    }
    
    static func writeFilters(_ filters: [Filter]) {
        eraseFilters()
        
        var filterForSave: [SavedFilter] = []
        
        for item in filters {
            let savedFilter = SavedFilter()
            savedFilter.category = item.category
            savedFilter.state = item.status
            filterForSave.append(savedFilter)
        }
        
        try! realm.write {
            realm.add(filterForSave)
        }
    }
    
    static func readFilters(onlyActive: Bool = false) -> [Filter] {
        let result = realm.objects(SavedFilter.self).toArray(ofType: SavedFilter.self)
        if onlyActive {
           return result.map{ Filter(filter: $0)}.filter({ $0.status == true})
        }
        return result.map{ Filter(filter: $0)}.sorted(by: {$0.category < $1.category})
    }
    
    static func eraseFilters() {
          try! realm.write {
              realm.deleteAll()
          }
      }
    
    static func readNotes() -> [Bookmark] {
        return realm.objects(SavedBookmarks.self).toArray(ofType: SavedBookmarks.self).map({Bookmark(note: $0.note, coordinate: $0.coordinate)})
    }
    
    static func writeBookmark(bookmark: Bookmark) {
        let bookmarkForSave = SavedBookmarks()
        bookmarkForSave.coordinate = bookmark.coordinate
        bookmarkForSave.note = bookmark.note
        
        do {
            try realm.write {
                realm.add(bookmarkForSave)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}

