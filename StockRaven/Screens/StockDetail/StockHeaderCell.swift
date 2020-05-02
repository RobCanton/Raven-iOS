//
//  StockHeaderCell.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-20.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftChart

class StockHeaderCell:UITableViewCell {
    var stock:PolygonStock?
    var priceLabel:UILabel!
    var nameLabel:UILabel!
    var bidAskLabel:UILabel!
    var timeLabel:UILabel!
    var changeLabel:UILabel!
    var marketCapLabel:UILabel!
    
    var chart:Chart!
    
    
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
        stackView.constraintToSuperview(20, 16, 15, 16, ignoreSafeArea: true)
        stackView.axis = .vertical
        stackView.spacing = 1
        
       
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)//monospacedSystemFont(ofSize: 12, weight: .light)
        nameLabel.text = "0.00"
        nameLabel.textColor = UIColor.label
        nameLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(nameLabel)
        
        let spacer = UIView()
        spacer.constraintHeight(to: 10)
        stackView.addArrangedSubview(spacer)
        
        let priceView = UIView()
        
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 44, weight: .bold)//monospacedSystemFont(ofSize: 32, weight: .bold)
        priceLabel.text = "0.00"
        
        priceView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.constraintToSuperview(0, 0, 0, nil, ignoreSafeArea: true)
        
        changeLabel = UILabel()
        changeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)//.monospacedSystemFont(ofSize: 15, weight: .regular)
        changeLabel.text = "+0.26 (0.11%)"
        changeLabel.textColor = UIColor(hex: "33E190")
        
        priceView.addSubview(changeLabel)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.lastBaselineAnchor.constraint(equalTo: priceLabel.lastBaselineAnchor).isActive = true
        changeLabel.constraintToSuperview(nil, nil, nil, 0, ignoreSafeArea: true)
        
        
        changeLabel.isHidden = true
       // changeLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8).isActive = true
        
        stackView.addArrangedSubview(priceView)
        
        let bidView = UIView()
        
        bidAskLabel = UILabel()
        bidAskLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)//.monospacedSystemFont(ofSize: 16, weight: .medium)
        bidAskLabel.text = "0.00"
        
        bidView.addSubview(bidAskLabel)
        bidAskLabel.translatesAutoresizingMaskIntoConstraints = false
        bidAskLabel.constraintToSuperview(0, 0, 0, nil, ignoreSafeArea: true)
        
        marketCapLabel = UILabel()
        marketCapLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)//monospacedSystemFont(ofSize: 15, weight: .semibold)
        marketCapLabel.text = "14.45B"
        marketCapLabel.textColor = UIColor(hex: "33E190")
        
        bidView.addSubview(marketCapLabel)
        
        marketCapLabel.translatesAutoresizingMaskIntoConstraints = false
        marketCapLabel.constraintToSuperview(0, nil, nil, 0, ignoreSafeArea: true)
        marketCapLabel.isHidden = true
        //marketCapLabel.firstBaselineAnchor.constraint(equalTo: bidAskLabel.firstBaselineAnchor).isActive = true
        
        stackView.addArrangedSubview(bidView)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        timeLabel.text = "0.00"
        timeLabel.textColor = .secondaryLabel
        timeLabel.isHidden = true
        stackView.addArrangedSubview(timeLabel)
        
        chart = Chart()
        
        chart.tintColor = UIColor.label
        chart.gridColor = .clear
        chart.axesColor = .clear
        //chart.delegate = self
        
        chart.highlightLineWidth =  1.0
        chart.highlightLineColor = UIColor(hex: "33E190")
        chart.lineWidth = 1.0
        chart.bottomInset = 0
        chart.topInset = 0
        chart.xLabels = nil
        chart.showXLabelsAndGrid = false
        chart.showYLabelsAndGrid = false
        chart.showsLargeContentViewer = false
        chart.alpha = 0.0
        chart.constraintHeight(to: 164)
        chart.hideHighlightLineOnTouchEnd = true
        stackView.addArrangedSubview(chart)
        
    }
    
    func observe(_ ticker:PolygonStock) {
        self.stock = ticker
        //titleLabel.text = "\(ticker.details.name ?? "") (\(ticker.symbol))"
        nameLabel.text = ticker.details.name
        
        //changeLabel.text = stock?.changeCompositeStr
        //changeLabel.textColor = stock?.changeColor
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
        
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateTrade), name: .init("T.\(ticker.symbol)"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateQuote), name: .init("Q.\(ticker.symbol)"), object: nil)
        
        chart.alpha = 0.0
        populate(stock: ticker)
    }
    
    @objc func didUpdateTrade(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let _stock = userInfo["stock"] as? PolygonStock else { return }
        self.stock = _stock
        guard let p = stock?.lastTrade?.price else { return }
        
        self.priceLabel?.text = "\(p)"
        
        if let previousClose = stock?.previousClose?.close {
            let change = p - previousClose
            let changeFormatted = NumberFormatter.localizedString(from: NSNumber(value: change),
                                                                  number: NumberFormatter.Style.decimal)
            
            let changePercent = abs( change / previousClose )
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
            let marketCap = shares * p
            marketCapLabel.text = marketCap.shortFormatted
        } else {
            marketCapLabel.text = ""
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
    
    func populate(stock:PolygonStock) {
        PolyravenAPI.stockHistoricTrades(symbol: stock.symbol, date: "2020-04-20") { trades in
            var max:Double = 0
            var min:Double = .greatestFiniteMagnitude
            var points = [Double]()
            for t in trades {
                if let c = t.average {
                    if c > max {
                        max = c
                    }
                    if c < min {
                        min = c
                    }
                    points.append(c)
                }
            }
            self.chart.maxY = max * 1.075
            self.chart.minY = min - ((max - min) * 0.1)
            
            let series = ChartSeries(points)
            series.colors = (above: UIColor(hex: "33E190"), UIColor(hex: "33E190"), zeroLevel: 0)
            
            self.chart.add(series)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.chart.alpha = 1.0
            }, completion: nil)
        }
    }
}
