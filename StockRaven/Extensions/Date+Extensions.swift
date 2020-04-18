//
//  Date+Extensions.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-26.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

extension Date {
    
    var UTCToLocalStr:String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        
        
        if self.isToday {
            dateFormatter.dateFormat = "h:mm:ss a"
        } else if self.isYesterday {
            dateFormatter.dateFormat = "Yesteday, h:mm:ss a"
        } else {
            dateFormatter.dateFormat = "MMM d, h:mm:ss a"
        }
        return dateFormatter.string(from: self)
    }
    
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    var isToday:Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday:Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    
    enum Format:String {
        case yyyyMMdd = "yyyyMMdd"
        case MMddyyyy = "MMddyyyy"
    }
    
    static func string(from date:Date, withFormat format:Format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: date)
    }
    
    static func date(from string:String, withFormat format:Format) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: string)
    }
    
}
