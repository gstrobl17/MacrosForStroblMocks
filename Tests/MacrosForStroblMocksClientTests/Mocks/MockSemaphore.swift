@testable import MacrosForStroblMocksClient
import Foundation

public class MockSemaphore: MacrosForStroblMocksClient.Semaphore {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let signalCalled = Method(rawValue: 1 << 0)
        public static let waitCalled = Method(rawValue: 1 << 1)
    }
    private(set) public var calledMethods = Method()

    // MARK: - Variables to Use as Method Return Values

    public var signalReturnValue = 0


    public func reset() {
        calledMethods = []
    }

    // MARK: - Methods for Protocol Conformance

    public func signal() -> Int {
        calledMethods.insert(.signalCalled)
        return signalReturnValue
    }

    public func wait() {
        calledMethods.insert(.waitCalled)
    }

}

extension MockSemaphore.Method: CustomStringConvertible {
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

        if self.contains(.signalCalled) {
            handleFirst()
            value += ".signalCalled"
        }
        if self.contains(.waitCalled) {
            handleFirst()
            value += ".waitCalled"
        }

        value += "]"
        return value
    }
}

extension MockSemaphore: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "calledMethods": calledMethods
               ],
               displayStyle: .none
        )
    }
    
}
