@testable import MacrosForStroblMocksClient
import Foundation

public class NonStroblCustomReflectableMock: CookieStoring {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct Method: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let setCookieCookieCalled = Method(rawValue: 1 << 0)
        public static let deleteCookieCookieCalled = Method(rawValue: 1 << 1)
        public static let cookiesForURLCalled = Method(rawValue: 1 << 2)
    }
    private(set) public var calledMethods = Method()

    public struct MethodParameter: OptionSet {
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
        calledMethods = []
        assignedParameters = []
        cookie = nil
        URL = nil
    }

    // MARK: - Methods for Protocol Conformance

    public func setCookie(_ cookie: HTTPCookie) {
        calledMethods.insert(.setCookieCookieCalled)
        self.cookie = cookie
        assignedParameters.insert(.cookie)
    }

    public func deleteCookie(_ cookie: HTTPCookie) {
        calledMethods.insert(.deleteCookieCookieCalled)
        self.cookie = cookie
        assignedParameters.insert(.cookie)
    }

    public func cookies(for URL: URL) -> [HTTPCookie]? {
        calledMethods.insert(.cookiesForURLCalled)
        self.URL = URL
        assignedParameters.insert(.URL)
        return cookiesForURLReturnValue
    }

}

extension NonStroblCustomReflectableMock.Method: CustomStringConvertible {
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

        if self.contains(.setCookieCookieCalled) {
            handleFirst()
            value += ".setCookieCookieCalled"
        }
        if self.contains(.deleteCookieCookieCalled) {
            handleFirst()
            value += ".deleteCookieCookieCalled"
        }
        if self.contains(.cookiesForURLCalled) {
            handleFirst()
            value += ".cookiesForURLCalled"
        }

        value += "]"
        return value
    }
}

extension NonStroblCustomReflectableMock.MethodParameter: CustomStringConvertible {
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

extension NonStroblCustomReflectableMock: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "cookie": cookie as Any,
                "URL": URL as Any
               ],
               displayStyle: .none
        )
    }
    
}
