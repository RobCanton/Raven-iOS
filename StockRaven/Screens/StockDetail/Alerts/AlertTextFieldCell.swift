//
//  AlertTextFieldCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2019-08-20.
//  Copyright © 2019 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol AlertTextFieldCellDelegate:class {
    func alertTextFieldCell(indexPath:IndexPath, didTextChange text:String?)
}

class AlertTextFieldCell:UITableViewCell, UITextFieldDelegate {
    
    var textField:UITextField!
    var label:UILabel!
    
    var indexPath:IndexPath?
    weak var delegate:AlertTextFieldCellDelegate?
    
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
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)//.regularFont(ofSize: 17.0)
        label.textColor = UIColor.label
        label.textAlignment = .left
        contentView.addSubview(label)
        label.constraintToSuperview(nil, 16, nil, nil, ignoreSafeArea: true)
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        //label.widthAnchor.constraint(equalToConstant: 72.0).isActive = true
        
        textField = UITextField()
        contentView.addSubview(textField)
        textField.constraintToSuperview(12, nil, 12, 16, ignoreSafeArea: true)
        textField.textColor = UIColor.label
        textField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textField.textAlignment = .right
        
        
        textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8.0).isActive = true
        textField.isUserInteractionEnabled = false
        textField.delegate = self
       
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        
        textField.keyboardType = .decimalPad
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Ended")
        textField.isUserInteractionEnabled = false
    }
    
    @objc func handleTextChange(_ textField:UITextField) {
        guard let indexPath = indexPath else { return }
        delegate?.alertTextFieldCell(indexPath: indexPath, didTextChange: textField.text)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newCharacters = CharacterSet(charactersIn: string)

        let boolIsNumber = NSCharacterSet.decimalDigits.isSuperset(of: newCharacters)
        if boolIsNumber == true {
            return true
        } else {
            if string == "." {

                let countdots = (textField.text!.components(separatedBy: ".") as AnyObject).count - 1
                if countdots == 0 {
                    return true
                } else {
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            } else {
                return false
            }
        }
    }
    
    
    
}
