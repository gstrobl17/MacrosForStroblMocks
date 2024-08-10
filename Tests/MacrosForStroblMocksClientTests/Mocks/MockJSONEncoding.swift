@testable import MacrosForStroblMocksClient
import Foundation

public class MockJSONEncoding: JSONEncoding {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let encodeValueCalled = Method(rawValue: 1 << 0)
    }
    private(set) public var calledMethods = Method()

    public struct MethodParameter: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let value = MethodParameter(rawValue: 1 << 0)
    }
    private(set) public var assignedParameters = MethodParameter()

    // MARK: - Variables for Captured Parameter Values

    private(set) public var value: Any?

    // MARK: - Variables to Use as Method Return Values

    public var encodeValueReturnValue: Data!

    public var errorToThrow: Error!
    public var encodeValueShouldThrowError = false


    public func reset() {
        calledMethods = []
        assignedParameters = []
        value = nil
    }

    // MARK: - Methods for Protocol Conformance

    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        calledMethods.insert(.encodeValueCalled)
        self.value = value
        assignedParameters.insert(.value)
        if encodeValueShouldThrowError && errorToThrow != nil {
            throw errorToThrow
        }
        return encodeValueReturnValue
    }

}

extension MockJSONEncoding.Method: CustomStringConvertible {
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

        if self.contains(.encodeValueCalled) {
            handleFirst()
            value += ".encodeValueCalled"
        }

        value += "]"
        return value
    }
}

extension MockJSONEncoding.MethodParameter: CustomStringConvertible {
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

        if self.contains(.value) {
            handleFirst()
            value += ".value"
        }

        value += "]"
        return value
    }
}

extension MockJSONEncoding: CustomReflectable {
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
