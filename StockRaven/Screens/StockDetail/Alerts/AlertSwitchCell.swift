//
//  AlertSwitchCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2019-08-20.
//  Copyright © 2019 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class AlertSwitchCell:UITableViewCell {
    
    var alert:Alert?
    var switchView:UISwitch!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        //self.selectionStyle = .none
        
        switchView = UISwitch()
        contentView.addSubview(switchView)
        switchView.constraintToSuperview(nil, nil, nil, 16, ignoreSafeArea: true)
        switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switchView.onTintColor = Theme.current.primary
        
        switchView.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
    }
    
    func setAlert(_ alert:Alert) {
        self.alert = alert
        textLabel?.text = alert.stringRepresentation
        switchView.isOn = alert.enabled > 0 ? true : false
    }
    
    @objc func handleSwitch() {
        guard let alert = self.alert else { return }
        var editable = alert.editable
        editable.enabled = switchView.isOn ? 1 : 0
        PolyravenAPI.patchAlert(editable) { _alert in
            if _alert != nil {
                StockManager.shared.updateAlert(_alert!)
            }
        }
    }
    
    
}
