//
//  StockDescriptionCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class StockDescroptionCell:UITableViewCell {
    
    var titleLabel:UILabel!
    var descriptionLabel:UILabel!
    
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
        titleLabel.text = "Description"
        titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "Description"
        descriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        descriptionLabel.numberOfLines = 2
        
        contentView.addSubview(titleLabel)
        titleLabel.constraintToSuperview(16, 16, nil, 16, ignoreSafeArea: true)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.constraintToSuperview(nil, 16, 16, 16, ignoreSafeArea: true)
        
        titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8).isActive = true
    }
    
    func setCollapsed(_ collapsed:Bool) {
        descriptionLabel.numberOfLines = collapsed ? 2 : 0
    }
}
