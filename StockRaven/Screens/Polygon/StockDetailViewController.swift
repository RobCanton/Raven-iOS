//
//  StockDetailViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-19.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class StockDetailViewController:UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
    }
}
