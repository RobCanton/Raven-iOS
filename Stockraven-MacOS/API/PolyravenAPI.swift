//
//  PolygonAPI.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-15.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

enum HTTPMethod:String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

class PolyravenAPI {

    static let shared = PolyravenAPI()
    
    static let host = "http://replicode.io:3004/"
    
    enum Endpoint:String {
        case watchlist = "user/watchlist"
        case search = "ref/search"
        case registerPushToken = "user/pushtoken"
        case stockHistoricTrades = "stocks/trades"
        case userAlerts = "user/alerts"
    }
    
    private static func getURL(for endpoint:Endpoint) -> String {
        return "\(PolyravenAPI.host)\(endpoint.rawValue)"
    }
    
    static private let session = URLSession.shared
    
    static var authToken:String?
    static var pushToken:String?

    private init() {
    
    }
    
    static func search(_ text:String, completion: @escaping ((_ searchFragment:String, _ tickers:[PolygonTicker])->())) {
        
        if text.isEmpty {
            completion(text, [])
            return
        }
        
        let url = "\(getURL(for: .search))/\(text)"
        
        authenticatedRequest(.get, url: url, cachePolicy: .returnCacheDataElseLoad) { data, response, error in
            var tickers = [PolygonTicker]()
            
            if let data = data {
                do {
                    tickers = try JSONDecoder().decode([PolygonTicker].self, from: data)

                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion(text, tickers)
            }
        }
    }
    
    struct WatchlistResponse:Codable {
        let stocks:[PolygonStock]
        let alerts:[Alert]
    }
    
    static func getWatchlist(completion: @escaping ((_ stocks:[PolygonStock], _ alerts:[Alert])->())) {
        
        let url = getURL(for: .watchlist)
         
        
        authenticatedRequest(.get, url: url) { data, response, error in
            var stocks = [PolygonStock]()
            var alerts = [Alert]()
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("JSON: \(json)")
                    let resp = try JSONDecoder().decode(WatchlistResponse.self, from: data)
                    stocks = resp.stocks
                    alerts = resp.alerts
                    print("ALERTS: \(resp.alerts)")
                } catch {
                    print("Error: \(error.localizedDescription)")
                    
                }
            }
            
            
            
            DispatchQueue.main.async {
                completion(stocks, alerts)
            }
        }
        
    }
    
    static func subscribe(to ticker:String, completion: @escaping ((_ stock:PolygonStock?)->())) {
        let url = "\(getURL(for: .watchlist))/\(ticker)"
        
        authenticatedRequest(.post, url: url) { data, response, error in
            var stock:PolygonStock?
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("JSON: \(json)")
                    stock = try JSONDecoder().decode(PolygonStock.self, from: data)
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            print("Stock: \(stock)")
        
            DispatchQueue.main.async {
                completion(stock)
            }
        }
    }
    
    static func unsubscribe(from ticker:String, completion: @escaping (()->())) {
        let url = "\(getURL(for: .watchlist))/\(ticker)"

        
        authenticatedRequest(.delete, url: url) { data, response, error in
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    static func registerPushToken() {
        guard let token = pushToken else { return }
        let url = "\(getURL(for: .registerPushToken))/\(token)"
        
        authenticatedRequest(.post, url: url) { data, response, error in
            print("Error: \(error?.localizedDescription)")
            
        }
    }
    
    static func stockHistoricTrades(symbol:String, date:String, completion: @escaping ((_ trades:[HistoricTrade])->())) {
        let url = "\(getURL(for: .stockHistoricTrades))/\(symbol)/\(date)"
        
        authenticatedRequest(.get, url: url, cachePolicy: .returnCacheDataElseLoad) { data, response, error in
            var trades = [HistoricTrade]()
            if let data =  data {
                do {
                    trades = try JSONDecoder().decode([HistoricTrade].self, from: data)
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion(trades)
            }
            
        }
    }
    
    static func createAlert(_ alert:AlertEditable, for stock:PolygonStock, completion: @escaping (_ alert:Alert?)->()) {
        let url = getURL(for: .userAlerts)
        let params:[String:Any] = [
            "symbol": stock.symbol,
            "type": alert.type.rawValue,
            "condition": alert.condtion,
            "value": alert.value!,
            "enabled": true,
            "reset": alert.reset
        ]
        print("Params: \(params)")
        authenticatedRequest(.post, url: url, params: params, cachePolicy: .reloadIgnoringCacheData) { data, response, error in
            
            var alert:Alert?
            print("Error: \(error?.localizedDescription)")
            
            if let data = data{
                
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                    print("JSON: \(json)")

                    alert = try JSONDecoder().decode(Alert.self, from: data)

                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            
            DispatchQueue.main.async {
                completion(alert)
            }
            
        }
        
    }
    
    static func patchAlert(_ alert:AlertEditable, completion: @escaping (_ alert:Alert?)->()) {
        let url = "\(getURL(for: .userAlerts))/\(alert.id)"
        let params:[String:Any] = [
            "type": alert.type.rawValue,
            "condition": alert.condtion,
            "value": alert.value!,
            "enabled": alert.enabled,
            "reset": alert.reset
        ]
        
        authenticatedRequest(.patch, url: url, params: params, cachePolicy: .reloadIgnoringCacheData) { data, response, error in
            
            var alert:Alert?
            print("Error: \(error?.localizedDescription)")
            
            if let data = data{
                
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                    print("JSON: \(json)")

                    alert = try JSONDecoder().decode(Alert.self, from: data)

                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            
            DispatchQueue.main.async {
                completion(alert)
            }
            
        }
        
    }
    
    static func deleteAlert(_ id:String, completion: @escaping()->()) {
        let url = "\(getURL(for: .userAlerts))/\(id)"
        
        authenticatedRequest(.delete, url: url) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                    print("JSON: \(json)")

                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    private static func authenticatedRequest(_ method:HTTPMethod,
                                             url:String,
                                             params:[String:Any]? = nil,
                                             body:[String:Any]?=nil,
                                             cachePolicy:URLRequest.CachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData,
                                             completion: @escaping ((_ data:Data?, _ response:HTTPURLResponse?, _ error:Error?)->())) {
        
        guard let token = authToken else {
            completion(nil, nil, NSError(domain: "Token missing", code: 401, userInfo: nil))
            return
        }
        
        var urlComponents = URLComponents(string: url)
        var queryItems = [URLQueryItem]()
        
        if let params = params {
            for (key, value) in params  {
                let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                queryItems.append(URLQueryItem(name: key, value: encodedValue))
            }
        }
        
        var httpBody:Data?
        if let body = body{
            
            do {
                httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(nil, nil, NSError(domain: "Invalid body", code: 402, userInfo: nil))
                return
            }
            
            print("Body: \(body)")
        }
        
        urlComponents?.queryItems = queryItems
        
        
        guard let url = urlComponents?.url else {
            completion(nil, nil, nil)
            return
        }
        
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: cachePolicy,
                                    timeoutInterval: 30)
        
        urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = httpBody
        
        print("httpBody: \(httpBody)")
        
        print("urlRequest: \(urlRequest)")
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            completion(data, response as? HTTPURLResponse, error)
        }
        
        task.resume()
        
    }

    
}

struct HistoricTrade:Codable {
    var close:Double?
    var average:Double?
}
