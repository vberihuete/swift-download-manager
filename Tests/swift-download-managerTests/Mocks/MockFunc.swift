//
//  File.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

import Foundation

final class MockFunc<In, Out> {
    var parameters: [In] = []
    var result: () -> Out = { fatalError() }
    var invokedCount = 0

    static func mock(for function: (In) throws -> Out) -> MockFunc {
        return MockFunc()
    }

    var input: In {
        assert(!parameters.isEmpty, "Called before assigning params")
        return parameters[parameters.count - 1]
    }

    func callAndReturn(_ input: In) -> Out {
        invokedCount += 1
        parameters.append(input)
        return result()
    }

    func returns(_ value: Out) {
        result = { value }
    }

    func returns() where Out == Void {
        result = { () }
    }
}
