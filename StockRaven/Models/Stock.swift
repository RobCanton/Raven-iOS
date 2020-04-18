//
//  Stock.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-06.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

struct Stock {
    var symbol:String
    var quote:Quote
    
    var symbol_calculable:String {
        return symbol.replacingOccurrences(of: "-", with: "_")
    }
    
    struct Quote {
        // Searchable
        var price: Double? // latestPrice
        var volume:Double? // latestVolume
        var change:Double? // change
        var changePercent:Double? // changePercent
        var open:Double? // open
        var close:Double? // close
        var previousClose:Double? // previousClose
        var previousVolume:Double? // previousVolume
        var high:Double? // high
        var low:Double? // low
        var marketCap:Double? // marketCap
        var avgTotalVolume:Double? // avgTotalVolume
        var week52High:Double? // week52High
        var week52Low:Double? // week52Low
        var ytdChange:Double? // ytdChange
        var peRatio:Double? // peRatio
        var extendedPrice:Double? // extendedPrice
        var extendedChange:Double? // extendedChange
        var extendedChangePercent:Double? // extendedChangePercent
        
        // Auxillary
        var latestUpdate:Date?
        var currency:Currency
        
        
        static func parse(from dict:[String:Any]) -> Quote? {
            
            let price = dict["latestPrice"] as? Double
            let volume = dict["latestVolume"] as? Double
            let change = dict["change"] as? Double
            let changePercent = dict["changePercent"] as? Double
            let open = dict["open"] as? Double
            let close = dict["close"] as? Double
            let previousClose = dict["previousClose"] as? Double
            let previousVolume = dict["previousVolume"] as? Double
            let high = dict["high"] as? Double
            let low = dict["low"] as? Double
            let marketCap = dict["marketCap"] as? Double
            let avgTotalVolume = dict["avgTotalVolume"] as? Double
            let week52High = dict["week52High"] as? Double
            let week52Low = dict["week52Low"] as? Double
            let ytdChange = dict["ytdChange"] as? Double
            let peRatio = dict["peRatio"] as? Double
            let extendedPrice = dict["extendedPrice"] as? Double
            let extendedChange = dict["extendedChange"] as? Double
            let extendedChangePercent = dict["extendedChangePercent"] as? Double
            
            var latestUpdate:Date?
            if let _latestUpdate = dict["latestUpdate"] as? TimeInterval {
                latestUpdate = Date(timeIntervalSince1970: _latestUpdate)
            }
                
            let currencyStr = dict["currency"] as? String ?? ""
            let currency = Currency(rawValue: currencyStr) ?? Currency.none
            
            return Quote(price: price, volume: volume, change: change, changePercent: changePercent, open: open, close: close, previousClose: previousClose, previousVolume: previousVolume, high: high, low: low, marketCap: marketCap, avgTotalVolume: avgTotalVolume, week52High: week52High, week52Low: week52Low, ytdChange: ytdChange, peRatio: peRatio, extendedPrice: extendedPrice, extendedChange: extendedChange, extendedChangePercent: extendedChangePercent, latestUpdate: latestUpdate, currency: currency)
            
        }
    }
    
    static func parse(from dict:[String:Any]) -> Stock? {
        if let symbol = dict["symbol"] as? String,
            let quote = Quote.parse(from: dict) {
            return Stock(symbol: symbol, quote: quote)
        }
        return nil
    }
    
    
    
    
    
}


struct HistoricalQuote {
    var symbol:String
    var dateStr:String
    
    var changePercent:Double?
    var change:Double?
    var volume:Double?
    var close:Double?
    var open:Double?
    var low:Double?
    var high:Double?
    
    
    static func parse(from dict:[String:Any]) -> HistoricalQuote? {
        
        guard let symbol = dict["symbol"] as? String,
            let date = dict["date"] as? String else { return nil }
        let volume = dict["volume"] as? Double
        let change = dict["change"] as? Double
        let changePercent = dict["changePercent"] as? Double
        let open = dict["open"] as? Double
        let close = dict["close"] as? Double
        let high = dict["high"] as? Double
        let low = dict["low"] as? Double
       
        let dateStr = date.replacingOccurrences(of: "-", with: "")
 
            
        return HistoricalQuote(symbol: symbol, dateStr: dateStr,
                               changePercent: changePercent, change: change, volume: volume,
                               close: close, open: open, low: low , high: high)
        
    }
    
}
