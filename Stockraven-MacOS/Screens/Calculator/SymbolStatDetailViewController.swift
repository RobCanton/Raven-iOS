//
//  SymbolStatDetailViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-26.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

enum StatUpdateMode {
    case live
    case historical(dateStr:String)
    
}

protocol SymbolStatDetailDelegate:class {
    func symbolStatDetailUpdate(_ proxy:ProxyComponent)
}

class SymbolStatDetailViewController:UITableViewController {
    
    var index:Int
    var proxyComponent:ProxyComponent
    var date:Date
    
    weak var delegate:SymbolStatDetailDelegate?
    
    init(index:Int, proxyComponent:ProxyComponent) {
        self.index = index
        self.proxyComponent = proxyComponent
        
        
        
        switch proxyComponent.updateMode {
        case let .historical(dateStr):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            self.date = dateFormatter.date(from: dateStr) ?? Date()
            break
        default:
            self.date = Date()
            break
        }
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    var liveCell:UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 1, section: 0))
    }
    
    var historicalCell:UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 1))
    }
    
    var datePickerCell:DatePickerCell? {
        return tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? DatePickerCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "emptyCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "basicCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "datePickerCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hex: "161617")
        
        datePickerCell?.datePicker.date = date
        datePickerCell?.datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.symbolStatDetailUpdate(proxyComponent)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            switch proxyComponent.updateMode {
            case .historical:
                return 2
            default:
                return 1
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                cell.textLabel?.text = "Live"
                cell.separatorInset = .zero
                cell.tintColor = .systemPink
                cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
                switch proxyComponent.updateMode {
                case .live:
                    cell.accessoryType = .checkmark
                    cell.textLabel?.textColor = UIColor.systemPink
                    break
                default:
                    cell.accessoryType = .none
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                    break
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
                return cell
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                cell.textLabel?.text = "Historical"
                cell.tintColor = .systemPink
                cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
                switch proxyComponent.updateMode {
                case .historical:
                    cell.accessoryType = .checkmark
                    cell.textLabel?.textColor = UIColor.systemPink
                    break
                default:
                    cell.accessoryType = .none
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                    break
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerCell
                cell.separatorInset = .zero
                return cell
            default:
                break
            }
            break
        default:
            break
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 1 {
            switch proxyComponent.updateMode {
            case .live:
                return
            default:
                break
            }
            proxyComponent.updateMode = .live
            liveCell?.accessoryType = .checkmark
            liveCell?.textLabel?.textColor = UIColor.systemPink
            
            historicalCell?.accessoryType = .none
            historicalCell?.textLabel?.textColor = UIColor.secondaryLabel
            
            tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            switch proxyComponent.updateMode {
            case .historical:
                return
            default:
                break
            }
            
            historicalCell?.accessoryType = .checkmark
            historicalCell?.textLabel?.textColor = UIColor.systemPink
            
            liveCell?.accessoryType = .none
            liveCell?.textLabel?.textColor = UIColor.secondaryLabel
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            proxyComponent.updateMode = .historical(dateStr: dateFormatter.string(from: date))
            
            tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
            
            
        }
        
        
        
        
    }
    
    @objc func datePickerDidChange(_ datePicker:UIDatePicker) {
        self.date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        proxyComponent.updateMode = .historical(dateStr: dateFormatter.string(from: date))
    }
}




class DatePickerCell:UITableViewCell {
    
    var datePicker:UIDatePicker!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        datePicker = UIDatePicker()
        contentView.addSubview(datePicker)
        datePicker.constraintToSuperview()
        datePicker.datePickerMode = .date
        datePicker.constraintHeight(to: 216)
        datePicker.maximumDate = Date.yesterday        
        
    }
    
}

