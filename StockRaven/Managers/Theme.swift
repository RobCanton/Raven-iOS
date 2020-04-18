//
//  Theme.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-06.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


enum Theme:String {
    case basicBlue = "basic-blue"
    case basicIndigo = "basic-indigo"
    case basicPink = "basic-pink"
    case basicTeal = "basic-teal"
    case basicYellow = "basic-yellow"
    
    var primary:UIColor {
        return UIColor(named: "\(self.rawValue):primary")!
    }
    
    var secondary:UIColor {
        return UIColor(named: "\(self.rawValue):secondary")!
    }
    
    
    static var current = Theme.basicBlue
    static let all:[Theme] = [
        .basicBlue, .basicPink, .basicIndigo, .basicTeal, .basicYellow
    ]
    
    var displayName:String {
        switch self {
        case .basicBlue:
            return "Blue"
        case .basicIndigo:
            return "Indigo"
        case .basicPink:
            return "Pink"
        case .basicTeal:
            return "Teal"
        case .basicYellow:
            return "Yellow"
        }
    }
}
