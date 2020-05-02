//
//  StockDetailViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-19.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import SwiftChart


class StockDetailViewController:UITableViewController {

    let screen = Screen.stock
    
    let stock:PolygonStock
    var alerts:[Alert]
    
    var descriptionCollapsed = true
    
    init(stock:PolygonStock) {
        self.stock = stock
        self.alerts = StockManager.shared.alerts(for: stock.symbol)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = stock.symbol
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.register(StockDetailCell.self, forCellReuseIdentifier: "stockCell")
        tableView.register(StockHeaderCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ChartCell.self, forCellReuseIdentifier: "chartCell")
        tableView.register(AlertSwitchCell.self, forCellReuseIdentifier: "alertCell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "titleCell")
        tableView.register(StockDescroptionCell.self, forCellReuseIdentifier: "descriptionCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.post(.screenChanged, userInfo: ["screen": screen])
        
        NotificationCenter.addObserver(self, selector: #selector(reloadAlerts), type: .alertsUpdated)
        NotificationCenter.addObserver(self, selector: #selector(newAlert), type: .action(screen, .add))
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func newAlert() {
        print("new alert:")
        let alertVC = AlertViewController(stock: stock)
        let nav = UINavigationController(rootViewController: alertVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func reloadAlerts() {
        self.alerts = StockManager.shared.alerts(for: stock.symbol)
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return alerts.count + 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockDetailCell
                cell.observe(stock)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! StockDescroptionCell
                cell.descriptionLabel.text = stock.details.description
                cell.setCollapsed(descriptionCollapsed)
                return cell
            default:
                break
            }
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
                cell.textLabel?.text = "Alerts"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: .semibold)
                return cell
            }
            let alert = alerts[indexPath.row-1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertSwitchCell
            cell.setAlert(alert)
            return cell
            
        default:
            break
        }
        
        let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
        return emptyCell
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                descriptionCollapsed.toggle()
                tableView.reloadRows(at: [indexPath], with: .automatic) 
                break
            default:
                break
            }
        case 1:
            if indexPath.row == 0 { return }
            let alert = alerts[indexPath.row-1]
            let alertVC = AlertViewController(stock: stock, alert: alert)
            let nav = UINavigationController(rootViewController: alertVC)
            self.present(nav, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
}

class ChartCell:UITableViewCell, ChartDelegate {
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    
    var chart:Chart!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        contentView.backgroundColor = UIColor.systemBackground
        //self.constraintHeight(to: 200)
        
        chart = Chart()
        self.addSubview(chart)
        chart.constraintToSuperview(0, 16, 0, 16, ignoreSafeArea: true)
        
        chart.tintColor = UIColor.label
        chart.gridColor = .clear
        chart.axesColor = .clear
        chart.delegate = self
        
        chart.highlightLineColor = UIColor(hex: "33E190")
        chart.lineWidth = 1.0
        chart.bottomInset = 0
        chart.topInset = 0
        chart.xLabels = nil
        chart.showXLabelsAndGrid = false
        chart.showYLabelsAndGrid = false
        chart.showsLargeContentViewer = false
        chart.alpha = 0.0
        
        
    }
    
    func populate(stock:PolygonStock) {
        PolyravenAPI.stockHistoricTrades(symbol: stock.symbol, date: "2020-04-20") { trades in
            var max:Double = 0
            var min:Double = .greatestFiniteMagnitude
            var points = [Double]()
            for t in trades {
                if let c = t.average {
                    if c > max {
                        max = c
                    }
                    if c < min {
                        min = c
                    }
                    points.append(c)
                }
            }
            self.chart.maxY = max * 1.075
            self.chart.minY = min - ((max - min) * 0.1)
            
            let series = ChartSeries(points)
            series.colors = (above: UIColor(hex: "33E190"), UIColor(hex: "33E190"), zeroLevel: 0)
            
            self.chart.add(series)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.chart.alpha = 1.0
            }, completion: nil)
        }
    }
}
