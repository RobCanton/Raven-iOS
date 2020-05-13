//
//  RavenAPI.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-06.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Firebase


struct EquationDataResponse {
    let stocks:[Stock]
    let historicalQuotes:[HistoricalQuote]
    
    static let none = EquationDataResponse(stocks: [], historicalQuotes: [])
}

class RavenAPI {

    static let shared = RavenAPI()

    private init() {
        
    }
    
    
    func enablePresenceDetection() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let presenceRef = database.child("users/connected/\(uid)")
        
        presenceRef.setValue(true)
        presenceRef.onDisconnectRemoveValue()
        
    }
    
    func disablePresenceDetection() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let presenceRef = database.child("users/connected/\(uid)")
        presenceRef.removeValue()
        presenceRef.cancelDisconnectOperations()
    }
    
    func saveItem(_ item:Item, completion: @escaping ((_ error:Error?)->())) {
        
        guard let evaluation = item.evaluation else { return }
        
        let endpoint = "saveItem"
        
        let proxyComponents = item.equation.proxyComponents
        
        var symbolsDict = [String:[String:[String:Bool]]]()
        for proxyComponent in proxyComponents {
            let statStr = proxyComponent.auxillary.string.replacingOccurrences(of: ":", with: "")
            var stat = statStr
            var date = "live"
            let split = statStr.split(separator: "@")
            if split.count == 2 {
                stat = String(split[0])
                date = String(split[1])
            }
            if symbolsDict[proxyComponent.primary.string]?[stat] == nil {
                symbolsDict[proxyComponent.primary.string] = [ stat : [ date : true ] ]
            } else {
                symbolsDict[proxyComponent.primary.string]![stat]![date] = true
            }
        }
        
        var params = [
            "equation": [
                "text": item.equation.stringRepresentation,
                "text_calcuable": item.equation.calculableString,
                "symbols": symbolsDict
            ],
            "evaluation": [
                "value": evaluation.value,
                "date": evaluation.date.timeIntervalSince1970 * 1000,
                "variables": evaluation.variables
            ],
            "details": [
                "name": item.details.name ?? "",
                "tags": item.details.tagsStr ?? ""
            ],
            "watch_level": item.details.watchLevel.rawValue
        ] as [String : Any]
        
        if !item.id.isEmpty {
            params["id"] = item.id
        }
        
        functions.httpsCallable(endpoint).call(params) { result, error in
            guard let result = result, error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(error)
                return
            }
            
            print("result: \(result)")
            completion(nil)
        }
    }
    
    func removeItem(_ item:Item) {
        let endpoint = "removeItem"
        
        let symbols = item.equation.components(ofType: .symbol).map { symbol in
            return symbol.string
        }
        
        let params = [
            "equation": [
                "symbols": symbols
            ],
            "id": item.id
        ] as [String : Any]
        
        functions.httpsCallable(endpoint).call(params) { result, error in
            guard let data = result?.data as? [String:Any] else { return }
            print("Data: \(data)")
        }
    }
    
    func getItems(completion: @escaping ((_ items:[Item])->())) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        let itemsRef = database.child("users/items/\(uid)")
        
        
        itemsRef.observeSingleEvent(of: .value, with: {snapshot in
            var _items = [Item]()
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                    var childData = childSnapshot.value as? [String:Any] else {
                    continue
                }
                childData["id"] = childSnapshot.key
                
                if let item = Item.parse(from: childData) {
                    _items.append(item)
                }
            }
            
            completion(_items)
            
        })
    }
    
    func observeItems() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = database.child("users/items/\(uid)")
        ref.observe(.childAdded, with: { snapshot in
            
            guard var data = snapshot.value as? [String:Any] else { return }
            
            data["id"] = snapshot.key
            
            if let item = Item.parse(from: data) {
                ItemManager.shared.addItem(item)
            }
            
        })
        
        ref.observe(.childChanged, with: { snapshot in
            guard var data = snapshot.value as? [String:Any] else { return }
            
            data["id"] = snapshot.key
            
            if let item = Item.parse(from: data) {
                ItemManager.shared.addItem(item)
            }
        })
        
        ref.observe(.childRemoved, with: { snapshot in
            // Do nothing
        })
    }
    
    
    func evaluate(equation:Equation, completion: @escaping ()->()) {
        
        let proxyComponents = equation.proxyComponents
        var symbols = [String]()
        var symbolsHistorical = [String]()
        
        for proxy in proxyComponents {
            if let date = proxy.date {
                let pair = "\(proxy.primary.string)\(date.string)"
                if !symbolsHistorical.contains(pair) {
                    symbolsHistorical.append(pair)
                }
            } else {
                if !symbols.contains(proxy.primary.string) {
                    symbols.append(proxy.primary.string)
                }
            }
        }
        
        let endpoint = "evaluateEquation"
        let params = [
            "equation": equation.calculableString,
            "symbols": symbols,
            "symbolsHistorical": symbolsHistorical
        ] as [String:Any]
        
        functions.httpsCallable(endpoint).call(params) { result, error in
            guard let data =  result?.data as? [String:Any] else {
                print("Failed with error: \(error?.localizedDescription ?? "nil")")
                return
            }
            print("Data: \(data)")
        }
    }
    
    func getData(for equation:Equation, completion: @escaping ((_ response:EquationDataResponse?, _ error:Error?)->())) {
        
        let proxyComponents = equation.proxyComponents
        var symbols = [String]()
        var symbolsHistorical = [String]()
        
        for proxy in proxyComponents {
            if let date = proxy.date {
                let pair = "\(proxy.primary.string)\(date.string)"
                if !symbolsHistorical.contains(pair) {
                    symbolsHistorical.append(pair)
                }
            } else {
                if !symbols.contains(proxy.primary.string) {
                    symbols.append(proxy.primary.string)
                }
            }
        }
        
        let endpoint = "symbolQuotesBatch"
        let params = [
            "symbols": symbols,
            "symbolsHistorical": symbolsHistorical
        ]
               
        functions.httpsCallable(endpoint).call(params) { result, error in
            guard let result = result, error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = result.data as? [String:Any] else { return }
            
            print("Data: \(data)")
            var stocks = [Stock]()
            if let quotes = data["quotes"] as? [[String:Any]] {
                for quote in quotes {
                    if let stock = Stock.parse(from: quote) {
                        stocks.append(stock)
                    }
                }
            }
            
            var historicalStocks = [HistoricalQuote]()
            if let historicalQuotes = data["historicalQuotes"] as? [[String:Any]] {
                for quote in historicalQuotes {
                    if let quote = HistoricalQuote.parse(from: quote) {
                        historicalStocks.append(quote)
                    }
                }
            }
            
            let response = EquationDataResponse(stocks: stocks,
                                                historicalQuotes: historicalStocks)
            completion(response, error)
            return

        }
    }
    
}
