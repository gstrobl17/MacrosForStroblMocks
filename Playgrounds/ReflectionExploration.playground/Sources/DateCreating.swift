import Foundation

public protocol DateCreating {
    
    var now: Date { get }
    func date(timeIntervalSinceNow: TimeInterval) -> Date
    
}

public struct DateFactory {
    public init() { }
}

extension DateFactory: DateCreating {
    
    public var now: Date {
        return Date()
    }
    
    public func date(timeIntervalSinceNow interval: TimeInterval) -> Date {
        return Date(timeIntervalSinceNow: interval)
    }
    
}

public class MockDateCreating: DateCreating {
    
    public init() { }

    public var baseDate = Date(timeIntervalSince1970: 0)

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let now = Method(rawValue: 1)
        public static let dateTimeIntervalSinceNowCalled = Method(rawValue: 2)
    }
    public private(set) var calledMethods = Method()

    public struct MethodParameter: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let timeIntervalSinceNow = MethodParameter(rawValue: 1)
    }
    public private(set) var assignedParameters = MethodParameter()

    // MARK: - Variables for Captured Parameter Values

    public private(set) var timeIntervalSinceNow: TimeInterval?

    public func reset() {
        calledMethods = []
        assignedParameters = []
        timeIntervalSinceNow = nil
    }

    // MARK: - Methods for Protocol Conformance

    public var now: Date {
        calledMethods.insert(.now)
        return baseDate
    }

    public func date(timeIntervalSinceNow interval: TimeInterval) -> Date {
        calledMethods.insert(.dateTimeIntervalSinceNowCalled)
        self.timeIntervalSinceNow = interval
        assignedParameters.insert(.timeIntervalSinceNow)
        return baseDate.addingTimeInterval(interval)
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

        if self.contains(.now) {
            handleFirst()
            value += ".now"
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

