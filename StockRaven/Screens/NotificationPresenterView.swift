//
//  NotificationPresenterView.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-05-01.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class NotificationPresenterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        //self.backgroundColor = UIColor.systemPink.withAlphaComponent(0.25)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.presentNotification()
        })
        
    }
    
    func presentNotification() {
        
        let banner = NotificationBannerView()
        addSubview(banner)
        banner.constraintToSuperview(nil, 0, nil, 0, ignoreSafeArea: false)
        banner.heightAnchor.constraint(equalToConstant: 44 + 20).isActive = true
        
        let bottomAnchor = banner.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 49)
        bottomAnchor.isActive = true
        
        self.layoutIfNeeded()
        
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: Easings.Cubic.easeOut)
        animator.addAnimations {
            bottomAnchor.constant = 20
            self.layoutIfNeeded()
        }
        
        animator.startAnimation()
        /*
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4, options: .curveEaseOut, animations: {
            bottomAnchor.constant = 20
            self.layoutIfNeeded()
        }, completion: nil)*/
        
    }
}

class NotificationBannerView:UIView {
    
    var stackView:UIStackView!
    var titleLabel:UILabel!
    var subtitleLabel:UILabel!
    var valueLabel:UILabel!
    var accessoryIconView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = Theme.current.primary
        
        let contentView = UIView()
        addSubview(contentView)
        contentView.constraintToSuperview(0, 0, 20, 0, ignoreSafeArea: false)
        /*stackView = UIStackView()
        addSubview(stackView)
        stackView.constraintToSuperview(8, 16, 8, 12, ignoreSafeArea: false)
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillProportionally*/
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.text = "TSLA"
        contentView.addSubview(titleLabel)
        titleLabel.constraintToCenter(axis: [.y])
        titleLabel.constraintToSuperview(nil, 16, nil, nil, ignoreSafeArea: false)
        
        //stackView.addArrangedSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.text = "price over 700"
        contentView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8).isActive = true
        
        //stackView.addArrangedSubview(subtitleLabel)
        
        
        valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.text = "↗  712.55"
        contentView.addSubview(valueLabel)
        valueLabel.constraintToCenter(axis: [.y])
        valueLabel.constraintToSuperview(nil, nil, nil, 16, ignoreSafeArea: false)
        
        
    }
}
