//
//  Database.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import Foundation
import GRDB

/// A multi-keys value item base database with thread safe.
public final class Database {

    ///  The internal database queue.
    private var databaseQueue: DatabaseQueue

    ///  Create and return a database to access SQLite database in `path`.
    public init(path: String) throws {
        databaseQueue = try DatabaseQueue(path: path)
    }

    ///  Convenience init with database name, the database will be saved in the document directory.
    public convenience init?(name: String) {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first else {
            return nil
        }
        let path = documentPath.stringByAppendingString("/\(name)")
        do {
            try self.init(path: path)
        } catch {
            return nil
        }
    }

    /// The database path.
    public var databasePath: String {
        return databaseQueue.path
    }

    ///  Create a `table` with `numberOfKeys` key columns and a value column.
    public func create(table table: String, numberOfKeys: Int) throws {
        let sql = SQL.createTable(table, numberOfKeys: numberOfKeys)
        try databaseQueue.inDatabase { db in
            try db.execute(sql)
        }
    }

    ///  Find out a `table` is empty or not.
    public func isEmpty(table table: String) -> Bool {
        let sql = SQL.selectOne(from: table)
        var result = true
        databaseQueue.inDatabase { db in
            let row = Row.fetchOne(db, sql)
            result = row == nil
        }
        return result
    }

    ///  Put a `item` into `table`.
    public func put(item: Item, into table: String) throws {
        let sql = SQL.replace(into: table, numberOfkeys: item.keys.count)
        let arguments = item.keys + [item.value]
        try databaseQueue.inDatabase { db in
            try db.execute(sql, arguments: StatementArguments(arguments))
        }
    }

    ///  Put an array of `items` into `table`.
    public func put(items: [Item], into table: String) throws {
        guard let firstItem = items.first else { return }
        let sql = SQL.replace(into: table, numberOfkeys: firstItem.keys.count)
        try databaseQueue.inTransaction { db in
            for item in items {
                let arguments = item.keys + [item.value]
                try db.execute(sql, arguments: StatementArguments(arguments))
            }
            return .Commit
        }
    }

    ///  Get one item from `table` where `predicate`.
    public func getOne(where predicate: Predicate, from table: String) -> Item? {
        let sql = SQL.select(from: table, where: predicate.predicateSQL, limit: 1)
        return getAll(sql: sql).first
    }

    ///  Get all items from `table` where `predicate`.
    public func getAll(where predicate: Predicate, from table: String) -> [Item] {
        let sql = SQL.select(from: table, where: predicate.predicateSQL)
        return getAll(sql: sql)
    }

    ///  Get all items from `table`.
    public func getAll(from table: String) -> [Item] {
        let sql = SQL.selectAll(from: table)
        return getAll(sql: sql)
    }

    ///  Delete all items from `table` where `predicate`.
    public func delete(where predicate: Predicate, from table: String) throws {
        let sql = SQL.delete(from: table, where: predicate.predicateSQL)
        try databaseQueue.inDatabase { db in
            try db.execute(sql)
        }
    }

    ///  Delete all items from `table`.
    public func deleteAll(from table: String) throws {
        let sql = SQL.deleteAll(from: table)
        try databaseQueue.inDatabase { db in
            try db.execute(sql)
        }
    }

    ///  Delete all items from `table` and drop itself.
    public func drop(table table: String) throws {
        let sql = SQL.dropTable(table)
        try databaseQueue.inDatabase { db in
            try db.execute(sql)
        }
    }

    ///  Get all items with raw sql.
    private func getAll(sql sql: String) -> [Item] {
        var result = [Item]()
        databaseQueue.inDatabase { db in
            for row in Row.fetch(db, sql) {
                var keys = [String]()
                for i in 0..<row.count - 1 {
                    let key: String = row.value(atIndex: i)
                    keys.append(key)
                }
                let value: String = row.value(atIndex: row.count - 1)
                let item = Item(keys: keys, value: value)
                result.append(item)
            }
        }
        return result
    }

}

