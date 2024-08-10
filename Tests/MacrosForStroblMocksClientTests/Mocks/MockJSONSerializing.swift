@testable import MacrosForStroblMocksClient
import Foundation

public class MockJSONSerializing: JSONSerializing {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct StaticMethod: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let dataWithJSONObjectObjOptionsOptCalled = StaticMethod(rawValue: 1 << 0)
        public static let jsonObjectWithDataOptionsOptCalled = StaticMethod(rawValue: 1 << 1)
    }
    nonisolated(unsafe) private(set) public static var calledStaticMethods = StaticMethod()

    public struct StaticMethodParameter: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let obj = StaticMethodParameter(rawValue: 1 << 0)
        public static let opt = StaticMethodParameter(rawValue: 1 << 1)
        public static let data = StaticMethodParameter(rawValue: 1 << 2)
        public static let opt1 = StaticMethodParameter(rawValue: 1 << 3)
    }
    nonisolated(unsafe) private(set) public static var assignedStaticParameters = StaticMethodParameter()

    // MARK: - Variables for Captured Parameter Values

    nonisolated(unsafe) private(set) public static var obj: Any?
    nonisolated(unsafe) private(set) public static var opt: JSONSerialization.WritingOptions?
    nonisolated(unsafe) private(set) public static var data: Data?
    nonisolated(unsafe) private(set) public static var opt1: JSONSerialization.ReadingOptions?

    // MARK: - Variables to Use as Method Return Values

    nonisolated(unsafe) public static var dataWithJSONObjectObjOptionsOptReturnValue = Data()
    nonisolated(unsafe) public static var jsonObjectWithDataOptionsOptReturnValue: Any = ["a": "b"]

    nonisolated(unsafe) public static var errorToThrow: Error!
    nonisolated(unsafe) public static var dataWithJSONObjectObjOptionsOptShouldThrowError = false
    nonisolated(unsafe) public static var jsonObjectWithDataOptionsOptShouldThrowError = false

    public func reset() {
        MockJSONSerializing.calledStaticMethods = []
        MockJSONSerializing.assignedStaticParameters = []
        MockJSONSerializing.obj = nil
        MockJSONSerializing.opt = nil
        MockJSONSerializing.data = nil
        MockJSONSerializing.opt1 = nil
    }

    // MARK: - Methods for Protocol Conformance

    public static func data(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions) throws -> Data {
        calledStaticMethods.insert(.dataWithJSONObjectObjOptionsOptCalled)
        self.obj = obj
        assignedStaticParameters.insert(.obj)
        self.opt = opt
        assignedStaticParameters.insert(.opt)
        if dataWithJSONObjectObjOptionsOptShouldThrowError && errorToThrow != nil {
            throw errorToThrow
        }
        return dataWithJSONObjectObjOptionsOptReturnValue
    }

    public static func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions) throws -> Any {
        calledStaticMethods.insert(.jsonObjectWithDataOptionsOptCalled)
        self.data = data
        assignedStaticParameters.insert(.data)
        self.opt1 = opt
        assignedStaticParameters.insert(.opt1)
        if jsonObjectWithDataOptionsOptShouldThrowError && errorToThrow != nil {
            throw errorToThrow
        }
        return jsonObjectWithDataOptionsOptReturnValue
    }

}

extension MockJSONSerializing.StaticMethod: CustomStringConvertible {
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

        if self.contains(.dataWithJSONObjectObjOptionsOptCalled) {
            handleFirst()
            value += ".dataWithJSONObjectObjOptionsOptCalled"
        }
        if self.contains(.jsonObjectWithDataOptionsOptCalled) {
            handleFirst()
            value += ".jsonObjectWithDataOptionsOptCalled"
        }

        value += "]"
        return value
    }
}

extension MockJSONSerializing.StaticMethodParameter: CustomStringConvertible {
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

        if self.contains(.obj) {
            handleFirst()
            value += ".obj"
        }
        if self.contains(.opt) {
            handleFirst()
            value += ".opt"
        }
        if self.contains(.data) {
            handleFirst()
            value += ".data"
        }
        if self.contains(.opt1) {
            handleFirst()
            value += ".opt1"
        }

        value += "]"
        return value
    }
}

extension MockJSONSerializing: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "calledStaticMethods": MockJSONSerializing.calledStaticMethods,
                "assignedStaticParameters": MockJSONSerializing.assignedStaticParameters
               ],
               displayStyle: .none
        )
    }
    
}
