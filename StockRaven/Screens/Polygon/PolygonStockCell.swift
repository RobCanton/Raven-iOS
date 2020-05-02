//
//  PolygonStockCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-16.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class StockCell:UITableViewCell {
    
    var stock:PolygonStock?
    
    var priceLabel:UILabel!
    var tickerLabel:UILabel!
    var nameLabel:UILabel!
    var bidAskLabel:UILabel!
    var timeLabel:UILabel!
    var changeLabel:UILabel!
    var marketCapLabel:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let stackView = UIStackView()
        contentView.addSubview(stackView)
        stackView.constraintToSuperview(12, 16, 12, 16, ignoreSafeArea: true)
        stackView.axis = .vertical
        stackView.spacing = 1
        
        let titleView = UIView()
        
        tickerLabel = UILabel()
        tickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)//monospacedSystemFont(ofSize: 18, weight: .medium)
        tickerLabel.text = "0.00"
        
        titleView.addSubview(tickerLabel)
        tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        tickerLabel.constraintToSuperview(0, 0, 0, nil, ignoreSafeArea: true)
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)//monospacedSystemFont(ofSize: 12, weight: .light)
        nameLabel.text = "0.00"
        nameLabel.textColor = UIColor.label
        
        titleView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.lastBaselineAnchor.constraint(equalTo: tickerLabel.lastBaselineAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: tickerLabel.trailingAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -72).isActive = true
        
        tickerLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        tickerLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        stackView.addArrangedSubview(titleView)
        
        let spacer = UIView()
        spacer.constraintHeight(to: 8)
        stackView.addArrangedSubview(spacer)
        
        let priceView = UIView()
        
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)//monospacedSystemFont(ofSize: 32, weight: .bold)
        priceLabel.text = "0.00"
        
        priceView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.constraintToSuperview(0, 0, 0, nil, ignoreSafeArea: true)
        
        changeLabel = UILabel()
        changeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)//.monospacedSystemFont(ofSize: 15, weight: .regular)
        changeLabel.text = "+0.26 (0.11%)"
        changeLabel.textColor = UIColor(hex: "33E190")
        
        priceView.addSubview(changeLabel)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.lastBaselineAnchor.constraint(equalTo: priceLabel.lastBaselineAnchor).isActive = true
        changeLabel.constraintToSuperview(nil, nil, nil, 0, ignoreSafeArea: true)
       // changeLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8).isActive = true
        
        stackView.addArrangedSubview(priceView)
        
        let bidView = UIView()
        
        bidAskLabel = UILabel()
        bidAskLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)//.monospacedSystemFont(ofSize: 16, weight: .medium)
        bidAskLabel.text = "0.00"
        
        bidView.addSubview(bidAskLabel)
        bidAskLabel.translatesAutoresizingMaskIntoConstraints = false
        bidAskLabel.constraintToSuperview(0, 0, 0, nil, ignoreSafeArea: true)
        
        marketCapLabel = UILabel()
        marketCapLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)//monospacedSystemFont(ofSize: 15, weight: .semibold)
        marketCapLabel.text = "14.45B"
        marketCapLabel.textColor = UIColor(hex: "33E190")
        
        bidView.addSubview(marketCapLabel)
        
        marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
        marketCapLabel.constraintToSuperview(0, nil, nil, 0, ignoreSafeArea: true)
        //marketCapLabel.firstBaselineAnchor.constraint(equalTo: bidAskLabel.firstBaselineAnchor).isActive = true
        
        stackView.addArrangedSubview(bidView)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        timeLabel.text = "0.00"
        timeLabel.textColor = .secondaryLabel
        timeLabel.isHidden = true
        stackView.addArrangedSubview(timeLabel)
    }
    
    func observe(_ ticker:PolygonStock) {
        stopObserving()
        self.stock = ticker
        //titleLabel.text = "\(ticker.details.name ?? "") (\(ticker.symbol))"
        tickerLabel.text = ticker.symbol
        nameLabel.text = ticker.details.name
        
        changeLabel.text = stock?.changeCompositeStr
        changeLabel.textColor = stock?.changeColor
        marketCapLabel.textColor = changeLabel.textColor
        
        if let lastTrade = ticker.lastTrade {
            self.priceLabel?.text = "\(lastTrade.price)"
            let date = Date(timeIntervalSince1970: lastTrade.timestamp / 1000)
            self.timeLabel.text = date.UTCToLocalStr
            
            if let shares = stock?.details.shares {
                let marketCap = shares * lastTrade.price
                marketCapLabel.text = marketCap.shortFormatted
            } else {
                marketCapLabel.text = ""
            }
        }
        
        if let lastQuote = ticker.lastQuote {
            self.bidAskLabel.text = "\(lastQuote.bidprice) / \(lastQuote.askprice)"
        }
        
        NotificationCenter.addObserver(self,
                                       selector: #selector(didUpdateTrade),
                                       type: .stockTradeUpdated(ticker.symbol))
        NotificationCenter.addObserver(self,
                                       selector: #selector(didUpdateQuote),
                                       type: .stockQuoteUpdated(ticker.symbol))
    }
    
    func stopObserving() {
        if let stock = stock {
            NotificationCenter.removeObserver(self, type: .stockTradeUpdated(stock.symbol))
            NotificationCenter.removeObserver(self, type: .stockQuoteUpdated(stock.symbol))
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    @objc func didUpdateTrade(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let _stock = userInfo["stock"] as? PolygonStock else { return }
        self.stock = _stock
        
        changeLabel.text = stock?.changeCompositeStr
        changeLabel.textColor = stock?.changeColor
        marketCapLabel.textColor = changeLabel.textColor
        
        if let lastTrade = _stock.lastTrade {
            self.priceLabel?.text = "\(lastTrade.price)"
            let date = Date(timeIntervalSince1970: lastTrade.timestamp / 1000)
            self.timeLabel.text = date.UTCToLocalStr
            
            if let shares = stock?.details.shares {
                let marketCap = shares * lastTrade.price
                marketCapLabel.text = marketCap.shortFormatted
            } else {
                marketCapLabel.text = ""
            }
        }
        
        if let lastQuote = _stock.lastQuote {
            self.bidAskLabel.text = "\(lastQuote.bidprice) / \(lastQuote.askprice)"
            
        }
        //let date = Date(timeIntervalSince1970: t / 1000)
        //self.timeLabel.text = date.UTCToLocalStr
        
    }
    
    @objc func didUpdateQuote(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let _stock = userInfo["stock"] as? PolygonStock else { return }
        self.stock = _stock
        guard let bp = stock?.lastQuote?.bidprice else { return }
        guard let ap = stock?.lastQuote?.askprice else { return }
        guard let t = stock?.lastQuote?.timestamp else { return }
        
        self.bidAskLabel.text = "\(bp) / \(ap)"
        let date = Date(timeIntervalSince1970: t / 1000)
        self.timeLabel.text = date.UTCToLocalStr
    }
    
    func updateStats() {
        
    }
    
}

