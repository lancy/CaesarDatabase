//
//  CaesarDatabaseKeyValueExtensionTests.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import XCTest
import CaesarDatabase

class CaesarDatabaseKeyValueExtensionTests: XCTestCase {

    var db: Database!

    override func setUp() {
        super.setUp()
        db = Database(name: "test_kve.db")
    }
    
    override func tearDown() {
        let path = db.databasePath
        try! NSFileManager.defaultManager().removeItemAtPath(path)
        super.tearDown()
    }

    func testSimple() {
        let table = "Simple"
        try! db.create(table: table)

        // Test put and get
        db.putString("One", withKey: "1", into: table)
        db.putString("Two", withKey: "2", into: table)
        let one = db.getString(withKey: "1", from: table)
        let two = db.getString(withKey: "2", from: table)
        XCTAssert(one! == "One")
        XCTAssert(two! == "Two")

        // Test Delete
        db.deleteString(withKey: "1", from: table)
        let one1 = db.getString(withKey: "1", from: table)
        XCTAssert(one1 == nil)
        let two2 = db.getString(withKey: "2", from: table)
        XCTAssert(two2! == "Two")
    }

    func testBatch() {
        let table = "Batch"
        try! db.create(table: table)

        let strings = ["One", "Two", "Three"]
        let keys = ["1", "2", "3"]
        db.putStrings(strings, withKeys: keys, into: table)

        let result = db.getStrings(withKeys: keys, from: table)
        let one = result["1"]
        XCTAssert(one! == "One")
        let two = result["2"]
        XCTAssert(two! == "Two")
        let three = result["3"]
        XCTAssert(three! == "Three")

        db.putString("Zero", withKey: "0", into: table)
        let keys2 = ["0", "2"]
        let result2 = db.getStrings(withKeys: keys2, from: table)
        let zero = result2["0"]
        XCTAssert(zero! == "Zero")

        db.deleteStrings(withKeys: keys2, from: table)
        let keys3 = ["0", "1", "2", "3"]
        let result3 = db.getStrings(withKeys: keys3, from: table)
        let zero3 = result3["0"]
        XCTAssert(zero3 == nil)
        let one3 = result3["1"]
        XCTAssert(one3! == "One")
        let two3 = result3["2"]
        XCTAssert(two3 == nil)
        let three3 = result3["3"]
        XCTAssert(three3! == "Three")

        let result4 = db.getAllStrings(from: table)
        XCTAssert(result4.count == 2)
    }

}
