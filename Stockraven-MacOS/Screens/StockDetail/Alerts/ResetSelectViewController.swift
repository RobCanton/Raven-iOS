//
//  ResetSelectionViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-30.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


protocol ResetSelectDelegate:class {
    func resetSelect(didSelect option:ResetDelay)
}

class ResetSelectViewController: UITableViewController {
    
    weak var delegate:ResetSelectDelegate?
    var selectedOption:Int?
    
    init(selectedOption:Int?=nil) {
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Reset"
        view.backgroundColor = UIColor.systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resetCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ResetDelay.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resetCell", for: indexPath)
        let resetDelay = ResetDelay.all[indexPath.row]
        cell.textLabel?.text = resetDelay.name
        cell.backgroundColor = UIColor.secondarySystemGroupedBackground
        cell.accessoryView?.tintColor = UIColor.white
        if let selectedOption = selectedOption,
            selectedOption == resetDelay.rawValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.resetSelect(didSelect: ResetDelay.all[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}
