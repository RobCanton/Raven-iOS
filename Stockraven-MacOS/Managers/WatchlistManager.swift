//
//  WatchlistManager.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class WatchlistManager {
    
    static let shared = WatchlistManager()
    
    var watchlist:[String:Bool]
    var handles:[UInt:DatabaseReference]
    var stocks:[String:Stock]
    
    private init() {
        watchlist = [:]
        handles = [:]
        stocks = [:]
    }
    
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemsUpdated),
                                               name: Notification.Name("itemsUpdated"), object: nil)
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func itemsUpdated() {
        let items = ItemManager.shared.items
        var watchlistSymbols = [String:Bool]()
        for item in items {
            let symbols = item.equation.components(ofType: .symbol)
            for symbol in symbols {
                watchlistSymbols[symbol.string] = true
            }
        }
        
        self.watchlist = watchlistSymbols
        
        self.updateObservers()
    }
    
    func updateObservers() {
        
        removeObservers()
        
        for (symbol, _) in watchlist {
            let ref = systemDatabase.child("stocks/\(symbol)")
            
            let handle = ref.observe(.value, with: { snapshot in
                guard let data = snapshot.value as? [String:Any] else { return }
                
                if let quote = Stock.Quote.parse(from: data) {
                    let stock = Stock(symbol: symbol, quote: quote)
                    self.stocks[symbol] = stock
                    NotificationCenter.default.post(name: Notification.Name("stockUpdated"), object: nil, userInfo: [
                        "symbol": symbol
                    ])
                }
            })
            
            handles[handle] = ref
            
            
        }
    }
    
    func removeObservers() {
        for (handle,ref) in handles {
            ref.removeObserver(withHandle: handle)
        }
        
        handles = [:]
    }
    
    
}
