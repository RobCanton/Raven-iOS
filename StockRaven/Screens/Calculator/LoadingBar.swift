//
//  LoadingBar.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-31.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


class LoadingBar:UIView {
    
    var gradientView:UIView!
    var gradientLeadingAnchor:NSLayoutConstraint!
    var gradientWidth:CGFloat!
    var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    private func setup() {
        backgroundColor = Theme.current.primary
        
        gradientWidth = UIScreen.main.bounds.width
        
        gradientView = UIView()
        self.addSubview(gradientView)
        gradientView.constraintWidth(to: gradientWidth)
        gradientView.constraintToSuperview(0, nil, 0, nil, ignoreSafeArea: true)
        
        gradientLeadingAnchor = gradientView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -gradientWidth)
        gradientLeadingAnchor.isActive = true
        
        gradientView.backgroundColor = UIColor.clear
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: gradientWidth, height: 64)
        
        gradient.colors = [ UIColor.clear.cgColor,
                            Theme.current.secondary.cgColor,
                            Theme.current.secondary.cgColor,
                            UIColor.clear.cgColor ]
        gradient.locations = [0.0, 0.45, 0.55, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradientView.layer.addSublayer(gradient)
        
        self.alpha = 0.0
        
        
    }
    
    func startAnimating(recursive:Bool=false) {
        
        if recursive && !isAnimating {
            return
        }
        
        isAnimating = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1.0
        })
        
        UIView.animate(withDuration: 1.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.gradientLeadingAnchor.constant = self.gradientWidth
            self.layoutIfNeeded()
            
        }, completion: { _ in
            self.gradientLeadingAnchor.constant = -self.gradientWidth
            self.layoutIfNeeded()
            
            self.startAnimating(recursive: true)
        })
    }
    
    func stopAnimating() {
        isAnimating = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        })
        
    }
    
}
