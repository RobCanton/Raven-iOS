//
//  Evaluation.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-13.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

public struct Evaluation {
    let value:Double
    let currency:Currency
    let date:Date
    let variables:[String:Double]
    
    var displayString:String {
        var str = NumberFormatter.localizedString(from: NSNumber(value: value),
                                                  number: NumberFormatter.Style.decimal)
//        if currency != .none {
//            str += " \(currency.rawValue)"
//        }
        
        return str
    }
     
    static func parse(_ data:[String:Any]) -> Evaluation? {
        if let value = data["value"] as? Double,
            let _date = data["date"] as? TimeInterval {
            let variables = data["variables"] as? [String:Double] ?? [String:Double]()
            
            return Evaluation(value: value,
                              currency: .usd,
                              date: Date(timeIntervalSince1970: _date / 1000),
                              variables: variables)
        }
        return nil
    }
}
