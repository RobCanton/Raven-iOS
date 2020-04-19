//
//  TickerTapeView.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftTickerView

class TickerTapeView:UIView {
    
    fileprivate let labelIdentifier = "TextMessage"
    var tickerView:SwiftTickerView!
    let provider = TickerProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        tickerView = SwiftTickerView(frame: self.bounds)
        self.addSubview(tickerView)
        //tickerView.constraintToSuperview()
        tickerView.backgroundColor = UIColor.blue
        
        tickerView.contentProvider = provider
        tickerView.viewProvider = self
        tickerView.separator = "   "
        
        tickerView.render = Renderer.rightToLeft
        
        tickerView.registerNodeView(UILabel.self, for: labelIdentifier)
        tickerView.tickerDelegate = self
        tickerView.reloadData()
        tickerView.pixelPerSecond = 0.05
        tickerView.start()
    }
}

extension TickerTapeView: SwiftTickerDelegate {
    func tickerView(willResume ticker: SwiftTickerView) {}
    func tickerView(willStart ticker: SwiftTickerView) {}
    func tickerView(willStop ticker: SwiftTickerView) {}
    func tickerView(didPress view: UIView, content: Any?) {}
}

extension TickerTapeView: SwiftTickerViewProvider {
    func tickerView(_ tickerView: SwiftTickerView, prepareSeparator separator: UIView) {
        if let separator = separator as? UILabel {
            separator.textColor = .white
        }
    }

    func tickerView(_ tickerView: SwiftTickerView, viewFor: Any) -> (UIView, reuseIdentifier: String?) {
        if let text = viewFor as? String,
            let label = tickerView.dequeReusableNodeView(for: labelIdentifier) as? UILabel {
            label.text = text
            label.sizeToFit()
            label.textColor = .white
            return (label, reuseIdentifier: labelIdentifier)
        }
        return (UIView(), reuseIdentifier: nil)
    }
}


final class TickerProvider: SwiftTickerProviderProtocol {
    
    private let superContent = [["CODX", "GILD", "MDRN", "JNJ", "NFLX", "MSFT", "SPR", "BA"]]
    private var content: [String]
    private var contentIndex = 0
    private var index = 0
    
    init() {
        content = superContent[contentIndex]
    }
    
    var hasContent = true
    var next: Any {
        if index >= content.count {
            index = 0
        }
        let next = content[index]
        index += 1
        return next
    }
    
    func updateContent() {
        if !superContent.indices.contains(contentIndex) {
            index = 0
            contentIndex = 0
        }
        let next = superContent[contentIndex]
        contentIndex += 1
        index = 0
        content = next
    }
}

