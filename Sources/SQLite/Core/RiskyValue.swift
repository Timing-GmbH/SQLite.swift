//
//  RiskyValue.swift
//  SQLite
//
//  Created by Christian Tietze on 08.12.20.
//  Copyright © 2020 Timing Software GmbH. All rights reserved.
//

public protocol RiskyValue : Value {

    static func fromDatatypeValue(_ datatypeValue: Datatype) throws -> ValueType

}
