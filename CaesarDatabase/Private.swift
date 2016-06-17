//
//  Utils.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import Foundation

struct SQL {

    static func selectOne(from table: String) -> String {
        return "SELECT * FROM \(table) LIMIT 1"
    }

    static func selectAll(from table: String) -> String {
        return "SELECT * FROM \(table)"
    }

    static func select(from table: String, where predicate: String) -> String {
        return "SELECT * FROM \(table) WHERE \(predicate)"
    }

    static func select(from table: String, where predicate: String, limit: Int) -> String {
        return "SELECT * FROM \(table) WHERE \(predicate) LIMIT \(limit)"
    }

    static func delete(from table: String, where predicate: String) -> String {
        return "DELETE FROM \(table) WHERE \(predicate)"
    }

    ///  Create and return sql for delete all from `table`.
    static func deleteAll(from table: String) -> String {
        return "DELETE FROM \(table)"
    }

    ///  Create and return sql for drop `table`.
    static func dropTable(table: String) -> String {
        return "DROP TABLE IF EXISTS \(table)"
    }

    ///  Create and return sql for create table with `table` and `numberOfKeys`.
    static func createTable(table: String, numberOfKeys: Int) -> String {
        var sql = "CREATE TABLE IF NOT EXISTS \(table) ("
        for i in 0..<numberOfKeys {
            sql.appendContentsOf("\(Utils.key(forIndex: i)) TEXT NOT NULL, ")
        }
        sql.appendContentsOf("value TEXT NOT NULL, ")
        sql.appendContentsOf("PRIMARY KEY\(Utils.columns(forNumberOfKeys: numberOfKeys, includeValueColumn: false))")
        sql.appendContentsOf(")")
        return sql
    }

    ///  Create and return sql template for replace with `table` and `numberOfKeys`.
    static func replace(into table: String, numberOfkeys: Int) -> String {
        return "REPLACE INTO \(table) "
            + "\(Utils.columns(forNumberOfKeys: numberOfkeys, includeValueColumn: true)) "
            + "values \(Utils.placeholder(forNumberOfKeys: numberOfkeys, includeValueColumn: true))"
    }

}

struct Utils {

    ///  Create and return columns for `numberOfKeys` with value column if `includeValueColumn` is true.
    static func columns(forNumberOfKeys numberOfKeys: Int, includeValueColumn: Bool) -> String {
        var columns = "("
        for i in 0..<numberOfKeys {
            columns.appendContentsOf(key(forIndex: i))
            if i != numberOfKeys - 1 {
                columns.appendContentsOf(", ")
            } else if includeValueColumn {
                columns.appendContentsOf(", value")
            }
        }
        columns.appendContentsOf(")")
        return columns
    }

    ///  Create and return placeholder for `numberOfKeys` with value column if `includeValueColumn` is true.
    static func placeholder(forNumberOfKeys numberOfKeys: Int, includeValueColumn: Bool) -> String {
        var columns = "("
        for i in 0..<numberOfKeys {
            columns.appendContentsOf("?")
            if i != numberOfKeys - 1 {
                columns.appendContentsOf(", ")
            } else if includeValueColumn {
                columns.appendContentsOf(", ?")
            }
        }
        columns.appendContentsOf(")")
        return columns
    }

    ///  Create and return key for `index`.
    static func key(forIndex index: Int) -> String {
        return "key\(index)"
    }
    
}