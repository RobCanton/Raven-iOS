//
//  Item.swift
//  RavenCalculator
//
//  Created by Robert Canton on 2020-03-13.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

protocol ItemDelegate {
    func itemEquationDidUpdate()
}
public struct Item {
    public var id:String
    public var equation:Equation
    public var evaluation:Evaluation?
    public var details:ItemDetails
    
    var delegate:ItemDelegate?
    
    static func parse(from data:[String:Any]) -> Item? {
        if let id = data["id"] as? String,
            let _equation = data["equation"] as? [String:Any],
            let _equationText = _equation["text"] as? String,
            let _details = data["details"] as? [String:Any],
            let name = _details["name"] as? String,
            let tags = _details["tags"] as? String,
            let _watchLevel = data["watch_level"] as? Int,
            let _evaluationData = data["evaluation"] as? [String:Any],
            let evaluation = Evaluation.parse(_evaluationData) {
            
            var equation = Equation()
            equation.process(text: _equationText)
            
            let watchLevel = ItemWatchLevel(rawValue: _watchLevel) ?? .none
            
            let details = ItemDetails(name: name,
                                      tagsStr: tags,
                                      watchLevel: watchLevel)
            return Item(id: id,
                        equation: equation,
                        evaluation: evaluation,
                        details: details)
        }
        return nil
    }
}

enum ItemWatchLevel:Int {
    case none = 0
    case inAppOnly = 1
    case daily = 2
    case hourly = 3
    case every15Minutes = 4
}



public struct ItemDetails {
    
    public enum Property {
        case name
        case tags
    }
    
    var name:String?
    var tagsStr:String?
    var tags:[String]
    var watchLevel:ItemWatchLevel
    
    
    static func createTags(from str:String?) -> [String] {
        var tags = [String]()
        if let _tagsStr = str {
            let tagsStrClean = _tagsStr.replacingOccurrences(of: " ", with: "")
            for token in tagsStrClean.split(separator: ",") {
                tags.append(String(token))
            }
        }
        return tags
    }
    
    
    
    init(name:String?, tagsStr:String?, watchLevel:ItemWatchLevel) {
        self.name = name
        self.tagsStr = tagsStr
        self.tags = ItemDetails.createTags(from: tagsStr)
        self.watchLevel = watchLevel
    }
    
    init() {
        name = nil
        tags = []
        watchLevel = .inAppOnly
    }
    
    mutating func setTags(fromStr tagsStr:String?) {
        self.tagsStr = tagsStr
        self.tags = ItemDetails.createTags(from: tagsStr)
    }
    
    
}
