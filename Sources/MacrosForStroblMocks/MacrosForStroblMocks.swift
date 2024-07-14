// The Swift Programming Language
// https://docs.swift.org/swift-book

/// This macro is used to mark variables in an XCTTestCase as being "Strobl" mocks. The **@StroblMock** macro is
/// used in conjunction with the **@UsesStroblMocks** macro to autogenerate code that is used to aid in testing
/// the mocks used in unit testing.
///
/// ```Swift
///     @StroblMock
///     var notificationCenter: MockNotificationProviding!
/// ```
///
@attached(peer)
public macro StroblMock() = #externalMacro(module: "MacrosForStroblMocksMacros", type: "StroblMockMacro")
