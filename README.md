# Macros for Strobl Mocks

A collection of Swift Macros for reducing the assertions required to test the injected dependencies in any given unit test fully.

Use the **@StroblMock** macro to mark Strobl mocks present in a test class:

```Swift
    @StroblMock var cookieStore: MockCookieStoring!
    @StroblMock var urlSession: MockDataTaskCreating!
    @StroblMock var dateFactory: MockDateCreating!
    @StroblMock var jsonDecoder: MockJSONDecoding!
    @StroblMock var jsonEncoder: MockJSONEncoding!
    @StroblMock var jsonSerializer: MockJSONSerializing!
    @StroblMock var semaphore: MockSemaphore!
```

Use the **@UsesStroblMocks** macro to generate helper code.

```Swift
@UsesStroblMocks
final class Test05OptionSetValueTests: XCTestCase {

...

}
```

The **@UsesStroblMocks** macro will define two elements.

1. A **enum** that lists the **@StroblMock**s in the test class:
 
	```Swift
	enum StroblMock {
   		case mock1
   		case mock2
	}
	```
	
	The **enum** is used by the second generated element. (You can use it if you want/need to.)
	
2. A helper custom XCT Assertion to eliminate the need to write `XCTAssertEquals(mock.calledMethods, [])` assertions

	```Swift
	func verifyStroblMocksUnused(
		except excludedMocks: Set<StroblMock> = [], 
		file: StaticString = #filePath, 
		line: UInt = #line
		)
	```

### How to use verifyStroblMocksUnused(except:file:line:)
If you have a test that will not cause any interaction with the Strobl mocks, you can write the test like this:

```Swift
func testSomething() {
     // Setup

     // Call thing being tested

     verifyStroblMocksUnused()
     XCTAssert ... whatever needs to be tested
}
```

When this test is run, it will test whatever is being tested and, by calling `verifyStroblMocksUnused()`, verifies that the Strobl mocks weren't used too.

---

When you have a test that will use one or more of the Strobl mocks, you can write the test like this:


```Swift
func testSomethingThatUsesMock1ButNotMock2() {
    // Setup
    // Call thing being tested
    verifyStroblMocksUnused(except: .mock1)
    XCTAssertEqual(mock1.calledMethods, [.someMethod])
    XCTAssertEqual(mock1.assignedParameters, [])
    XCTAssert ... whatever else needs to be tested
}
```

When this test is run, the call to `verifyStroblMocksUnused()` will test that all the Strobl mocks except `mock1` were not used. Then, the subsequent assertions verify the expected functionality of `mock1` was used.


