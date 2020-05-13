//
//  DeleteCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-28.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class DeleteCell:UITableViewCell {
    
    var titleLabel:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        titleLabel = UILabel()
        
        contentView.addSubview(titleLabel)
        titleLabel.constraintToSuperview(16, 16, 16, 16, ignoreSafeArea: true)
        titleLabel.textColor = UIColor.systemRed
        titleLabel.textAlignment = .center
        titleLabel.text = "Delete"
    }
}

