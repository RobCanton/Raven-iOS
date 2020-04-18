//
//  Currency.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-07.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation


enum Currency:String {
    case none = ""
    case usd = "USD"
    case cad = "CAD"
    case eur = "EUR"
    
    static let all:[Currency] = [
        .usd, .cad, .eur
    ]

}

struct CurrencyPair:Fuseable {
    var code:String
    var properties: [FuseProperty] {
        return [
            FuseProperty(name: code, weight: 1.0),
        ]
    }
    
    static let all:[CurrencyPair] = [
        CurrencyPair(code: "USDCAD"), CurrencyPair(code: "USDEUR"),
        CurrencyPair(code: "CADEUR"), CurrencyPair(code: "CADEUR"),
        CurrencyPair(code: "EURUSD"), CurrencyPair(code: "EURCAD")
    ]
}
