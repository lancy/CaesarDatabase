//
//  CaesarDatabaseTests.swift
//  CaesarDatabaseTests
//
//  Created by Chenyu Lan on 6/16/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import XCTest
@testable import CaesarDatabase

private let kTestCount = 10000;

class CaesarDatabaseTests: XCTestCase {

    var db: Database!

    var performaceItems: [Item]!

    override func setUp() {
        super.setUp()
        db = Database(name: "test.db")

        var items = [Item]()
        for i in 0..<kTestCount {
            let positive = arc4random() % 2 == 0 ? "positive" : "negative"
            let item = Item(keys: [String(i), "number", positive], value: "Sample")
            items.append(item)
        }
        performaceItems = items
    }
    
    override func tearDown() {
        let path = db.databasePath
        try! NSFileManager.defaultManager().removeItemAtPath(path)
        super.tearDown()
    }

    func testCreateTable() {
        try! db.create(table: "TestTable")
    }

    func testCreateTableWithNumberOfKeys() {
        try! db.create(table: "TestTableN", numberOfKeys: 3)
    }

    func testSimplePutAndGetItem() {
        let table = "Table1"
        try! db.create(table: table)
        let item = Item(key: "1", value: "One")
        try! db.put(item, into: table)
        
        let predicate = EqualPredicate(keyIndex: 0, target: "1")
        let result = db.getOne(where: predicate, from: table)!
        XCTAssert(result.key == "1")
        XCTAssert(result.value == "One")
        
        try! db.deleteAll(from: table)
        XCTAssert(db.isEmpty(table: table))
    }

    func testIsTableEmpty() {
        let table = "Table2";
        try! db.create(table: table)
        XCTAssert(db.isEmpty(table: table))
        
        let item = Item(key: "1", value: "One")
        try! db.put(item, into: table)
        
        XCTAssert(!db.isEmpty(table: table))
    }

    func testMultipleKeyPutAndGetItem() {
        let table = "Table3";
        try! db.create(table: table, numberOfKeys: 3)
        let item1 = Item(keys: ["1", "number", "positive"], value: "One")
        let item2 = Item(keys: ["2", "number", "positive"], value: "Two")
        let item3 = Item(keys: ["3", "number", "negative"], value: "-Three")
        let item4 = Item(keys: ["yo!", "string", "positive"], value: "YO!")

        // Test put and batch put.
        try! db.put(item1, into: table)
        try! db.put([item2, item3, item4], into: table)

        // Test single predicate
        let number = EqualPredicate(keyIndex: 1, target: "number")
        let result0 = db.getAll(where: number, from: table)
        XCTAssert(result0.count == 3)

        let positive = EqualPredicate(keyIndex: 2, target: "positive")
        let result1 = db.getAll(where: positive, from: table)
        XCTAssert(result1.count == 3)

        // Test multiple predicates
        let positiveAndNumber  = positive && number
        let result2 = db.getAll(where: positiveAndNumber, from: table)
        XCTAssert(result2.count == 2)

        let negative = EqualPredicate(keyIndex: 2, target: "negative")
        let negativeAndNumber = negative && number
        let result3 = db.getAll(where: negativeAndNumber, from: table)
        XCTAssert(result3.count == 1)

        // Test item keys and value.
        let item = result3.first!
        XCTAssert(item.keys.count == 3)
        XCTAssert(item.keys[0] == "3")
        XCTAssert(item.keys[1] == "number")
        XCTAssert(item.keys[2] == "negative")
        XCTAssert(item.value == "-Three")

        // Test get all items.
        let result4 = db.getAll(from: table)
        XCTAssert(result4.count == 4)

        // Test or predicate
        let string = EqualPredicate(keyIndex: 1, target: "string")
        let stringOrNegative = string || negative
        let resultSON = db.getAll(where: stringOrNegative, from: table)
        XCTAssert(resultSON.count == 2)

        // Test complicated predicate
        let three = EqualPredicate(keyIndex: 0, target: "3")
        let stringOrNegativeThree = (string || negative) && three
        let resultSONT = db.getAll(where: stringOrNegativeThree, from: table)
        XCTAssert(resultSONT.count == 1)
        let itemSONT = resultSONT.first!
        XCTAssert(itemSONT.keys.count == 3)
        XCTAssert(itemSONT.keys[0] == "3")
        XCTAssert(itemSONT.keys[1] == "number")
        XCTAssert(itemSONT.keys[2] == "negative")
        XCTAssert(itemSONT.value == "-Three")

        // Test query miss
        let miss = EqualPredicate(keyIndex: 0, target: "MISS")
        let missItem = db.getOne(where: miss, from: table)
        XCTAssert(missItem == nil)
        let result5 = db.getAll(where: miss, from: table)
        XCTAssert(result5.count == 0)

        // Test contain predicate
        let contain = InPredicate(keyIndex: 0, targets: ["2", "3", "4"])
        let result6 = db.getAll(where: contain, from: table)
        XCTAssert(result6.count == 2)

        // Test delete items
        try! db.delete(where: number, from: table)
        let resultEnd = db.getAll(where: positive, from: table)
        XCTAssert(resultEnd.count == 1)

        try! db.deleteAll(from: table)
        XCTAssert(db.isEmpty(table: table))
    }

    func testWriteHugeData() {
        // iPhone 4 iOS 8 has SQLITE_MAX_COMPOUND_SELECT upto 500.
        let table = "TableHuge"
        try! db.create(table: table, numberOfKeys: 3)
        try! db.put(performaceItems, into: table)

        let result = db.getAll(from: table)
        XCTAssert(result.count == kTestCount)
    }

    func testDropTable() {
        let table = "TableDrop"
        try! db.create(table: table)
        XCTAssert(db.isEmpty(table: table))

        let item = Item(key: "1", value: "One")
        try! db.put(item, into: table)
        XCTAssert(!db.isEmpty(table: table))

        // Drop Table
        try! db.drop(table: table)

        // Create table with two key
        try! db.create(table: table, numberOfKeys: 2)
        XCTAssert(db.isEmpty(table: table))

        let item2 = Item(keys: ["1", "2"], value: "Two")
        try! db.put(item2, into: table)

        let predicate = EqualPredicate(keyIndex: 1, target: "2")
        let result = db.getOne(where: predicate, from: table)
        XCTAssert(result!.value == "Two")
    }

    func testWritePerformance() {
        let table = "TableW"
        try! db.create(table: table, numberOfKeys: 3)
        measureMetrics(self.dynamicType.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) {
            self.startMeasuring()
            try! self.db.put(self.performaceItems, into: table)
            self.stopMeasuring()
            try! self.db.deleteAll(from: table)
        }
    }

    func testReadPerformance() {
        let number = EqualPredicate(keyIndex: 1, target: "number")
        let table = "TableR"
        try! db.create(table: table, numberOfKeys: 3)

        measureMetrics(self.dynamicType.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) {
            try! self.db.put(self.performaceItems, into: table)
            self.startMeasuring()
            self.db.getAll(where: number, from: table)
            self.stopMeasuring()
            try! self.db.deleteAll(from: table)
        }
    }

    func testDeletePerformance() {
        let positive = EqualPredicate(keyIndex: 2, target: "positive")
        let table = "TableD"
        try! db.create(table: table, numberOfKeys: 3)

        measureMetrics(self.dynamicType.defaultPerformanceMetrics(), automaticallyStartMeasuring: false) {
            try! self.db.put(self.performaceItems, into: table)
            self.startMeasuring()
            try! self.db.delete(where: positive, from: table)
            self.stopMeasuring()
            try! self.db.deleteAll(from: table)
        }
    }

}
