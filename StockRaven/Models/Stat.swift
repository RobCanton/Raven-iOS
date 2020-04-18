//
//  Stat.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-07.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation


enum Stat:String {
    
    case price = "price"
    case volume = "volume"
    case change = "change"
    case changePercent = "changepercent"
    case open = "open"
    case close = "close"
    case previousClose = "previousclose"
    case previousVolume = "previousvolume"
    case high = "high"
    case low = "low"
    case marketCap = "marketcap"
    case avgTotalVolume = "avgtotalvolume"
    case week52High = "week52high"
    case week52Low = "week52low"
    case ytdChange = "ytdchange"
    case peRatio = "peratio"
    case extendedPrice = "extendedPrice"
    case extendedChange = "extendedChange"
    case extendedChangePercent = "extendedChangePercent"
    
    static let all = [
        price, volume, change, changePercent,
        open, close, previousClose, previousVolume,
        high, low, marketCap, avgTotalVolume,
        week52High, week52Low, ytdChange, peRatio,
        extendedPrice, extendedChange, extendedChangePercent
    ]
    
    var searchable:String {
        return self.rawValue
    }
    
}

extension Stat:Fuseable {
    var properties: [FuseProperty] {
        return [
            FuseProperty(name: rawValue, weight: 1.0),
        ]
    }
    
    
}
