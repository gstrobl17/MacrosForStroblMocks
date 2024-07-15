// The Swift Programming Language
// https://docs.swift.org/swift-book

/// This macro is used to mark variables in an ``XCTestCase`` as being "Strobl" mocks. The **@StroblMock** macro is
/// used in conjunction with the **@UsesStroblMocks** macro to autogenerate code that is used to aid in testing
/// the mocks used in unit testing.
///
/// Example of the use of **@StroblMock** in a property definition
///
/// ```
///     class Tests: XCTestCase {
///         @StroblMock
///         var notificationCenter: MockNotificationProviding!
///     }
/// ```
///
@attached(peer)
public macro StroblMock() = #externalMacro(module: "MacrosForStroblMocksMacros", type: "StroblMockMacro")


/// Use this macro on an ``XCTestCase`` to generate code to help test Strobl mocks not used in a specific test.
///
/// Given a test class with mocks defined like the following:
/// ```Swift
/// @UsesStroblMocks
/// class Tests: SomeClass, XCTestCase {
///     @StroblMock var mock1: Mock!
///     @StroblMock var mock2: Mock!
///     .
///     .
///     .
/// }
/// ```
///
/// This macro will define two elements.
///
/// 1. A **enum** that lists the **@StroblMock**
/// ```Swift
/// enum StroblMock {
///     case mock1
///     case mock2
///  }
/// ```
/// The **enum** is for use by the second element. (But you can use it if you want/need.)
///
/// 2. A helper custom XCT Assertion to eliminate the need to write `XCTAssertEquals(mock.calledMethods, [])` assertions
/// ```Swift
///  func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line)
/// ```
///
/// ## How to use verifyStroblMocksUnused(except:file:line:)
/// If you have a test that will not cause any interaction with the Strobl mocks, you can write the test like this:
/// ```
/// func testSomething() {
///     // Setup
///
///     // Call thing being tested
///
///     verifyStroblMocksUnused()
///     XCTAssert ... whatever needs to be tested
/// }
/// ```
/// When this test is run, it will test whatever is being tested and, by calling `verifyStroblMocksUnused()`, verifies that the Strobl mocks weren't used too.
///
/// When you have a test that will use one or more of the Strobl mocks, you can write the test like this:
/// ```
/// func testSomethingThatUsesMock1ButNotMock2() {
///     // Setup
///
///     // Call thing being tested
///
///     verifyStroblMocksUnused(except: .mock1)
///     XCTAssertEqual(mock1.calledMethods, [.someMethod])
///     XCTAssertEqual(mock1.assignedParameters, [])
///     XCTAssert ... whatever else needs to be tested
/// }
/// ```
///
@attached(member, names: named(StroblMock), named(verifyStroblMocksUnused(except:file:line:)))
public macro UsesStroblMocks() = #externalMacro(module: "MacrosForStroblMocksMacros", type: "UsesStroblMocksMacro")
