//
//  HomeViewController.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-11.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchController:UISearchController!
    
    var tableView:UITableView!
    var footerView:FooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemGroupedBackground
        searchController = UISearchController(searchResultsController: nil)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.secondarySystemGroupedBackground
        appearance.shadowImage = UIImage()
        
        
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Theme.current.primary
        
        navigationItem.title = "Watchlist"
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let rate = CurrencyManager.shared.rate(for: "USDCAD")
            print("Rate USDCAD: \(rate)")
            let rate2 = CurrencyManager.shared.rate(for: "CADUSD")
            print("Rate CADUSD: \(rate2)")
            
            let rate3 = CurrencyManager.shared.rate(for: "CADEUR")
            print("Rate CADEUR: \(rate3)")
            
            let rate4 = CurrencyManager.shared.rate(for: "EURCAD")
            print("Rate EURCAD: \(rate4)")
        })
        
        
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tableView.constraintToSuperview(0, 0, 52, 0, ignoreSafeArea: false)
        tableView.register(EquationTableViewCell.self, forCellReuseIdentifier: "equationCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.backgroundColor = UIColor.secondarySystemGroupedBackground
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.reloadData()
        
        footerView = FooterView()
        view.addSubview(footerView)
        footerView.constraintToSuperview(nil, 0, 0, 0, ignoreSafeArea: false)
        footerView.constraintHeight(to: 52)
        footerView.rightButton.addTarget(self, action: #selector(newEquation), for: .touchUpInside)
        
        let polygonIcon = UIBarButtonItem(image: UIImage(named: "mesh"), style: .plain, target: self, action: #selector(openPolygon))
        let personIcon = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItems = [
            polygonIcon,
            personIcon
        ]
        
        equationsUpdated()
        
        
        
    }
    
    @objc func openSettings() {
        let vc = SettingsViewController()
        //vc.modalPresentationStyle = .fullScreen
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openPolygon() {
        let vc = PolygonViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(equationsUpdated),
                                               name: Notification.Name("itemsUpdated"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func equationsUpdated() {
        self.tableView.reloadData()
    }
    
    @objc func newEquation() {
        let equationVC = EquationViewController()
        self.present(equationVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemManager.shared.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "equationCell", for: indexPath) as! EquationTableViewCell
        cell.setItem(ItemManager.shared.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = ItemManager.shared.items[indexPath.row]
        let equationVC = EquationViewController(item: item)
        
       // self.navigationController?.pushViewController(equationVC, animated: true)
        //let nav = UINavigationController(rootViewController: equationVC)
        self.present(equationVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movingItem = ItemManager.shared.items.remove(at: sourceIndexPath.row)
        ItemManager.shared.items.insert(movingItem, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = ItemManager.shared.items[indexPath.row]
            ItemManager.shared.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            RavenAPI.shared.removeItem(item)
        }
    }
    
}


extension HomeViewController: UITableViewDragDelegate, UITableViewDropDelegate {
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
