//
//  PolygonAPI.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-15.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

enum HTTPMethod {
    case get, post, put, patch ,delete
}

class PolyravenAPI {

    static let shared = PolyravenAPI()
    
    static let host = "http://replicode.io:3000/"
    
    enum Endpoint:String {
        case watchlist = "user/watchlist"
        case search = "search"
        case subscribe = "subscribe"
        case unsubscribe = "unsubscribe"
        case registerPushToken = "user/pushtoken"
    }
    
    private static func getURL(for endpoint:Endpoint) -> String {
        return "\(PolyravenAPI.host)\(endpoint.rawValue)"
    }
    
    static private let session = URLSession.shared
    
    static var authToken:String?

    private init() {
    
    }
    
    static func search(_ text:String, completion: @escaping ((_ searchFragment:String, _ tickers:[PolygonTicker])->())) {
        
        if text.isEmpty {
            completion(text, [])
            return
        }
        
        let url = getURL(for: .search)
        
        let params:[String:Any] = [
            "fragment": text
        ]
        
        authenticatedRequest(.get, url: url, params: params, cachePolicy: .returnCacheDataElseLoad) { data, response, error in
            var tickers = [PolygonTicker]()
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("JSON: \(json)")
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
    
    static func getWatchlist(completion: @escaping ((_ stocks:[PolygonStock])->())) {
        
        let url = getURL(for: .watchlist)
        
        authenticatedRequest(.get, url: url) { data, response, error in
            var stocks = [PolygonStock]()
            
            if let data = data {
                do {
                    stocks = try JSONDecoder().decode([PolygonStock].self, from: data)
                } catch {
                    print("Error: \(error.localizedDescription)")
                    
                }
            }
            
            DispatchQueue.main.async {
                completion(stocks)
            }
        }
        
    }
    
    static func subscribe(to ticker:String, completion: @escaping ((_ stock:PolygonStock?)->())) {
        let url = getURL(for: .subscribe)
        let params:[String:Any] = [
            "ticker": ticker
        ]
        
        struct SubscribeResponse:Codable {
            let subscribed:Bool
            let ticker:PolygonStock
        }
        
        authenticatedRequest(.get, url: url, params: params) { data, response, error in
            var stock:PolygonStock?
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("JSON: \(json)")
                    
                    let response = try JSONDecoder().decode(SubscribeResponse.self, from: data)
                    stock = response.ticker
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        
            DispatchQueue.main.async {
                completion(stock)
            }
        }
    }
    
    static func unsubscribe(from ticker:String, completion: @escaping (()->())) {
        let url = getURL(for: .unsubscribe)
        let params:[String:Any] = [
            "ticker": ticker
        ]
        
        authenticatedRequest(.get, url: url, params: params) { data, response, error in
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    static func registerPushToken(token:String) {
        let url = getURL(for: .registerPushToken)
        let params:[String:Any] = [
            "token": token
        ]
        
        authenticatedRequest(.post, url: url, params: params) { data, response, error in
            
        }
    }
    
    
    
    
    
    
    
    
    
    private static func authenticatedRequest(_ method:HTTPMethod,
                                             url:String,
                                             params:[String:Any]? = nil,
                                             cachePolicy:URLRequest.CachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData,
                                             completion: @escaping ((_ data:Data?, _ response:HTTPURLResponse?, _ error:Error?)->())) {
        
        guard let token = authToken else {
            completion(nil, nil, nil)
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
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            completion(nil, nil, nil)
            return
        }
        
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: cachePolicy,
                                    timeoutInterval: 30)
        
        urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            completion(data, response as? HTTPURLResponse, error)
        }
        
        task.resume()
        
    }
    
}
