//
//  IgnoreEquatable.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 16/03/2022.
//

import Foundation

@propertyWrapper public struct IgnoreEquatable<Value>: Equatable {

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    @inlinable public static func == (lhs: Self, rhs: Self) -> Bool { true }
}
