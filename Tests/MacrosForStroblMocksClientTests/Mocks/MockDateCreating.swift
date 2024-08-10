//
//  MockDateCreating.swift
//  StroblMacrosPOCTestFramework
//
// Created by Greg Strobl on 7/14/24.
// Copyright © 2024. All rights reserved.
//

@testable import MacrosForStroblMocksClient
import Foundation

public class MockDateCreating: DateCreating {

    public init() { }

    // MARK: - Variables for Protocol Conformance

    public var now = Date.now

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let dateTimeIntervalSinceNowCalled = Method(rawValue: 1 << 0)
    }
    private(set) public var calledMethods = Method()

    public struct MethodParameter: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let timeIntervalSinceNow = MethodParameter(rawValue: 1 << 0)
    }
    private(set) public var assignedParameters = MethodParameter()

    // MARK: - Variables for Captured Parameter Values

    private(set) public var timeIntervalSinceNow: TimeInterval?

    // MARK: - Variables to Use as Method Return Values

    public var dateTimeIntervalSinceNowReturnValue: Date!


    public func reset() {
        calledMethods = []
        assignedParameters = []
        timeIntervalSinceNow = nil
    }

    // MARK: - Methods for Protocol Conformance

    public func date(timeIntervalSinceNow: TimeInterval) -> Date {
        calledMethods.insert(.dateTimeIntervalSinceNowCalled)
        self.timeIntervalSinceNow = timeIntervalSinceNow
        assignedParameters.insert(.timeIntervalSinceNow)
        return dateTimeIntervalSinceNowReturnValue
    }

}

extension MockDateCreating.Method: CustomStringConvertible {
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

        if self.contains(.dateTimeIntervalSinceNowCalled) {
            handleFirst()
            value += ".dateTimeIntervalSinceNowCalled"
        }

        value += "]"
        return value
    }
}

extension MockDateCreating.MethodParameter: CustomStringConvertible {
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

        if self.contains(.timeIntervalSinceNow) {
            handleFirst()
            value += ".timeIntervalSinceNow"
        }

        value += "]"
        return value
    }
}

extension MockDateCreating: CustomReflectable {
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
