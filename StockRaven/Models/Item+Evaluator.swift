//
//  Item+Evaluation.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

extension Item: EvaluatorDelegate {
    
    func evaluate() {
        let evaluator = Evaluator(equation: self.equation, delegate: self)
        evaluator.solve()
    }
    
    internal func evaluatorDidStart() {
        print("didStart")
    }
    
    internal mutating func evaluatorDidComplete(withResult result: Evaluation) {
        print("evaluatorDidComplete withResult: \(result)")
        //delegate?.itemEquationDidUpdate()
        self.evaluation = result
        NotificationCenter.default.post(name: Notification.Name("itemUpdated-\(id)"), object: nil, userInfo: [
            "item": self
        ])
        
        RavenAPI.shared.saveItem(self) { error in
            print("didSaveItem withError: \(error?.localizedDescription ?? "nil")")
            if error == nil {
                
            }
        }
    }
    
    internal func evaluatorDidFail(withError error: Error) {
        print("evaluatorDidFail withError: \(error.localizedDescription)")
    }
}
