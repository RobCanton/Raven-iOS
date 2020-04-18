//
//  SymbolStatPairCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-26.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class SymbolStatDetailCell:UITableViewCell {
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        textLabel?.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        accessoryType = .disclosureIndicator
        backgroundColor = UIColor(hex: "1D1D1E")
        separatorInset = .zero
        
        detailTextLabel?.font = UIFont.monospacedSystemFont(ofSize: 15.0, weight: .regular)
    }
    
    func setSymbolStat(_ proxyComponent:ProxyComponent) {
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: proxyComponent.primary.string,
                                                 attributes: proxyComponent.primary.type.lightStyleAttributes))
        
        
        var statStr:String
        let split = proxyComponent.auxillary.string.split(separator: "@")
        if split.count == 2 {
            statStr = String(split[0])
            let dateStr = String(split[1])
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            
            if let date = dateFormatter.date(from: dateStr) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, yyyy"
                detailTextLabel?.text = displayFormatter.string(from: date)
                detailTextLabel?.textColor = .secondaryLabel
            } else {
                detailTextLabel?.text = "Invalid Date"
                detailTextLabel?.textColor = .systemRed
            }
            
        } else {
            statStr = proxyComponent.auxillary.string
            detailTextLabel?.text = "Live"
            detailTextLabel?.textColor = .systemPink
            
        }
        
        attributedText.append(NSAttributedString(string: statStr,
        attributes: proxyComponent.auxillary.type.lightStyleAttributes))
        
        textLabel?.attributedText = attributedText
        
        
        
    }
    
}
