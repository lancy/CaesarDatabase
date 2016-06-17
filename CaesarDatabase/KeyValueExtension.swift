//
//  KeyValueExtension.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import Foundation

///  The key value extension wrap some convenience accessor for single key value pair.
///  IMPORTANCE: Use these API only for table that have ONLY ONE key column.
extension Database {

    ///  Create a `table` with one key column.
    public func create(table table: String) throws {
        return try create(table: table, numberOfKeys: 1)
    }

    ///  Put `string` with `key` into `table`.
    public func putString(string: String, withKey key: String, into table: String) {
        let item = Item(key: key, value: string)
        do {
            try put(item, into: table)
        } catch let error {
            print(error)
        }
    }

    ///  Batch put `strings` with `keys` into `table`.
    public func putStrings(strings: [String], withKeys keys: [String], into table: String) {
        guard strings.count == keys.count else { return }
        var items = [Item]()
        for i in 0..<strings.count {
            let item = Item(key: keys[i], value: strings[i])
            items.append(item)
        }
        do {
            try put(items, into: table)
        } catch let error {
            print(error)
        }
    }

    ///  Get `string` with `key` from `table`.
    public func getString(withKey key: String, from table: String) -> String? {
        let predicate = EqualPredicate(keyIndex: 0, target: key)
        let item = getOne(where: predicate, from: table)
        return item?.value
    }

    ///  Batch get strings with `keys` from `table`, return a [Key: Value] dictioanry.
    public func getStrings(withKeys keys: [String], from table: String) -> [String: String] {
        let predicate = InPredicate(keyIndex: 0, targets: keys)
        let items = getAll(where: predicate, from: table)
        var result = [String: String]()
        for item in items {
            result[item.key] = item.value
        }
        return result
    }

    ///  Batch get all strings from `table`.
    public func getAllStrings(from table: String) -> [String] {
        return getAll(from: table).map { item in
            return item.value
        }
    }

    ///  Delete string with `key` from `table`.
    public func deleteString(withKey key: String, from table: String) {
        let predicate = EqualPredicate(keyIndex: 0, target: key)
        do {
            try delete(where: predicate, from: table)
        } catch let error {
            print(error)
        }
    }

    ///  Batch delete strings with `keys` from `table`.
    public func deleteStrings(withKeys keys: [String], from table: String) {
        let predicate = InPredicate(keyIndex: 0, targets: keys)
        do {
            try delete(where: predicate, from: table)
        } catch let error {
            print(error)
        }
    }

}