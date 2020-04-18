//
//  FooterView.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-06.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class FooterView:UIView {
    
    var rightButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        rightButton = UIButton(type: .system)
        
        rightButton.setTitle("Add Item", for: .normal)
        rightButton.tintColor = Theme.current.primary
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        addSubview(rightButton)
        rightButton.constraintToSuperview(nil, nil, nil, 16, ignoreSafeArea: false)
        rightButton.constraintToCenter(axis: [.y])
        
        let divider = UIView()
        addSubview(divider)
        divider.constraintToSuperview(0, 0, nil, 0, ignoreSafeArea: true)
        divider.constraintHeight(to: 0.5)
        divider.backgroundColor = UIColor.separator
        
        self.backgroundColor = UIColor.secondarySystemGroupedBackground//.withAlphaComponent(0.92)
    }
}
