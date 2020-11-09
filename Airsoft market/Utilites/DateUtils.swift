//
//  DateUtils.swift
//  Airsoft market
//
//  Created by Illia Romanenko on 5/24/20.
//  Copyright © 2020 Illia Romanenko. All rights reserved.
//

import Foundation
import ObjectMapper


extension Date {
    
    func timeForEvent() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

            return formatter.string(from: self)
    }
    
    
    func dateForEvent() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "HH:mm"
           
           if Calendar.current.isDateInTomorrow(self) {
               return "Завтра"
           } else if Calendar.current.isDateInToday(self) {
               return "Сегодня"
           } else {
               formatter.dateFormat = "dd.MM.yy"
               return formatter.string(from: self)
           }
       }

    
    func dateToHumanString() -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "HH:mm"
            return "Сегодня в \(formatter.string(from: self))"
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.dateFormat = "HH:mm"
            return "Вчера в \(formatter.string(from: self))"
        } else {
            formatter.dateFormat = "d MMMM, HH:mm"
            return formatter.string(from: self)
        }
    }
    
    func compare(with dateToCompare: Date) -> Bool {
        let calendar = Calendar.current
        
        if calendar.component(.day, from: self) != calendar.component(.day, from: dateToCompare) {
            return false
        } else if calendar.component(.month, from: self) != calendar.component(.month, from: dateToCompare) {
            return false
        } else if calendar.component(.year, from: self) != calendar.component(.year, from: dateToCompare) {
            return false
        }
            
        return true
    }
    
    var localizedDescription: String {
        return description(with: .current)
    }
}




