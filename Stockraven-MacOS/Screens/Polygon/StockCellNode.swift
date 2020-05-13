//
//  StockCellNode.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-28.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class StockCellNode:ASCellNode {
    
    let symbolTextNode = ASTextNode()
    let priceTextNode = ASTextNode()
    let bidAskTextNode = ASTextNode()
    
    let stock:PolygonStock
    
    init(stock:PolygonStock) {
        self.stock = stock
        super.init()
        self.automaticallyManagesSubnodes = true
        
        symbolTextNode.attributedText = NSAttributedString(string: stock.symbol, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ])
        
        priceTextNode.attributedText = NSAttributedString(string: "\(stock.lastTrade?.price ?? 0)", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .semibold)
        ])
        
        bidAskTextNode.attributedText = NSAttributedString(string: "\(stock.lastTrade?.price ?? 0)", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let mainVStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 6.0,
                                           justifyContent: .start,
                                           alignItems: .start,
                                           children: [symbolTextNode,
                                                      priceTextNode,
                                                      bidAskTextNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), child: mainVStack)
    }
    
    override func didEnterVisibleState() {
        super.didEnterVisibleState()
        print("\(stock.symbol) - Enter")
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.addObserver(self, selector: #selector(stockDidUpdateTrade), type: .stockTradeUpdated(stock.symbol))
        NotificationCenter.addObserver(self, selector: #selector(stockDidUpdateQuote), type: .stockTradeUpdated(stock.symbol))
    }
    
    override func didExitVisibleState() {
        super.didExitVisibleState()
        print("\(stock.symbol) - Exit")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func stockDidUpdateTrade(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let _stock = userInfo["stock"] as? PolygonStock else { return }

        if let lastTrade = _stock.lastTrade {
//            self.priceLabel?.text = "\(lastTrade.price)"
            priceTextNode.attributedText = NSAttributedString(string: "\(lastTrade.price)", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .semibold)
            ])
        }
        
       
        
    }
    
    @objc func stockDidUpdateQuote(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let _stock = userInfo["stock"] as? PolygonStock else { return }
        
    }
    
    
}


