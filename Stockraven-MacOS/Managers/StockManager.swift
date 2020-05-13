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

enum MarketStatus:String {
    case open = "open"
    case closed = "closed"
    case premarket = "pre-market"
    case afterhours = "after-hours"
    
    var displayString:String {
        switch self {
        case .open:
            return "Market Open"
        case .closed:
            return "Market Closed"
        case .premarket:
            return "Pre-market"
        case .afterhours:
            return "After Hours"
        }
    }
}

class StockManager {
    
    static let shared = StockManager()
    
    
    private(set) var stocks = [PolygonStock]()
    private var stockIndex = [String:Int]()
    
    private(set) var marketStatus = MarketStatus.closed
    
    private var socket:SocketIOClient!
    
    private(set) var alerts = [Alert]()
    private(set) var alertIndexes = [String:[Int]]()
    
    func alerts(for symbol:String) -> [Alert] {
        var _alerts = [Alert]()
        if let indexes = alertIndexes[symbol] {
            for i in indexes {
                _alerts.append(alerts[i])
            }
        }
        _alerts.sort(by: { return $0.timestamp < $1.timestamp })
        return _alerts
    }
    
    private let manager = SocketManager(socketURL: URL(string: "http://replicode.io:3100")!,
                                        config: [.log(false), .compress])
    func connect() {
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on("market-status") { data, ack in
            if let statusStr = data.first as? String,
                let status = MarketStatus(rawValue: statusStr) {
                self.marketStatus = status
                NotificationCenter.post(.marketStatusUpdated)
            }
        }
        
        for stock in stocks {
            addSocketListener(for: stock.symbol)
        }

        socket.connect()
    }
    
    private func addSocketListener(for symbol:String) {
        
        self.socket.on("T.\(symbol)") { data, ack in
            if let dict = data.first as? [String:Any] {

                guard let index = self.stockIndex[symbol] else { return }
                guard let price = dict["p"] as? Double,
                    let exchange = dict["x"] as? Int,
                    let size = dict["s"] as? Int,
                    let timestamp = dict["t"] as? TimeInterval else { return }
                
                let trade = PolygonStockTrade(price: price,
                                              exchange: exchange,
                                              size: size,
                                              timestamp: timestamp)
                
                var stock = self.stocks[index]
                
                stock.lastTrade = trade
                self.stocks.remove(at: index)
                self.stocks.insert(stock, at: index)
                NotificationCenter.post(.stockTradeUpdated(stock.symbol), userInfo: [
                    "stock": stock
                ])
            }
        }
        
        self.socket.on("Q.\(symbol)") { data, ack in
            if let dict = data.first as? [String:Any] {
                
                guard let index = self.stockIndex[symbol] else { return }
                guard let askexchange = dict["ax"] as? Int,
                    let askprice = dict["ap"] as? Double,
                    let asksize = dict["as"] as? Int,
                    let bidexchange = dict["bx"] as? Int,
                    let bidprice = dict["bp"] as? Double,
                    let bidsize = dict["bs"] as? Int,
                    let timestamp = dict["t"] as? TimeInterval else { return }
                
                let quote = PolygonStockQuote(askexchange: askexchange,
                                              askprice: askprice,
                                              asksize: asksize,
                                              bidexchange: bidexchange,
                                              bidprice: bidprice,
                                              bidsize: bidsize,
                                              timestamp: timestamp)
                
                var stock = self.stocks[index]
                
                stock.lastQuote = quote
                self.stocks.remove(at: index)
                self.stocks.insert(stock, at: index)
                
                NotificationCenter.post(.stockQuoteUpdated(stock.symbol), userInfo: [
                    "stock": stock
                ])
                
            }
        }
    }
    
    private func removeSocketListener(for symbol:String) {
        self.socket.off("T.\(symbol)")
        self.socket.off("Q.\(symbol)")
    }
    
    private init() {
        
    }
    
    func observe() {
        PolyravenAPI.getWatchlist { _stocks, _alerts in
            self.stocks = _stocks
            self.stockIndex = [:]
            for i in 0..<self.stocks.count {
                let stock = self.stocks[i]
                self.stockIndex[stock.symbol] = i
            }
            
            self.alerts = _alerts
            for i in 0..<self.alerts.count {
                let alert = self.alerts[i]
                if self.alertIndexes[alert.symbol] == nil {
                    self.alertIndexes[alert.symbol] = [i]
                } else {
                    self.alertIndexes[alert.symbol]!.append(i)
                }
            }
            self.connect()
            NotificationCenter.post(.stocksUpdated)
        }
    }
    
    func subscribe(to symbol:String) {
        PolyravenAPI.subscribe(to: symbol) { stock in
            
            guard let stock = stock else { return }
            self.stocks.append(stock)
            self.stockIndex[stock.symbol] = self.stocks.count - 1
            self.addSocketListener(for: stock.symbol)
            NotificationCenter.post(.stocksUpdated)
        }
    }
    
    func unsubscribe(from symbol:String) {
        
        self.stocks.removeAll(where: { stock in
            return stock.symbol == symbol
        })
        
        self.stockIndex = [:]
        for i in 0..<self.stocks.count {
            let stock = self.stocks[i]
            self.stockIndex[stock.symbol] = i
        }
        
        
        PolyravenAPI.unsubscribe(from: symbol) {
            self.socket.off("T.\(symbol)")
            self.socket.off("Q.\(symbol)")
        }
    }
    
    func addAlert(_ alert:Alert) {
        let index = alerts.count
        self.alerts.append(alert)
        
        if self.alertIndexes[alert.symbol] == nil {
            self.alertIndexes[alert.symbol] = [index]
        } else {
            self.alertIndexes[alert.symbol]!.append(index)
        }
        
        NotificationCenter.post(.alertsUpdated)
    }
    
    func updateAlert(_ alert:Alert) {
        guard let index = alerts.firstIndex(where: { $0.id == alert.id }) else { return }
        alerts[index] = alert
        
        NotificationCenter.post(.alertsUpdated)
    }
    
    func deleteAlert(withID id:String, completion: @escaping ()->()) {
        PolyravenAPI.deleteAlert(id) {
            completion()
        }
    }
    
    func moveStock(at sourceIndex: Int, to destinationIndex: Int) {
        let moveItem = self.stocks.remove(at: sourceIndex)
        self.stocks.insert(moveItem, at: destinationIndex)
        
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
    var lastTrade:PolygonStockTrade?
    var lastQuote:PolygonStockQuote?
    let previousClose:PolygonStockClose?
    let order:Int
    
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
    //let ceo:String?
    //let country:String?
    let description:String?
    //let employees:Int?
    //let exchange:String?
    //let exchangeSymbol:String?
    //let industry:String?
    //let marketcap:Int?
    let shares:Double?
    let name:String?
    //let type:String
    //let updated:String?
    //let url:String?
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
    let open:Double?
    let close:Double?
    let high:Double?
    let low:Double?
}
