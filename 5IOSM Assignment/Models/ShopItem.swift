//
//  ShopItem.swift
//  5IOSM Assignment
//
//  Created by Jefferson MARINHO GOMES (001088479) on 11/9/19.
//  Copyright © 2019 Jefferson MARINHO GOMES (001088479). All rights reserved.
//

import Foundation

struct ShopItem: Comparable {
    
    // Enum type
    enum ItemType: String, CaseIterable {
        case Groceries, Electronics, Clothing, Other 
    }
    
    // Properties
    public var id: Int!
    public var name: String?
    public var price: Double?
    public var type: ItemType
    public var quantity: Int?
    
    // Constructor
    init(id: Int, name: String, price: Double, type: ItemType, quantity: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.type = type
        self.quantity = quantity
    }
    
    
    // Because we implemented the Comparable
    static func < (lhs: ShopItem, rhs: ShopItem) -> Bool {
        return lhs.type.hashValue < rhs.type.hashValue
    }
    
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        return lhs.type.hashValue == rhs.type.hashValue
    }
    
}
