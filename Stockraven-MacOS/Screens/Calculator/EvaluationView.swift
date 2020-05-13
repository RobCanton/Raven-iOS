//
//  EvaluationView.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-07.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class EvaluationView: UIView {
    
    private var valueLabel:UILabel!
    //private var loadingBar:GradientActivityIndicatorView!
    static let loadingBarHeight:CGFloat = 2
    
    var loadingBar:LoadingBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.secondarySystemGroupedBackground
        
        valueLabel = UILabel()
        valueLabel.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .medium)
        valueLabel.textColor = Theme.current.primary
        addSubview(valueLabel)
        valueLabel.constraintToSuperview(8, 12, 8, 12, ignoreSafeArea: false)
        valueLabel.textAlignment = .right
        valueLabel.alpha = 0.0
        
        loadingBar = LoadingBar()
        
        addSubview(loadingBar)
        loadingBar.constraintToSuperview(nil, 0, 0, 0, ignoreSafeArea: true)
        loadingBar.constraintHeight(to: EvaluationView.loadingBarHeight)
        loadingBar.alpha = 0.0
        
    }
    
    var isSolving = false
    func startSolving() {
        
        self.isSolving = false
        self.valueLabel.alpha = 0.0
        self.loadingBar.startAnimating()
        
    }
    
    func setEvaluation(_ evaluation: Evaluation) {                                          
        valueLabel.text = evaluation.displayString
        
        self.loadingBar.stopAnimating()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.valueLabel.alpha = 1.0
        }, completion: nil)
        
    }
    
    func setError(_ error: Error) {
        let _error = error as NSError
        valueLabel.text = "N/A"
        valueLabel.text = _error.description//error.localizedDescription
        
        self.loadingBar.stopAnimating()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.valueLabel.alpha = 1.0
        }, completion: nil)
    }
    
    func hide() {
        isSolving = false
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.valueLabel.alpha = 0.0
        }, completion: nil)
    }
    
}
