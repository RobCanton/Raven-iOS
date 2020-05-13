//
//  Solve.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-07.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import Expression

protocol EvaluatorDelegate {
    func evaluatorDidStart()
    mutating func evaluatorDidComplete(withResult result: Evaluation)
    func evaluatorDidFail(withError error:Error)
}

class Evaluator {
    let equation:Equation
    
    var delegate:EvaluatorDelegate?
    
    init (equation: Equation, delegate: EvaluatorDelegate?=nil) {
        self.equation = equation
        self.delegate = delegate
    }
    
    func solve() {
        fetchRequirements()
    }
    
    private func fetchRequirements() {
        delegate?.evaluatorDidStart()
        
        RavenAPI.shared.getData(for: equation) { response, error in
            self.calculate(equationData: response ?? .none)
        }
        
    }
    
    private func calculate( equationData: EquationDataResponse) {
        
        var currency:Currency?
        
        let stocks = equationData.stocks
        let historicalQuotes = equationData.historicalQuotes
        var vars = [Expression.Symbol: Expression.SymbolEvaluator]()
        
        let statComponents = equation.components(ofType: .stat)
        
        var statTypes = [Stat: Bool]()
        
        statTypes[.price] = true
        
        for component in statComponents {
            let statStrClean = component.string.replacingOccurrences(of: ":", with: "").lowercased()
            if let stat = Stat(rawValue: statStrClean) {
                statTypes[stat] = true
            }
        }
        
        var unavailableStats = [Stat]()
        var variableValues = [String:Double]()
        
        for stock in stocks {
            for (type, _) in statTypes {
                let key = "\(stock.symbol_calculable)_\(type.rawValue)"
                switch type {
                case .volume:
                    if stock.quote.volume == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.volume
                case .change:
                    if stock.quote.change == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.change
                case .changePercent:
                    if stock.quote.changePercent == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.changePercent
                case .open:
                    if stock.quote.open == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.open
                case .close:
                    if stock.quote.close == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.close
                case .previousClose:
                    if stock.quote.previousClose == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.previousClose
                case .previousVolume:
                    if stock.quote.previousVolume == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.previousVolume
                case .high:
                    if stock.quote.high == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.high
                case .low:
                    if stock.quote.low == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.low
                case .marketCap:
                    if stock.quote.marketCap == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.marketCap
                case .avgTotalVolume:
                    if stock.quote.avgTotalVolume == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.avgTotalVolume
                case .week52High:
                    if stock.quote.week52High == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.week52High
                case .week52Low:
                    if stock.quote.week52Low == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.week52Low
                case .ytdChange:
                    if stock.quote.ytdChange == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.ytdChange
                case .peRatio:
                    if stock.quote.peRatio == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.peRatio
                case .extendedPrice:
                    if stock.quote.extendedPrice == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.extendedPrice
                case .extendedChange:
                    if stock.quote.extendedChange == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.extendedChange
                case .extendedChangePercent:
                    if stock.quote.extendedChangePercent == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.extendedChangePercent
                default:
                    if stock.quote.price == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = stock.quote.price
                }
            }
        }
        
        for quote in historicalQuotes {
            for (type, _) in statTypes {
                let symbolCalculable = quote.symbol.replacingOccurrences(of: "-", with: "_")
                let key = "\(symbolCalculable)_\(type.rawValue)@\(quote.dateStr)"
                switch type {
                case .changePercent:
                    if quote.changePercent == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.changePercent
                    break
                case .change:
                    if quote.change == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.change
                    break
                case .volume:
                    if quote.volume == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.volume
                    break
                case .close, .price:
                    if quote.close == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.close
                    break
                case .open:
                    if quote.close == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.open
                    break
                case .low:
                    if quote.close == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.low
                    break
                case .high:
                    if quote.close == nil {
                        unavailableStats.append(type)
                    }
                    variableValues[key] = quote.high
                    break
                default:
                    break
                }
            }
        }
        
        if unavailableStats.count > 0 {
            let error = NSError(domain: "", code: 0, userInfo: [:])
            self.delegate?.evaluatorDidFail(withError: error as Error)
            return
        }
        
        var date:Date?
        for stock in stocks {
            for (type, _) in statTypes {
                let key = "\(stock.symbol_calculable)_\(type.rawValue)"
                vars[.variable(key)] = { _ in
                    if currency == nil {
                        currency = stock.quote.currency
                    }
                    return variableValues[key] ?? 0
                }
            }
            
            if date == nil {
                date = stock.quote.latestUpdate
            } else if let stockDate = stock.quote.latestUpdate {
                if date!.compare(stockDate) == .orderedAscending {
                    date = stockDate
                }
            }
        }
        
        for quote in historicalQuotes {
            for (type, _) in statTypes {
                let symbolCalculable = quote.symbol.replacingOccurrences(of: "-", with: "_")
                let key = "\(symbolCalculable)_\(type.rawValue)@\(quote.dateStr)"
                vars[.variable(key)] = { _ in
                    return variableValues[key] ?? 0
                }
            }
        }
        
        
        let forexSymbols = equation.components(ofType: .forex)
        
        for forex in forexSymbols {
            vars[.variable(forex.string)] = { _ in
                return CurrencyManager.shared.rate(for: forex.string)
            }
        }
        
        if date == nil {
            date = Date()
        }
        
        
        let expressionString = equation.calculableString
        
        print(" * expressionString: \(expressionString)")
        print(" * variables: \(variableValues)")
        print(" * unavailableStats: \(unavailableStats)")
        let expression = Expression(expressionString, symbols: vars)
        
        do {
            let value = try expression.evaluate()
            let evaluation = Evaluation(value: value,
                                        currency: currency ?? .none,
                                        date: Date(),
                                        variables: variableValues)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...3.0), execute: {
                self.delegate?.evaluatorDidComplete(withResult: evaluation)
            })
            
        } catch {
            
            
            print("Error: \(error)")
            
            self.delegate?.evaluatorDidFail(withError: error)
        }
        
    }
    
}
