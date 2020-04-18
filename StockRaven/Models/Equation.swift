//
//  Equation.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-03.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

protocol EquationDelegate:class {
    func equationDidUpdate(_ components:[Component])
}

struct ProxyComponent {
    var position:Int
    var primary:Component
    var auxillary:Component
    var date:Component?
    var updateMode:StatUpdateMode
    
    
    init(position:Int, primary:Component, auxillary:Component, date:Component?=nil) {
        self.position = position
        self.primary = primary
        self.auxillary = auxillary
        self.date = date
        
        if date != nil {
            updateMode = .historical(dateStr: date!.string.replacingOccurrences(of: "@", with: ""))
        } else {
            updateMode = .live
        }
        
    }
}

public struct Equation {
    
    
    weak var delegate:EquationDelegate?
    struct Evaluable {
        let string:String
        
    }
    
    var components:[Component] {
        didSet {
            delegate?.equationDidUpdate(self.components)
        }
    }
    
    var proxyComponents:[ProxyComponent]
    
    var cursor = (0,0)
    
    func components(ofType type:ComponentType) -> [Component] {
        return components.filter {
            return $0.type == type
        }
    }
    
 
    init() {
        components = []
        proxyComponents = []
    }
    
    var stringRepresentation:String {
        var string = ""
        for i in 0..<components.count {
            let component = components[i]
            var str = component.string
            
            if component.type == .symbol {
                var nextComponentIsStat = false
                
                if i + 1 < components.count {
                    nextComponentIsStat = components[i+1].type == .stat
                }
                
                if !nextComponentIsStat {
                    str += ":price"
                }
            }
            
            string += str
            
        }
        return string
    }
    
    var calculableString:String {
        var string = ""
        for i in 0..<components.count {
            let component = components[i]
            var str = component.string
            
            if component.type == .symbol {
                var nextComponentIsStat = false
                
                if i + 1 < components.count {
                    nextComponentIsStat = components[i+1].type == .stat
                }
                
                if !nextComponentIsStat {
                    str += ":price"
                }
                
                str = str.replacingOccurrences(of: "-", with: "_")
            }
            
            string += str
            
        }
        return string.replacingOccurrences(of: ":", with: "_")
    }
    
    func componentIndex(at position:Int) -> Int? {
        var totalLength = 0
        for i in 0..<components.count {
            let component = components[i]
            totalLength += component.string.count
            if totalLength >= position {
                return i
            }
            
        }
        return nil
    }
    
    mutating func insertComponent(_ component:Component, at index:Int) {
        self.components.insert(component, at: index)
    }
    
    mutating func insertComponents(_ components:[Component], at index:Int) {
        self.components.insert(contentsOf: components, at: index)
    }
    
    mutating func removeComponent(at index:Int) {
        self.components.remove(at: index)
    }
    
    
    func printAll() {
        var string = ""
        for component in components {
            string += "[\(component.string)] + "
        }
        print(string)
    }
    
    
    mutating func process(text:String) {
        self.components = Equation.parse(text: text)
        
        
        var _proxyComponents = [ProxyComponent]()
        for i in 0..<components.count {
            let component = components[i]
            if component.type == .symbol {
                var proxyComponent:ProxyComponent
                if i+1 < components.count {
                    
                    if components[i+1].type == .stat {
                        
                        if i+2 < components.count, components[i+2].type == .date {
                            proxyComponent = ProxyComponent(position:i,
                                                            primary: component,
                                                            auxillary: components[i+1],
                                                            date: components[i+2])
                        } else {
                            proxyComponent = ProxyComponent(position: i,
                                                            primary: component,
                                                            auxillary: components[i+1])
                        }
                    } else if components[i+1].type == .date {
                        proxyComponent = ProxyComponent(position: i,
                                                        primary: component,
                                                        auxillary: Component(string: ":price", type: .stat),
                                                        date: components[i+1])
                    } else {
                        proxyComponent = ProxyComponent(position:i,
                                                        primary: component,
                                                        auxillary: Component(string: ":price", type: .stat))
                    }
                    
                } else {
                    proxyComponent = ProxyComponent(position:i,
                                                    primary: component,
                                                    auxillary: Component(string: ":price", type: .stat))
                }
                
                _proxyComponents.append(proxyComponent)
            }
        }
        
        self.proxyComponents = _proxyComponents
    }
    
    /*
    mutating func process(text:String) {
        print("Text: [\(text)]")
        
        
        var _components = [Component]()
        //var _proxyComponents = [ProxyComponent]()
        
        //*let delimiterSet = ["*", "/", "+", "-", "(", ")", " "]//CharacterSet(charactersIn: "*/+-() ")
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
        
        print("Delimiters: \(delimiters)")
        
        var cap = 0
        for i in 0..<tokens.count {
            let token = String(tokens[i])

            if token.contains(":") {
                let split = token.split(separator: ":")
                if split.count == 2 {
                    let fragment = String(split[0])
                    
                    if fragment.contains("@") {
                        let dateSplit = fragment.split(separator: "@")
                        
                        if dateSplit.count == 2 {
                            let leadingFragment = String(dateSplit[0])
                            
                            if leadingFragment.isAlphabetic {
                                let symbol = Component(string: leadingFragment, type: .symbol)
                                _components.append(symbol)
                                cap += symbol.string.count
                            } else {
                                let unknown = Component(string: leadingFragment, type: .unknown)
                                _components.append(unknown)
                                cap += unknown.string.count
                            }
                            
                            let dateStat = Component(string: "@\(String(dateSplit[1]))", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                            
                            
                        } else if dateSplit.count == 1 {
                            let leadingFragment = String(dateSplit[0])
                            
                            if leadingFragment.isAlphabetic {
                                let symbol = Component(string: leadingFragment, type: .symbol)
                                _components.append(symbol)
                                cap += symbol.string.count
                            } else {
                                let unknown = Component(string: leadingFragment, type: .unknown)
                                _components.append(unknown)
                                cap += unknown.string.count
                            }
                            
                            let dateStat = Component(string: "@", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                        } else {
                            let unknown = Component(string: fragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                    } else {
                        if fragment.isAlphabetic {
                            let symbol = Component(string: fragment, type: .symbol)
                            _components.append(symbol)
                            cap += symbol.string.count
                        } else {
                            let unknown = Component(string: fragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                    }
                    
                    let statToken = String(split[1])
                    
                    if statToken.contains("@") {
                        let dateSplit = statToken.split(separator: "@")
                        
                        
                        if dateSplit.count == 2 {
                            let stat = Component(string: ":\(String(dateSplit[0]))", type: .stat)
                            _components.append(stat)
                            cap += stat.string.count
                            
                            let dateStat = Component(string: "@\(String(dateSplit[1]))", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                        } else if dateSplit.count == 1 {
                            let stat = Component(string: ":\(String(dateSplit[0]))", type: .stat)
                            _components.append(stat)
                            cap += stat.string.count
                            
                            let dateStat = Component(string: "@", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                        } else {
                            let unknown = Component(string: statToken, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                        
                    } else {
                        let stat = Component(string: ":\(statToken)", type: .stat)
                        _components.append(stat)
                        cap += stat.string.count
                    }
                    
                } else if split.count == 1 {
                    let fragment = String(split[0])
                    if fragment.contains("@") {
                        let dateSplit = fragment.split(separator: "@")
                        
                        if dateSplit.count == 2 {
                            let leadingFragment = String(dateSplit[0])
                            
                            if leadingFragment.isAlphabetic {
                                let symbol = Component(string: leadingFragment, type: .symbol)
                                _components.append(symbol)
                                cap += symbol.string.count
                            } else {
                                let unknown = Component(string: leadingFragment, type: .unknown)
                                _components.append(unknown)
                                cap += unknown.string.count
                            }
                            
                            let dateStat = Component(string: "@\(String(dateSplit[1]))", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                        } else if dateSplit.count == 1 {
                            let leadingFragment = String(dateSplit[0])
                            
                            if leadingFragment.isAlphabetic {
                                let symbol = Component(string: leadingFragment, type: .symbol)
                                _components.append(symbol)
                                cap += symbol.string.count
                            } else {
                                let unknown = Component(string: leadingFragment, type: .unknown)
                                _components.append(unknown)
                                cap += unknown.string.count
                            }
                            
                            let dateStat = Component(string: "@", type: .date)
                            _components.append(dateStat)
                            cap += dateStat.string.count
                        } else {
                            let unknown = Component(string: fragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                    } else {
                        if fragment.isAlphabetic {
                            let symbol = Component(string: fragment, type: .symbol)
                            _components.append(symbol)
                            cap += symbol.string.count
                        } else {
                            let unknown = Component(string: fragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                    }
                    
                    
                    let stat = Component(string: ":", type: .stat)
                    _components.append(stat)
                    cap += stat.string.count
                } else {
                    let unknown = Component(string: token, type: .unknown)
                    _components.append(unknown)
                    cap += unknown.string.count
                }
            } else {
                
                if token.contains("@") {
                    let dateSplit = token.split(separator: "@")
                    
                    if dateSplit.count == 2 {
                        let leadingFragment = String(dateSplit[0])
                        
                        if leadingFragment.isAlphabetic {
                            let symbol = Component(string: leadingFragment, type: .symbol)
                            _components.append(symbol)
                            cap += symbol.string.count
                        } else {
                            let unknown = Component(string: leadingFragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                        
                        let dateStat = Component(string: "@\(String(dateSplit[1]))", type: .date)
                        _components.append(dateStat)
                        cap += dateStat.string.count
                    } else if dateSplit.count == 1 {
                        let leadingFragment = String(dateSplit[0])
                        
                        if leadingFragment.isAlphabetic {
                            let symbol = Component(string: leadingFragment, type: .symbol)
                            _components.append(symbol)
                            cap += symbol.string.count
                        } else {
                            let unknown = Component(string: leadingFragment, type: .unknown)
                            _components.append(unknown)
                            cap += unknown.string.count
                        }
                        
                        let dateStat = Component(string: "@", type: .date)
                        _components.append(dateStat)
                        cap += dateStat.string.count
                    } else {
                        let unknown = Component(string: token, type: .unknown)
                        _components.append(unknown)
                        cap += unknown.string.count
                    }
                } else {
                    if token.isAlphabetic {
                        let symbol = Component(string: token, type: .symbol)
                        _components.append(symbol)
                        cap += symbol.string.count
                    } else if token.isNumeric {
                        let symbol = Component(string: token, type: .digit)
                        _components.append(symbol)
                        cap += symbol.string.count
                    } else {
                        let unknown = Component(string: token, type: .unknown)
                        _components.append(unknown)
                        cap += unknown.string.count
                    }
                }
            }
            
            
            if delimiters.count > 0 {
                
                var delimiter = delimiters.first
                
                while (delimiter?.1 == cap) {
                    let _ = delimiters.removeFirst()
                    let operation = Component(string: delimiter!.0, type: .operation)
                    _components.append(operation)
                    cap += delimiter!.0.count
                    delimiter = delimiters.first
                }
            }
        }
        
        
        var _proxyComponents = [ProxyComponent]()
        for i in 0..<_components.count {
            let component = _components[i]
            if component.type == .symbol {
                var proxyComponent:ProxyComponent
                if i+1 < _components.count {
                    
                    if _components[i+1].type == .stat {
                        
                        if i+2 < _components.count, _components[i+2].type == .date {
                            proxyComponent = ProxyComponent(position:i,
                                                            primary: component,
                                                            auxillary: _components[i+1],
                                                            date: _components[i+2])
                        } else {
                            proxyComponent = ProxyComponent(position: i,
                                                            primary: component,
                                                            auxillary: _components[i+1])
                        }
                    } else if _components[i+1].type == .date {
                        proxyComponent = ProxyComponent(position: i,
                                                        primary: component,
                                                        auxillary: Component(string: ":price", type: .stat),
                                                        date: _components[i+1])
                    } else {
                        proxyComponent = ProxyComponent(position:i,
                                                        primary: component,
                                                        auxillary: Component(string: ":price", type: .stat))
                    }
                    
                } else {
                    proxyComponent = ProxyComponent(position:i,
                                                    primary: component,
                                                    auxillary: Component(string: ":price", type: .stat))
                }
                
                _proxyComponents.append(proxyComponent)
            }
        }
        
        printAll()
        self.components = _components
        self.proxyComponents = _proxyComponents
    }
    
    */
}
