//
//  MockJSONDecoding.swift
//  StroblMacrosPOCTestFramework
//
// Created by Greg Strobl on 7/14/24.
// Copyright © 2024. All rights reserved.
//

@testable import MacrosForStroblMocksClient
import Foundation

public enum MockJSONDecodingError: Error {
    case typeOfReturnValueDoesNotMatch
}

public class MockJSONDecoding: JSONDecoding {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let decodeTypeFromDataCalled = Method(rawValue: 1 << 0)
    }
    private(set) public var calledMethods = Method()

    public struct MethodParameter: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let type = MethodParameter(rawValue: 1 << 0)
        public static let data = MethodParameter(rawValue: 1 << 1)
    }
    private(set) public var assignedParameters = MethodParameter()

    // MARK: - Variables for Captured Parameter Values

    private(set) public var type: Any.Type?
    private(set) public var data: Data?

    // MARK: - Variables to Use as Method Return Values

    public var decodeTypeFromDataReturnValue: Any = "Default Value"

    public var errorToThrow: Error!
    public var decodeTypeFromDataShouldThrowError = false


    public func reset() {
        calledMethods = []
        assignedParameters = []
        type = nil
        data = nil
    }

    // MARK: - Methods for Protocol Conformance

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        calledMethods.insert(.decodeTypeFromDataCalled)
        self.type = type
        assignedParameters.insert(.type)
        self.data = data
        assignedParameters.insert(.data)
        if decodeTypeFromDataShouldThrowError && errorToThrow != nil {
            throw errorToThrow
        }
        guard let returnValue = decodeTypeFromDataReturnValue as? T else { throw MockJSONDecodingError.typeOfReturnValueDoesNotMatch }
        return returnValue
    }

}

extension MockJSONDecoding.Method: CustomStringConvertible {
    public var description: String {
        var value = "["
        var first = true
        func handleFirst() {
            if first {
                first = false
            } else {
                value += ", "
            }
        }

        if self.contains(.decodeTypeFromDataCalled) {
            handleFirst()
            value += ".decodeTypeFromDataCalled"
        }

        value += "]"
        return value
    }
}

extension MockJSONDecoding.MethodParameter: CustomStringConvertible {
    public var description: String {
        var value = "["
        var first = true
        func handleFirst() {
            if first {
                first = false
            } else {
                value += ", "
            }
        }

        if self.contains(.type) {
            handleFirst()
            value += ".type"
        }
        if self.contains(.data) {
            handleFirst()
            value += ".data"
        }

        value += "]"
        return value
    }
}

extension MockJSONDecoding: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "calledMethods": calledMethods,
                "assignedParameters": assignedParameters
               ],
               displayStyle: .none
        )
    }
    
}
