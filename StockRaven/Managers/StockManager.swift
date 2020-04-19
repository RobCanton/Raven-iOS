//
//  StockManager.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

class StockManager {
    
    static let shared = StockManager()
    
    
    private(set) var stocks = [PolygonStock]()
    
    private var socket:SocketIOClient!
    private let manager = SocketManager(socketURL: URL(string: "http://replicode.io:3000")!,
                                        config: [.log(false), .compress])
    func connect() {
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        
        socket.on("welcome") { data, ack in
            print("I have been welcomed!")
        }
        
        for stock in stocks {
            addSocketListener(for: stock.symbol)
        }

        socket.connect()
    }
    
    private func addSocketListener(for symbol:String) {
        
        self.socket.on("T.\(symbol)") { data, ack in
            if let first = data.first as? [String:Any] {
                NotificationCenter.default.post(name: .init("T.\(symbol)"), object: nil, userInfo: first)
            }
        }
        
        self.socket.on("Q.\(symbol)") { data, ack in
            if let first = data.first as? [String:Any] {
                NotificationCenter.default.post(name: .init("Q.\(symbol)"), object: nil, userInfo: first)
            }
        }
    }
    
    private init() {
        
    }
    
    func observe() {
        PolyravenAPI.getWatchlist { _stocks in
            self.stocks = _stocks
            self.connect()
            NotificationCenter.default.post(name: Notification.Name("stocks-updated"), object: nil, userInfo: nil)
        }
    }
    
    func subscribe(to symbol:String) {
        PolyravenAPI.subscribe(to: symbol) { stock in
            guard let stock = stock else { return }
            self.stocks.append(stock)
            self.addSocketListener(for: stock.symbol)
            NotificationCenter.default.post(name: Notification.Name("stocks-updated"), object: nil, userInfo: nil)
        }
    }
    
    func unsubscribe(from symbol:String) {
        
        self.stocks.removeAll(where: { stock in
            return stock.symbol == symbol
        })
        
        PolyravenAPI.unsubscribe(from: symbol) {
            self.socket.off("T.\(symbol)")
            self.socket.off("Q.\(symbol)")
        }
    }
    
    
    
}

struct PolygonSearchResponse:Codable {
    let tickers:[PolygonTicker]
}

struct PolygonTicker:Codable {
    let symbol:String
    let securityName:String
    let exchange:String
}

struct PolygonStock:Codable {
    let symbol:String
    let details:PolygonStockDetails
    let lastTrade:PolygonStockTrade?
    let lastQuote:PolygonStockQuote?
    let previousClose:PolygonStockClose?
    
    var change:Double? {
        if let price = lastTrade?.price,
            let previousClose = previousClose?.close {
            return price - previousClose
        }
        return nil
    }
    
    var changePercent:Double? {
        if let change = change,
            let previousClose = previousClose?.close {
            let changePercent = abs(change / previousClose) * 100
            
            return changePercent
        }
        return nil
    }
    
    var changeStr:String? {
        guard let change = change else { return nil }
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: change),
                                                        number: NumberFormatter.Style.decimal)
        if change > 0 {
            return "+\(formatted)"
        }
        
        return formatted
    }
    
    var changePercentStr:String? {
        guard let changePercent = changePercent else { return nil }
        return "\(String(format: "%.2f", locale: Locale.current, changePercent))%"
    }
    
    var changeCompositeStr:String {
        guard let change = changeStr, let changePercent = changePercentStr else { return "" }
        
        return "\(change) (\(changePercent))"
    }
    
    var changeColor:UIColor {
        guard let change = change else { return UIColor.label }
        if change > 0 {
            return UIColor(hex: "33E190")
        } else if change < 0 {
            return UIColor(hex: "FF3860")
        } else {
            return UIColor.label
        }
    }
    
}


struct PolygonStockDetails:Codable {
    let ceo:String
    let country:String
    let description:String?
    let employees:Int
    let exchange:String?
    let exchangeSymbol:String?
    let industry:String?
    let marketcap:Int?
    let shares:Int?
    let name:String?
    let type:String
    let updated:String?
    let url:String?
}

struct PolygonStockTrade:Codable {
    let price:Double
    let exchange:Int
    let size:Int
    let timestamp:TimeInterval
}

struct PolygonStockQuote:Codable {
    let askexchange:Int
    let askprice:Double
    let asksize:Int
    let bidexchange:Int
    let bidprice:Double
    let bidsize:Int
    let timestamp:TimeInterval
}

struct PolygonStockClose:Codable {
    let open:Double
    let close:Double
    let high:Double
    let low:Double
}
