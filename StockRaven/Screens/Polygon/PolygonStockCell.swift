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
    var handle:UInt?
    
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
                let marketCap = Double(shares) * lastTrade.price
                marketCapLabel.text = marketCap.shortFormatted
            } else {
                marketCapLabel.text = ""
            }
        }
        
        if let lastQuote = ticker.lastQuote {
            self.bidAskLabel.text = "\(lastQuote.bidprice) / \(lastQuote.askprice)"
            
        }
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateTrade), name: .init("T.\(ticker.symbol)"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateQuote), name: .init("Q.\(ticker.symbol)"), object: nil)
    }
    
    @objc func didUpdateTrade(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let p = userInfo["p"] as? Double else { return }
        guard let t = userInfo["t"] as? TimeInterval else { return }
        self.priceLabel?.text = "\(p)"
        
        if let previousClose = stock?.previousClose {
            let change = p - previousClose.close
            let changeFormatted = NumberFormatter.localizedString(from: NSNumber(value: change),
                                                                  number: NumberFormatter.Style.decimal)
            
            let changePercent = abs( change / previousClose.close )
            let changePercentFormatted = NumberFormatter.localizedString(from: NSNumber(value: changePercent),
                                                                         number: NumberFormatter.Style.decimal)
            var str = change > 0 ? "+\(changeFormatted)" : changeFormatted
            
            str += " (\(changePercentFormatted)%)"
            changeLabel.text = str
            
            var color:UIColor = UIColor.label
            if change > 0 {
                color = UIColor(hex: "33E190")
            } else if change < 0 {
                color = UIColor(hex: "FF3860")
            }
            
            changeLabel.textColor = color
            marketCapLabel.textColor = color
            
            
        } else {
            changeLabel.text = ""
        }
        
        if let shares = stock?.details.shares {
            let marketCap = Double(shares) * p
            marketCapLabel.text = marketCap.shortFormatted
        } else {
            marketCapLabel.text = ""
        }
        
        let date = Date(timeIntervalSince1970: t / 1000)
        self.timeLabel.text = date.UTCToLocalStr
        
    }
    
    @objc func didUpdateQuote(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let bp = userInfo["bp"] as? Double else { return }
        guard let ap = userInfo["ap"] as? Double else { return }
        guard let t = userInfo["t"] as? TimeInterval else { return }
        self.bidAskLabel.text = "\(bp) / \(ap)"
        let date = Date(timeIntervalSince1970: t / 1000)
        self.timeLabel.text = date.UTCToLocalStr
    }
    
    func updateStats() {
        
    }
    
}

