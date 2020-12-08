//
//  RiskyValue.swift
//  SQLite
//
//  Created by Christian Tietze on 08.12.20.
//  Copyright © 2020 Timing Software GmbH. All rights reserved.
//

public protocol RiskyValue : Expressible {
    associatedtype ValueType = Self
    associatedtype Datatype : Binding

    var datatypeValue: Datatype { get }
    static func fromDatatypeValue(_ datatypeValue: Datatype) throws -> ValueType
    static var declaredDatatype: String { get }
}
