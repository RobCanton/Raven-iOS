//
//  SettingsViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-06.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController:UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Theme.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let theme = Theme.all[indexPath.row]
        cell.textLabel?.text = theme.displayName
        cell.textLabel?.textColor = theme.primary
        cell.contentView.backgroundColor = UIColor.secondarySystemGroupedBackground
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = Theme.all[indexPath.row]
        Theme.current = theme
        self.navigationController?.popViewController(animated: true)
    }
}
