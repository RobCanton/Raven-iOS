//
//  EditWatchlistViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-28.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol EditWatchlistDelegate {
    func didEditWatchlist()
}

class EditWatchlistViewController:UITableViewController {
    
    var delegate:EditWatchlistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Watchlist"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        
        tableView.backgroundColor = UIColor.secondarySystemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.setEditing(true, animated: false)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        delegate?.didEditWatchlist()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StockManager.shared.stocks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = StockManager.shared.stocks[indexPath.row].symbol
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        StockManager.shared.moveStock(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let symbol = StockManager.shared.stocks[indexPath.row].symbol
            StockManager.shared.unsubscribe(from: symbol)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
