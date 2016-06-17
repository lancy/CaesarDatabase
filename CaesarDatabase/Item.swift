//
//  Item.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import Foundation

/// Item represent the data store in database.
public final class Item {

    /// Keys
    public var keys: [String]

    /// Value
    public var value: String

    /// Convenince property, return the first of `keys`, set this property will reset `keys` to [`key`].
    public var key: String {
        get {
            return keys.first!
        }
        set {
            keys = [newValue]
        }
    }

    ///  Create and return a item with `keys` and `value`.
    public init(keys: [String], value: String) {
        self.keys = keys
        self.value = value
    }

    ///  Convenience create and return a item with `key` and `value`.
    public convenience init(key: String, value: String) {
        self.init(keys: [key], value: value)
    }
}