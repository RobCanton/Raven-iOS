//
//  EquationTableViewCell.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-12.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class EquationTableViewCell: UITableViewCell {
    
    var item:Item?
    var titleLabel:UILabel!
    var equationLabel:UILabel!
    var evaluationLabel:UILabel!
    var timeLabel:UILabel!
    var tagsView:TagsView!
    var stackView:UIStackView!
    
    
    
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
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        stackView = UIStackView()
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.constraintToSuperview(16, 16, 16, 16, ignoreSafeArea: true)
        stackView.spacing = 10
        
        titleLabel = UILabel()
        stackView.addArrangedSubview(titleLabel)
        titleLabel.text = "mediumrisk"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .light)
        titleLabel.textColor = UIColor.secondaryLabel
        
       
        
        
        equationLabel = UILabel()
        stackView.addArrangedSubview(equationLabel)
        equationLabel.text = "NFLX:volume * 25 + 9.99"
        equationLabel.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        equationLabel.numberOfLines = 2
        
        evaluationLabel = UILabel()
        //stackView.addArrangedSubview(evaluationLabel)
        evaluationLabel.text = "317.85"
        evaluationLabel.font = UIFont.monospacedSystemFont(ofSize: 26, weight: .bold)
        evaluationLabel.textColor = UIColor.label
        evaluationLabel.numberOfLines = 0
        evaluationLabel.textAlignment = .left
        
        evaluationLabel.text = "-"
        stackView.addArrangedSubview(evaluationLabel)
        
        timeLabel = UILabel()
        timeLabel.text = "Updated at 4:00pm"
        //timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .light)
        timeLabel.textColor = UIColor.secondaryLabel
        stackView.addArrangedSubview(timeLabel)
        
        tagsView = TagsView()
        tagsView.isUserInteractionEnabled = false
        
    }
    
    func setItem(_ item:Item) {
        
        
        self.item = item
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(itemUpdated),
                                               name: Notification.Name("itemUpdated-\(item.id)"), object: nil)
        
        let equation = item.equation
        let attributedText = NSMutableAttributedString()
        for component in equation.components {
            attributedText.append(NSAttributedString(string: component.string,
                                                     attributes: component.type.lightStyleAttributes))
        }
        equationLabel.attributedText = attributedText
        
        if let evaluation = item.evaluation {
            let valueStr = NumberFormatter.localizedString(from: NSNumber(value: evaluation.value),
                                                           number: NumberFormatter.Style.decimal)
            evaluationLabel.text = valueStr
        } else {
            evaluationLabel.text = "-"
        }
        
        if let name = item.details.name, !name.isEmpty {
            titleLabel.text = name
            stackView.insertArrangedSubview(titleLabel, at: 0)
        } else {
            titleLabel.removeFromSuperview()
        }
        
        if let date = item.evaluation?.date {
            print("Date: \(date)")
            timeLabel.text = date.UTCToLocalStr
            
            //sstackView.addArrangedSubview(timeLabel)
        } else {
            print("No Date")
//            timeLabel.removeFromSuperview()
        }
        
        
        if item.details.tags.count > 0 {
            tagsView.setTags(item.details.tags)
            stackView.addArrangedSubview(tagsView)
        } else {
            tagsView.removeFromSuperview()
        }
        
        self.layoutIfNeeded()
    
    }
    
    @objc func itemUpdated(_ notification:Notification) {

        guard let item = notification.userInfo?["item"] as? Item else { return }
        setItem(item)
    }
    
    
    
}
