//
//  Equation+Parser.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-04.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

extension Equation {
    
    fileprivate static func parse(symbol:String) -> [Component] {
        
        var components = [Component]()
        
        func validateSymbol(_ symbol:String) -> Component {
            if symbol.count == 6,
                symbol.isAlphabetic,
                CurrencyManager.shared.currencies(for: symbol) != nil {
                return Component(string: symbol, type: .forex)
            } else if symbol.isAlphasymbolic {
                return Component(string: symbol, type: .symbol)
            }
            return Component(string: symbol, type: .unknown)
        }
        
        if symbol.contains("@") {
            let split = symbol.split(separator: "@")
            
            switch split.count {
            case 2:
                let leadingFragment = String(split[0])
                let trailingFragment = String(split[1])
                
                components.append(validateSymbol(leadingFragment))
                
                // add @Date
                let dateComponent = Component(string: "@\(trailingFragment)", type: .date)
                components.append(dateComponent)
                
                break
            case 1:
                let fragment = String(split[0])
                
                components.append(validateSymbol(fragment))
                
                // add @
                let dateComponent = Component(string: "@", type: .date)
                components.append(dateComponent)
                break
            default:
                
                let unknownComponent = Component(string: symbol, type: .unknown)
                components.append(unknownComponent)
                break
            }
        } else {
            components.append(validateSymbol(symbol))
        }
        
        
        return components
    }

    fileprivate static func parse(stat:String) -> [Component] {
        
        var components = [Component]()
        
        
        if stat.contains("@") {
            let split = stat.split(separator: "@")
            
            switch split.count {
            case 2:
                let leadingFragment = String(split[0])
                let trailingFragment = String(split[1])
                
                let statComponent = Component(string: leadingFragment, type: .stat)
                components.append(statComponent)
                
                let dateComponent = Component(string: "@\(trailingFragment)", type: .date)
                components.append(dateComponent)
                
                break
            case 1:
                let fragment = String(split[0])
                
                let statComponent = Component(string: fragment, type: .stat)
                components.append(statComponent)
                
                let dateComponent = Component(string: "@", type: .date)
                components.append(dateComponent)
                
                break
            default:
                let unknownComponent = Component(string: stat, type: .unknown)
                components.append(unknownComponent)
                break
            }
        } else {
            let statComponent = Component(string: stat, type: .stat)
            components.append(statComponent)
        }
        return components
    }


    fileprivate  static func parse(word:String) -> [Component] {
        let split = word.split(separator: ":")
        
        var components = [Component]()
        
        if word.contains(":") {
            switch split.count {
            case 2:
                let leadingFragment = String(split[0])
                let trailingFragment = String(split[1])
                
                let symbolComponents = parse(symbol: leadingFragment)
                components.append(contentsOf: symbolComponents)
                
                let statComponents = parse(stat: ":\(trailingFragment)")
                    
                components.append(contentsOf: statComponents)
                
                break
            case 1:
                let fragment = String(split[0])
                let symbolComponents = parse(symbol: fragment)
                components.append(contentsOf: symbolComponents)
                
                let statComponent = Component(string: ":", type: .stat)
                components.append(statComponent)
                
                break
            default:
                let unknown = Component(string: word, type: .unknown)
                components.append(unknown)
                break
            }
        } else {
            let symbolComponents = parse(symbol: word)
            components.append(contentsOf: symbolComponents)
        }
        
        return components
    }



    static func parse(text:String) -> [Component] {
        
        let delimiterSet = [" ", "(", ")"]
        let tokens = text.split {
            delimiterSet.contains(String($0))
        }
               
        var delimiters = [(String, Int)]()
               
        var count = 0
        text.forEach { c in
            if delimiterSet.contains(String(c)) {
                delimiters.append((String(c), count))
            }
                   
            count += 1
        }
        
        var components = [Component]()
        
        for i in 0..<tokens.count {
            let token = String(tokens[i])
            
            if token.isOperation {
                let component = Component(string: token, type: .operation)
                components.append(component)
                
            } else if token.isNumeric {
                components.append(Component(string: token, type: .digit))
            } else {
                components.append(contentsOf: parse(word: token))
            }
        }
        
        
        if delimiters.count > 0 {
            
            var cap = 0
            var componentsWithDelimiters = [Component]()
            
            
            
            for i in -1..<components.count {
                
                if i >= 0 {
                    let component = components[i]
                    componentsWithDelimiters.append(component)
                    
                    
                    cap += component.string.count
                }
                
                var delimiter = delimiters.first
                
                var insertionIndex = i + 1
                while (delimiter?.1 == cap) {
                    let _ = delimiters.removeFirst()
                    
                    let operation = Component(string: delimiter!.0, type: .space)
                    
                    componentsWithDelimiters.append(operation)
                    
                    cap += delimiter!.0.count
                    insertionIndex += 1
                    
                    delimiter = delimiters.first
                }
                
            }
            return componentsWithDelimiters
        } else {
            return components
        }
    }
        
}
