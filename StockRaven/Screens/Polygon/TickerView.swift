//
//  TickerView.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import UIKit
import SwiftTickerView

class TickerView: UIView {

    fileprivate let labelIdentifier = "TextMessage"
    
    let provider = TickerProvider()
    
    @IBOutlet weak var tickerTapeView: SwiftTickerView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setup() {
        self.backgroundColor = UIColor.systemGroupedBackground
        tickerTapeView.backgroundColor = UIColor.clear
        
        tickerTapeView.contentProvider = provider
        tickerTapeView.viewProvider = self
        tickerTapeView.separator = "  "
        
        tickerTapeView.render = Renderer.rightToLeft
        
        tickerTapeView.registerNodeView(UILabel.self, for: labelIdentifier)
        tickerTapeView.tickerDelegate = self
        tickerTapeView.reloadData()
        tickerTapeView.start()
        let divider = UIView()
        addSubview(divider)
        divider.constraintToSuperview(nil, 0, 0, 0, ignoreSafeArea: true)
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        divider.backgroundColor = UIColor.separator
    }

}

extension TickerView: SwiftTickerDelegate {
    func tickerView(willResume ticker: SwiftTickerView) {}
    func tickerView(willStart ticker: SwiftTickerView) {}
    func tickerView(willStop ticker: SwiftTickerView) {}
    func tickerView(didPress view: UIView, content: Any?) {
        
    }
}

extension TickerView: SwiftTickerViewProvider {
    func tickerView(_ tickerView: SwiftTickerView, prepareSeparator separator: UIView) {
        if let separator = separator as? UILabel {
            separator.textColor = .white
        }
    }

    func tickerView(_ tickerView: SwiftTickerView, viewFor: Any) -> (UIView, reuseIdentifier: String?) {
        if let text = viewFor as? String,
            let label = tickerView.dequeReusableNodeView(for: labelIdentifier) as? UILabel {
            let attributedText = NSMutableAttributedString()
            let at = [
                NSAttributedString(string: text, attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.label,
                    NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 17, weight: .medium)
                ]),
                NSAttributedString(string: " ", attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.clear,
                    NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
                ]),
                NSAttributedString(string: "5.54%", attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "33E190"),
                    NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
                ])
            ]
            for a in at {
                attributedText.append(a)
            }
            label.attributedText = attributedText
            label.sizeToFit()
            
            return (label, reuseIdentifier: labelIdentifier)
        }
        return (UIView(), reuseIdentifier: nil)
    }
}

class TickerCell:UIView {
    
    var titleLabel:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.yellow
        titleLabel = UILabel()
        addSubview(titleLabel)
    }
    
}
