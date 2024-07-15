import UIKit

public protocol LoadingViewRepresentable {
    
    var message: String? { get }
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }

}

/// Protocol used to define the methods used by the `WaitingRoomModalControllerWindow` to find, hide,
/// and restore a `LoadingView` when a Waiting Room is displayed. It is designed to be conformed to by the `AssetAndAnimHelper`.
public protocol LoadingViewHandling {
    
    /// Answers the question of whether a loading view is being displayed or not
    /// - Returns: **true** or **false**
    static func isLoadingViewShown() -> Bool
    
    /// Method that returns the `UIWindow` that is displaying a `LoadingView` or the top window (if no loading view is being displayed)
    /// - Returns: `UIWindow` instance
    static func findLoadingViewWindowOrTopWindow() -> UIWindow
    
    /// Returns the `LoadingViewRepresentable` instance being displayed in the provided view
    /// - Returns: Reference to loading view or nil
    static func loadingView(in parentView: UIView) -> LoadingViewRepresentable?
 
    /// Method to hide a loading view
    static func hideLoadingView(in parentView: UIView?)
    
    /// Method to show a loading view
    static func showLoadingView(in parentView: UIView, topMargin: CGFloat, bottomMargin: CGFloat, message: String?)

}

public class MockLoadingViewHandling: LoadingViewHandling {

    public init() { }

    // MARK: - Variables for Trackings Method Invocation

    public struct StaticMethod: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let isLoadingViewShownCalled = StaticMethod(rawValue: 1 << 0)
        public static let findLoadingViewWindowOrTopWindowCalled = StaticMethod(rawValue: 1 << 1)
        public static let loadingViewInParentViewCalled = StaticMethod(rawValue: 1 << 2)
        public static let hideLoadingViewInParentViewCalled = StaticMethod(rawValue: 1 << 3)
        public static let showLoadingViewInParentViewTopMarginBottomMarginMessageCalled = StaticMethod(rawValue: 1 << 4)
    }
    private(set) public static var calledStaticMethods = StaticMethod()

    public struct StaticMethodParameter: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public static let parentView = StaticMethodParameter(rawValue: 1 << 0)
        public static let topMargin = StaticMethodParameter(rawValue: 1 << 1)
        public static let bottomMargin = StaticMethodParameter(rawValue: 1 << 2)
        public static let message = StaticMethodParameter(rawValue: 1 << 3)
    }
    private(set) public static var assignedStaticParameters = StaticMethodParameter()

    // MARK: - Variables for Captured Parameter Values

    private(set) public static var parentView: UIView?
    private(set) public static var topMargin: CGFloat?
    private(set) public static var bottomMargin: CGFloat?
    private(set) public static var message: String?

    // MARK: - Variables to Use as Method Return Values

    public static var isLoadingViewShownReturnValue = false
    public static var findLoadingViewWindowOrTopWindowReturnValue: UIWindow!
    public static var loadingViewInParentViewReturnValue: LoadingViewRepresentable?


    public func reset() {
        MockLoadingViewHandling.calledStaticMethods = []
        MockLoadingViewHandling.assignedStaticParameters = []
        MockLoadingViewHandling.parentView = nil
        MockLoadingViewHandling.topMargin = nil
        MockLoadingViewHandling.bottomMargin = nil
        MockLoadingViewHandling.message = nil
    }

    // MARK: - Methods for Protocol Conformance

    public static func isLoadingViewShown() -> Bool {
        calledStaticMethods.insert(.isLoadingViewShownCalled)
        return isLoadingViewShownReturnValue
    }

    public static func findLoadingViewWindowOrTopWindow() -> UIWindow {
        calledStaticMethods.insert(.findLoadingViewWindowOrTopWindowCalled)
        return findLoadingViewWindowOrTopWindowReturnValue
    }

    public static func loadingView(in parentView: UIView) -> LoadingViewRepresentable? {
        calledStaticMethods.insert(.loadingViewInParentViewCalled)
        self.parentView = parentView
        assignedStaticParameters.insert(.parentView)
        return loadingViewInParentViewReturnValue
    }

    public static func hideLoadingView(in parentView: UIView?) {
        calledStaticMethods.insert(.hideLoadingViewInParentViewCalled)
        self.parentView = parentView
        assignedStaticParameters.insert(.parentView)
    }

    public static func showLoadingView(in parentView: UIView, topMargin: CGFloat, bottomMargin: CGFloat, message: String?) {
        calledStaticMethods.insert(.showLoadingViewInParentViewTopMarginBottomMarginMessageCalled)
        self.parentView = parentView
        assignedStaticParameters.insert(.parentView)
        self.topMargin = topMargin
        assignedStaticParameters.insert(.topMargin)
        self.bottomMargin = bottomMargin
        assignedStaticParameters.insert(.bottomMargin)
        self.message = message
        assignedStaticParameters.insert(.message)
    }

}

extension MockLoadingViewHandling.StaticMethod: CustomStringConvertible {
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

        if self.contains(.isLoadingViewShownCalled) {
            handleFirst()
            value += ".isLoadingViewShownCalled"
        }
        if self.contains(.findLoadingViewWindowOrTopWindowCalled) {
            handleFirst()
            value += ".findLoadingViewWindowOrTopWindowCalled"
        }
        if self.contains(.loadingViewInParentViewCalled) {
            handleFirst()
            value += ".loadingViewInParentViewCalled"
        }
        if self.contains(.hideLoadingViewInParentViewCalled) {
            handleFirst()
            value += ".hideLoadingViewInParentViewCalled"
        }
        if self.contains(.showLoadingViewInParentViewTopMarginBottomMarginMessageCalled) {
            handleFirst()
            value += ".showLoadingViewInParentViewTopMarginBottomMarginMessageCalled"
        }

        value += "]"
        return value
    }
}

extension MockLoadingViewHandling.StaticMethodParameter: CustomStringConvertible {
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

        if self.contains(.parentView) {
            handleFirst()
            value += ".parentView"
        }
        if self.contains(.topMargin) {
            handleFirst()
            value += ".topMargin"
        }
        if self.contains(.bottomMargin) {
            handleFirst()
            value += ".bottomMargin"
        }
        if self.contains(.message) {
            handleFirst()
            value += ".message"
        }

        value += "]"
        return value
    }
}

extension MockLoadingViewHandling: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self,
               children: [
                "calledStaticMethods": MockLoadingViewHandling.calledStaticMethods,
                "assignedStaticParameters": MockLoadingViewHandling.assignedStaticParameters
               ],
               displayStyle: .none
        )
    }
    
}

