//
//  PolygonViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-13.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SocketIO

class PolygonViewController:UITableViewController {
    
    //var tableView:UITableView!
    
    var symbols = [PolygonStock]()
    
    let manager = SocketManager(socketURL: URL(string: "http://replicode.io:3000")!, config: [.log(false), .compress])
    var searchVC:PolygonSearchViewController!
    
    var socket:SocketIOClient!
    func connect() {
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        
        socket.on("welcome") { data, ack in
            print("I have been welcomed!")
        }
        
        for symbol in symbols {
            let ticker = symbol.symbol
            self.socket.on("T.\(ticker)") { data, ack in
                if let first = data.first as? [String:Any] {
                    NotificationCenter.default.post(name: .init("T.\(ticker)"), object: nil, userInfo: first)
                }
            }
            
            self.socket.on("Q.\(ticker)") { data, ack in
                if let first = data.first as? [String:Any] {
                    NotificationCenter.default.post(name: .init("Q.\(ticker)"), object: nil, userInfo: first)
                }
            }
        }

        socket.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemGroupedBackground
        
        tabBarController?.tabBar.tintColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "5F5CFF")
        appearance.shadowImage = UIImage()
        
        
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.label
        
        navigationItem.title = "Market Open"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openSearch))
        
        //self.extendedLayoutIncludesOpaqueBars = true
        
        let dateButton = UIButton()
        dateButton.setTitle("April 16", for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        //tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = UIColor.systemGroupedBackground
        //view.addSubview(tableView)
        //tableView.constraintToSuperview()
        tableView.register(StockCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        //tableView.delegate = self
        //tableView.dataSource = self
        tableView.reloadData()
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        PolyravenAPI.getWatchlist { stocks in
            self.symbols = stocks
            self.tableView.reloadData()
            self.connect()
        }
        
        
    }
    
    @objc func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openSearch() {
        let vc = PolygonSearchViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension PolygonViewController {//: UITableViewDelegate, UITableViewDataSource {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StockCell
        cell.observe(symbols[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ticker = symbols[indexPath.row]
            symbols.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let symbol = ticker.symbol
            PolyravenAPI.unsubscribe(from: symbol) {
                self.socket.off("T.\(symbol)")
                self.socket.off("Q.\(symbol)")
            }
        }
    }
}

extension PolygonViewController:PolygonSearchDelegate {
    
    func searchDidSelect(_ ticker: PolygonTicker) {
        
        PolyravenAPI.subscribe(to: ticker.symbol) { stock in
            guard let stock = stock else { return }
            self.symbols.append(stock)
            self.tableView.reloadData()
            self.socket.on("T.\(stock.symbol)") { data, ack in
                if let first = data.first as? [String:Any] {
                    NotificationCenter.default.post(name: .init("T.\(stock.symbol)"), object: nil, userInfo: first)
                }
            }
            
            self.socket.on("Q.\(stock.symbol)") { data, ack in
                if let first = data.first as? [String:Any] {
                    NotificationCenter.default.post(name: .init("Q.\(stock.symbol)"), object: nil, userInfo: first)
                }
            }
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
    /*
     
     let change = lastTrade.price - previousClose.close
     let changeFormatted = NumberFormatter.localizedString(from: NSNumber(value: change),
                                                           number: NumberFormatter.Style.decimal)
     
     let changePercent = abs( change / previousClose.close )
     let changePercentFormatted = NumberFormatter.localizedString(from: NSNumber(value: changePercent),
                                                                  number: NumberFormatter.Style.decimal)
     var str = change > 0 ? "+\(changeFormatted)" : changeFormatted
     
     str += " (\(changePercentFormatted)%)"
     
     */
    
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



