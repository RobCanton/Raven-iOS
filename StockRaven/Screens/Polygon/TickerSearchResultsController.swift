//
//  TickerSearchResultsController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-05-01.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol TickerSearchDelegate {
    func tickerSearch(didSelect ticker:PolygonTicker)
}

class TickerSearchResultsController: UITableViewController, UISearchBarDelegate {
    
    var tickers = [PolygonTicker]()
    
    var delegate:TickerSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        tableView.register(PredictionResultCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        PolyravenAPI.search(searchText) { searchFragment, tickers in
            if searchFragment != searchBar.text {
                return
            }
            self.tickers = tickers
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PredictionResultCell
        let ticker = tickers[indexPath.row]
        cell.titleLabel.text = ticker.symbol
        cell.subtitleLabel.text = "\(ticker.securityName) [\(ticker.exchange)]"
        cell.backgroundColor = UIColor.systemBackground
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticker = tickers[indexPath.row]
        delegate?.tickerSearch(didSelect: ticker)
        tableView.deselectRow(at: indexPath, animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
 
}
