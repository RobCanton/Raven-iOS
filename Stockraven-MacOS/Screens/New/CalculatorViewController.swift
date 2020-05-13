//
//  CalculatorViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-26.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class CalculatorViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contentView:UIView!
    var contentViewBottomAnchor:NSLayoutConstraint!
    var tableView:UITableView!
    var evaluate = false
    
    struct Test {
        var solved = false
    }
    var equations = [ Test() ]
    
    var activeEquationCell:CalculatorEquationCell? {
        return tableView.cellForRow(at: IndexPath(row: equations.count-1, section: 0)) as? CalculatorEquationCell
    }
    
    var results = [
        Symbol(exchange: "NAS", region: "US", securityName: "Apple", securityType: "", symbol: "AAPL"),
        Symbol(exchange: "NAS", region: "US", securityName: "Amazon", securityType: "", symbol: "AMZN"),
        Symbol(exchange: "NAS", region: "US", securityName: "Alphabet", securityType: "", symbol: "GOOG"),
        Symbol(exchange: "NAS", region: "US", securityName: "Advanced Micro Devices", securityType: "", symbol: "AMD"),
        Symbol(exchange: "NAS", region: "US", securityName: "American Airlines", securityType: "", symbol: "AA"),
        Symbol(exchange: "NAS", region: "US", securityName: "Boeing", securityType: "", symbol: "BA"),
        Symbol(exchange: "NAS", region: "US", securityName: "International Business Machines", securityType: "", symbol: "IBM"),
        Symbol(exchange: "NAS", region: "US", securityName: "TD Ameritrade", securityType: "", symbol: "TD"),
        Symbol(exchange: "NAS", region: "US", securityName: "Tesla", securityType: "", symbol: "TSLA")
    ]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView = UIView()
        view.addSubview(contentView)
        contentView.constraintToSuperview(0, 0, 0, 0, ignoreSafeArea: false)
        //contentViewBottomAnchor = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        //contentViewBottomAnchor.isActive = true
        
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        contentView.addSubview(tableView)
        tableView.constraintToSuperview(0, 0, 0, 0, ignoreSafeArea: true)
        tableView.backgroundColor = UIColor.secondarySystemGroupedBackground
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(CalculatorEquationCell.self, forCellReuseIdentifier: "equationCell")
        tableView.register(PredictionResultCell.self, forCellReuseIdentifier: "predictionsCell")
        tableView.tableHeaderView = UIView()
        //tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        
//        contentView = UIView()
//        view.addSubview(contentView)
//        contentView.constraintToSuperview(0, 0, nil, 0, ignoreSafeArea: false)
//        contentViewBottomAnchor = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
//        contentViewBottomAnchor.isActive = true
//        contentView.layer.borderColor = UIColor.systemYellow.cgColor
//        contentView.layer.borderWidth = 0.5
//
//        let scrollView = UIScrollView()
//        contentView.addSubview(scrollView)
//        scrollView.constraintToSuperview()
//        scrollView.layer.borderColor = UIColor.systemTeal.cgColor
//        scrollView.layer.borderWidth = 0.25
//
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 1.5)
//
//        let topPanel = UIView()
//        scrollView.addSubview(topPanel)
//        topPanel.frame = CGRect(x: 0, y: 0,
//                                width: view.bounds.width,
//                                height: view.bounds.height * 0.75)
//        //topPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true
//        topPanel.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.15)
        
        capitalView = UIImageView()
        capitalView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        contentView.addSubview(capitalView)
        capitalView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
            UIResponder.keyboardWillHideNotification, object: nil)
        
        let cell = tableView.cellForRow(at: IndexPath(row: equations.count-1, section: 0)) as? CalculatorEquationCell
        cell?.equationEditorView.textView.becomeFirstResponder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return equations.count
        }
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "predictionsCell", for: indexPath) as! PredictionResultCell
            let result = results[indexPath.row]
            cell.titleLabel?.text = result.symbol
            cell.subtitleLabel?.text = result.securityName
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "equationCell", for: indexPath) as! CalculatorEquationCell
        cell.equationEditorView.textView.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == equations.count-1 {
            if let equationCell = cell as? CalculatorEquationCell {
                print("become! : \(indexPath)")
                print("Height: \(cell.bounds.height)")
                equationCell.equationEditorView.textView.becomeFirstResponder()
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        return 52
    }
    
    var predictionsHeight:CGFloat = 0
    
    @objc func keyboardWillShow(notification:Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        //contentViewBottomAnchor.constant = -keyboardSize.height
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0,
                                                             width: tableView.bounds.width,
                                                             height: keyboardSize.height))
        }
        view.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        //contentViewBottomAnchor.constant = 0
        //view.layoutIfNeeded()
    }
    
    var capitalView:UIImageView!
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        let prev:CGFloat = CGFloat(max(equations.count - 1, 0)) * 52
        
        
        if offset > prev {
            if capitalView.isHidden {
                capitalView.isHidden = false
                for subview in capitalView.subviews {
                    subview.removeFromSuperview()
                }
//                let activeCell = tableView.cellForRow(at: IndexPath(row: equations.count-1, section: 0))
//                if let sc = activeCell?.snapshotView(afterScreenUpdates: false) {
//                    sc.frame = capitalView.bounds
//                    //capitalView.addSubview(sc)
//                }
                
                
            }
            
            capitalView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: view.bounds.width,
                                       height: 52)
        } else {
            capitalView.isHidden = true
        }
        
        
    }
}

extension CalculatorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            print("evaluate!")
            activeEquationCell?.equationEditorView.textView.resignFirstResponder()
            equations.append(Test())
            
            
            
//            /self.tableView.beginUpdates()
            //UIView.performWithoutAnimation {
            
            self.tableView.insertRows(at: [IndexPath(row: equations.count-1, section: 0)], with: .none)
//            self.tableView.performBatchUpdates({
//                self.tableView.insertRows(at: [IndexPath(row: equations.count-1, section: 0)], with: .none)
//            }, completion: { _ in
//                let offset = self.tableView.contentSize.height - self.view.bounds.height - 56.5 * 3
//                print("offset: \(offset)")
//                self.tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
//            })
            let offset = self.tableView.contentSize.height - self.view.bounds.height - 56.5 * 3 - 20
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
            
            
                //self.tableView.endUpdates()
                //self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                
                var row = 0
                if self.equations.count >= 3 {
                    row = self.equations.count - 3
                }
                
            
            
                
                
           //}
            
             
            
            
           
            
            
            
            return false
        }
        
        return true
    }
}


class CalculatorEquationCell:UITableViewCell {
    
    var equationEditorView:EquationEditorView!
    
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
        equationEditorView = EquationEditorView()
        contentView.addSubview(equationEditorView)
        equationEditorView.constraintToSuperview()
    }
    
//    func updateSyntax(for components:[Component]) {
//
//        let attributedText = NSMutableAttributedString()
//
//        for component in components {
//            attributedText.append(NSAttributedString(string: component.string, attributes: component.type.styleAttributes))
//        }
//
//        textView.attributedText = attributedText
//    }
}

class EquationEditorView:UIView {
    
    var textView:UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        textView = UITextView()
        self.addSubview(textView)
        textView.constraintToSuperview(8, 12, 8, 12, ignoreSafeArea: true)
        //textView.constraintToCenter(axis: [.y])
        textView.font = UIFont.monospacedSystemFont(ofSize: 20.0, weight: .regular)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.clear
        textView.tintColor = UIColor.white
        textView.isScrollEnabled = false
        textView.keyboardType = .asciiCapable
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .allCharacters
        textView.tintColor = UIColor.label
        textView.returnKeyType = .done
        self.backgroundColor = UIColor.secondarySystemFill
        
    }
    
    
}
