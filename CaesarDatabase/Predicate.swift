//
//  Predicate.swift
//  CaesarDatabase
//
//  Created by Chenyu Lan on 6/17/16.
//  Copyright © 2016 Chenyu Lan. All rights reserved.
//

import Foundation

///  Abstract predicate protocol.
public protocol Predicate {

    /// The raw predicate SQL.
    var predicateSQL: String { get }

}

///  Equal predicate, genreate SQL as "key\(keyIndex) = \(target)".
public struct EqualPredicate: Predicate {

    /// The key index.
    let keyIndex: Int

    ///  The target value that key should equal to.
    let target: String

    /// The genereated SQL.
    public var predicateSQL: String {
        return "\(Utils.key(forIndex: keyIndex)) = \'\(target)\'"
    }

}

///  In predicate, generate SQL as "key\(keyIndex) in (\(targets))"
public struct InPredicate: Predicate {

    /// The key index.
    let keyIndex: Int

    ///  The targets values that key should inside.
    let targets: [String]

    /// The genereated SQL.
    public var predicateSQL: String {
        let fixedTargets = targets.map { target in
            return "\'\(target)\'"
        }
        let joinedTargets = fixedTargets.joinWithSeparator(",")
        return "\(Utils.key(forIndex: keyIndex)) IN (\(joinedTargets))"
    }

}

///  And predicate, combine sub-predicates with AND operator.
///  Generate SQL as "(predicate0 AND predicate1 AND predicate2 ...)
public struct AndPredicate: Predicate {

    ///  The sub-predicates to be combine.
    let predicates: [Predicate]

    /// The genereated SQL.
    public var predicateSQL: String {
        let sql = predicates.map { predicate in
            return predicate.predicateSQL
            }.joinWithSeparator(" AND ")
        return "(\(sql))"
    }

}

///  Or predicate, combine sub-predicates with OR operator.
///  Generate SQL as "(predicate0 OR predicate1 OR predicate2 ...)
public struct OrPredicate: Predicate {

    ///  The sub-predicates to be combine.
    let predicates: [Predicate]

    /// The genereated SQL.
    public var predicateSQL: String {
        let sql = predicates.map { predicate in
            return predicate.predicateSQL
            }.joinWithSeparator(" OR ")
        return "(\(sql))"
    }
    
}

//  Mark: - Operator for convenience

public func &&(lhs: Predicate, rhs: Predicate) -> AndPredicate {
    return AndPredicate(predicates: [lhs, rhs])
}

public func ||(lhs: Predicate, rhs: Predicate) -> OrPredicate {
    return OrPredicate(predicates: [lhs, rhs])
}
