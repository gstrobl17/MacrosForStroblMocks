
@testable import MacrosForStroblMocksClient
import Foundation

public class MockWithoutCalledMethodsProperty: CookieStoring {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct MethodParameter: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let cookie = MethodParameter(rawValue: 1 << 0)
        public static let URL = MethodParameter(rawValue: 1 << 1)
    }
    private(set) public var assignedParameters = MethodParameter()

    // MARK: - Variables for Captured Parameter Values

    private(set) public var cookie: HTTPCookie?
    private(set) public var URL: URL?

    // MARK: - Variables to Use as Method Return Values

    public var cookiesForURLReturnValue: [HTTPCookie]?


    public func reset() {
        assignedParameters = []
        cookie = nil
        URL = nil
    }

    // MARK: - Methods for Protocol Conformance

    public func setCookie(_ cookie: HTTPCookie) {
        self.cookie = cookie
        assignedParameters.insert(.cookie)
    }

    public func deleteCookie(_ cookie: HTTPCookie) {
        self.cookie = cookie
        assignedParameters.insert(.cookie)
    }

    public func cookies(for URL: URL) -> [HTTPCookie]? {
        self.URL = URL
        assignedParameters.insert(.URL)
        return cookiesForURLReturnValue
    }

}

extension MockWithoutCalledMethodsProperty.MethodParameter: CustomStringConvertible {
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

        if self.contains(.cookie) {
            handleFirst()
            value += ".cookie"
        }
        if self.contains(.URL) {
            handleFirst()
            value += ".URL"
        }

        value += "]"
        return value
    }
}

extension MockWithoutCalledMethodsProperty: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "assignedParameters": assignedParameters
               ],
               displayStyle: .none
        )
    }
    
}
