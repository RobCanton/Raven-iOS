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
import SwiftUI

class PolygonViewController:UITableViewController {
    
    let screen = Screen.home
    
    var symbols = [PolygonStock]()
    var headerView:TagsHeaderView!
    var searchController:UISearchController!
    var searchResultsVC:TickerSearchResultsController!
    
    var resetMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //headerView = UINib(nibName: "TickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TickerView
        //headerView.setup()
        headerView = TagsHeaderView()
        
        view.backgroundColor = UIColor.systemGroupedBackground
        
        tabBarController?.tabBar.tintColor = UIColor.white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground//UIColor(white: 0.15, alpha: 1.0)//UIColor(hex: "5F5CFF")
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        appearance.shadowColor = UIColor.clear
        
        searchResultsVC = TickerSearchResultsController()
        searchResultsVC.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchBar.delegate = searchResultsVC
        searchController.searchBar.autocapitalizationType = .allCharacters
        searchController.searchBar.autocorrectionType = .no
        searchController.automaticallyShowsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["Stocks", "Forex", "Crypto"]
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.hidesNavigationBarDuringPresentation = true
        
        
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.tintColor = UIColor.label
        
        navigationController?.navigationBar.sizeToFit()
        navigationItem.title = "After Hours"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: nil, action: nil)
        
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
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        //tableView.delegate = self
        //tableView.dataSource = self
        
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.symbols = StockManager.shared.stocks
        
        tableView.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.post(.screenChanged, userInfo: ["screen": screen])
        NotificationCenter.addObserver(self, selector: #selector(stocksUpdated), type: .stocksUpdated)
        NotificationCenter.addObserver(self, selector: #selector(marketStatusUpdated), type: .marketStatusUpdated)
        
        NotificationCenter.addObserver(self, selector: #selector(toggleEdit), type: .action(screen, .edit))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleEdit() {
        //tableView.setEditing(!tableView.isEditing, animated: true)
        let editVC = EditWatchlistViewController()
        editVC.delegate = self
        let navVC = UINavigationController(rootViewController: editVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func stocksUpdated() {
        self.symbols = StockManager.shared.stocks
        self.tableView.reloadData()
    }
    
    @objc func marketStatusUpdated() {
        navigationItem.title = StockManager.shared.marketStatus.displayString
    }
    
}

extension PolygonViewController: UISearchControllerDelegate, TickerSearchDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        print("willPresentSearchController")
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 0.25
        })
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("willDismissSearchController")
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 1.0
        })
    }
    
    func tickerSearch(didSelect ticker: PolygonTicker) {
        StockManager.shared.subscribe(to: ticker.symbol)
        searchController.isActive = false   
    }
}

extension PolygonViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32 + 8
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resetMode ? 0 : symbols.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StockCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as? StockCell
        cell?.observe(symbols[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as? StockCell
        cell?.stopObserving()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        StockManager.shared.moveStock(at: sourceIndexPath.row, to: destinationIndexPath.row)
        self.symbols = StockManager.shared.stocks

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
        let vc = StockDetailViewController(stock: symbols[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PolygonViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}

extension PolygonViewController: EditWatchlistDelegate {
    func didEditWatchlist() {
        resetMode = true
        self.tableView.reloadData()
        //resetMode = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.resetMode = false
            self.stocksUpdated()
        }
        
        
    }
}
