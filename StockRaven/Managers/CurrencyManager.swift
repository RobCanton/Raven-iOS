//
//  CurrencyManager.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-07.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

class CurrencyManager {
    
    static let shared = CurrencyManager()
    var rates:[Currency:Double] {
        didSet {
            print("Rates: \(rates)")
        }
    }
    
    private var forexRef:DatabaseReference {
        return database.child("data/forex")
    }
    
    private init() {
        rates = [:]
        for c in Currency.all {
            rates[c] = 1.0
        }
    }
    
    func observeRates() {
        let ref = forexRef
        ref.observe(.childAdded, with: { snapshot in
            
            if let currency = Currency(rawValue: snapshot.key),
                let value = snapshot.value as? Double {
                self.rates[currency] = value
            }
        })
        
        ref.observe(.childChanged, with: { snapshot in
            
            if let currency = Currency(rawValue: snapshot.key),
                let value = snapshot.value as? Double {
                self.rates[currency] = value
            }
        })
    }
    
    func stopObservingRates() {
        forexRef.removeAllObservers()
    }
    
    func currencies(for symbol:String) -> (Currency, Currency)? {
        if symbol.count == 6 {
            let index = symbol.index(symbol.startIndex, offsetBy: 3)
            let leading = String(symbol[..<index])
            let trailing = String(symbol[index...])

            if let to = Currency(rawValue: leading), let from = Currency(rawValue: trailing) {
                return (to, from)
            }
        }
        return nil
    }
    
    func rate(for symbol:String) -> Double {
        if let pair = currencies(for: symbol) {
            return rate(from: pair.0, to: pair.1)
        }
        return 1.0
    }
    
    func rate(from:Currency, to:Currency) -> Double {
        if from == .usd { 
            return rates[to] ?? 1.0
        } else if to == .usd {
            return 1.0 / (rates[from] ?? 1.0)
        } else {
            return (rates[to] ?? 1.0) / (rates[from] ?? 1.0)
        }
    }
}
