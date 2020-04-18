//
//  PolygonSearchViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-15.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol PolygonSearchDelegate {
    func searchDidSelect(_ ticker:PolygonTicker)
}

class PolygonSearchViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tickers = [PolygonTicker]()
    
    var tableView:UITableView!
    var tableBottomAnchor:NSLayoutConstraint!
    var headerView:UIView!
    var searchBar:UITextField!
    
    var delegate:PolygonSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        
        headerView = UIView()
        view.addSubview(headerView)
        headerView.constraintToSuperview(0, 0, nil, 0, ignoreSafeArea: false)
        headerView.backgroundColor = UIColor.secondarySystemGroupedBackground
        headerView.constraintHeight(to: 62)
        searchBar = UITextField()
        headerView.addSubview(searchBar)
        searchBar.constraintToSuperview(8, 16, 8, 16, ignoreSafeArea: true)
        searchBar.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
        searchBar.tintColor = .white
        searchBar.placeholder = "Search"
        searchBar.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        searchBar.autocapitalizationType = .allCharacters
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tableView.constraintToSuperview(nil, 0, nil, 0, ignoreSafeArea: false)
        tableBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableBottomAnchor.isActive = true
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        tableView.register(PredictionResultCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
            UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        delegate = nil
    }
    
    @objc func textDidChange(_ textField:UITextField) {
        guard let text = textField.text else { return }
        
        PolyravenAPI.search(text) { searchFragment, tickers in
            if searchFragment != textField.text {
                return
            }
            self.tickers = tickers
            self.tableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PredictionResultCell
        let ticker = tickers[indexPath.row]
        cell.titleLabel.text = ticker.symbol
        cell.subtitleLabel.text = "\(ticker.securityName) [\(ticker.exchange)]"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticker = tickers[indexPath.row]
        delegate?.searchDidSelect(ticker)
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        tableBottomAnchor.constant = -keyboardSize.height
        
        view.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        tableBottomAnchor.constant = 0
        view.layoutIfNeeded()
    }
}


