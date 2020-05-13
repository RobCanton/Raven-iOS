//
//  ResetCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-30.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ResetCell: UITableViewCell {
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        accessoryType = .disclosureIndicator
    }
    
}
