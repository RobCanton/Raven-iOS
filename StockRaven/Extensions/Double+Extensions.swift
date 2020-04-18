//
//  Double+Extensions.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

extension Double {
    var shortFormatted: String {
        
        func format(for value:Double) -> String {
            let num = Int(value)
            if num >= 100 {
                return "%.1f"
            } else if num >= 10 {
                return "%.2f"
            } else {
                return "%.3f"
            }
            
        }

        if self >= 1000000000000 {
            let value = self / 1000000000000
            return String(format: "\(format(for: value))T", locale: Locale.current, value)
        }
        
        if self >= 1000000000 {
            let value = self / 1000000000
            return String(format: "\(format(for: value))B", locale: Locale.current, value)
        }
        
        if self >= 1000000 {
            let value = self / 1000000
            return String(format: "\(format(for: value))M", locale: Locale.current, value)
        }
        
        if self >= 10000 {
            let value = self / 1000
            return String(format: "\(format(for: value))K", locale: Locale.current, value)
        }
        
        return String(format: "%.0f", locale: Locale.current,self)
    }
}
