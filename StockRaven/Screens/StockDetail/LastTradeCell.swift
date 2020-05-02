//
//  LastTradeCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class LastTradeCell:UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
    }
}
