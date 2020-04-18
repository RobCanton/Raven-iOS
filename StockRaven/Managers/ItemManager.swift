//
//  ItemManager.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-03-18.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation

class ItemManager {
    
    static let shared = ItemManager()
    
    var items:[Item]
    var stockSortedItemIndexes:[String:[Int:Bool]]
    
    private init() {
        // Mock Data
        items = []
        stockSortedItemIndexes = [:]
        
    }
    
    func configure() {
        RavenAPI.shared.getItems { items in
            self.setItems(items)
        }
    }
    
    func addItem(_ item:Item) {
        
        let index = items.firstIndex {
            return $0.id == item.id
        }
        
        if index != nil {
            items[Int(index!)] = item
        } else {
            items.append(item)
        }
        
        itemsUpdated()
    }
    
    func setItems(_ items:[Item]) {
        self.items = items
        self.stockSortedItemIndexes = [:]
        for i in 0..<items.count {
            let item = items[i]
            let symbols = item.equation.components(ofType: .symbol)
            for symbol in symbols {
                if self.stockSortedItemIndexes[symbol.string] == nil {
                    self.stockSortedItemIndexes[symbol.string] = [ i:true ]
                } else {
                    self.stockSortedItemIndexes[symbol.string]![i] = true
                }
            }
        }
        itemsUpdated()
    }
    
    
    private func itemsUpdated() {
        NotificationCenter.default.post(name: Notification.Name("itemsUpdated"), object: nil)
    }
    
    @objc func handleStockUpdate(_ notification:Notification) {
        
    }
}
