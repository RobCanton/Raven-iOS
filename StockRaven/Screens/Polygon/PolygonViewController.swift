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
    
    
    var symbols = [PolygonStock]()
    var headerView:TickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = UINib(nibName: "TickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TickerView
        headerView.setup()
        //headerView.backgroundColor = UIColor.systemGroupedBackground
        
        
        
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
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let dateStr = dateFormatter.string(from: date)
        let dateButton = UIButton()
        dateButton.setTitle(dateStr, for: .normal)
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
        
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.symbols = StockManager.shared.stocks
        
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(stocksUpdated),
                                               name: Notification.Name(rawValue: "stocks-updated"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openSearch() {
        let vc = PolygonSearchViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func stocksUpdated() {
        self.symbols = StockManager.shared.stocks
        self.tableView.reloadData()
    }
    
}

extension PolygonViewController {//: UITableViewDelegate, UITableViewDataSource {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            
            StockManager.shared.unsubscribe(from: symbol)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = StockDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PolygonViewController:PolygonSearchDelegate {
    
    func searchDidSelect(_ ticker: PolygonTicker) {
        
        StockManager.shared.subscribe(to: ticker.symbol)
        
    }
}

