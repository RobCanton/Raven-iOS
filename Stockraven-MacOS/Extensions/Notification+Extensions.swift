//
//  Notification+Extensions.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation


extension NotificationCenter {
    enum NotificationType {
        
        case stocksUpdated
        case stockTradeUpdated(_ symbol:String)
        case stockQuoteUpdated(_ symbol:String)
        case marketStatusUpdated
        case screenChanged
        case action(_ screen:Screen, _ action:Action)
        case alertsUpdated
        
        var id:String {
            switch self {
            case .stocksUpdated:
                return "stocks-updated"
            case let .stockTradeUpdated(symbol):
                return "T.\(symbol)"
            case let .stockQuoteUpdated(symbol):
                return "Q.\(symbol)"
            case .marketStatusUpdated:
                return "market-status-updated"
            case .screenChanged:
                return "screen-changed"
            case let .action(screen, action):
                return "action-\(screen.rawValue)-\(action.rawValue)"
            case .alertsUpdated:
                return "alerts-updated"
            }
        }
        
        var name:Notification.Name {
            return Notification.Name(id)
        }
        
    }
    
    
    static func post(_ type:NotificationType, userInfo: [AnyHashable : Any]?=nil) {
        self.default.post(name: type.name, object: nil, userInfo: userInfo)
    }
    
    static func addObserver(_ observer:NSObject, selector: Selector, type: NotificationCenter.NotificationType) {
        self.default.addObserver(observer, selector: selector, name: type.name, object: nil)
    }
    
    static func removeObserver(_ observer:NSObject, type: NotificationCenter.NotificationType) {
        self.default.removeObserver(observer, name: type.name, object: nil)
    }
    
}

extension Notification.Name {
    
}
