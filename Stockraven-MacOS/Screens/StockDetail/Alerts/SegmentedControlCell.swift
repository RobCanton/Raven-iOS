//
//  SegmentedControlCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2019-08-19.
//  Copyright © 2019 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedControlCellDelegate:class {
    func segmentedControlCell(indexPath:IndexPath, didSelect index:Int)
}

class SegmentedControlCell:UITableViewCell {
    
    var segmentedControl:UISegmentedControl!
    
    weak var delegate:SegmentedControlCellDelegate?
    var indexPath:IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.selectionStyle = .none
        segmentedControl = UISegmentedControl(items: nil)
        
        contentView.addSubview(segmentedControl)
        segmentedControl.constraintToSuperview(12, 16, 12, 16, ignoreSafeArea: true)
        
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
    }
    
    
    @objc private func segmentedControlDidChange(_ target:UISegmentedControl) {
        guard let indexPath = indexPath else { return }
        delegate?.segmentedControlCell(indexPath: indexPath, didSelect: target.selectedSegmentIndex)
    }
    
    
    
    
}
