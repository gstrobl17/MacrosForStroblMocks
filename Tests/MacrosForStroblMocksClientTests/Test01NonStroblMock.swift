import MacrosForStroblMocks
import XCTest
@testable import MacrosForStroblMocksClient

@UsesStroblMocks
final class Test01NonStroblMock: XCTestCase {
    
    @StroblMock var mock: NonCustomReflectableMock!
    
    override func setUpWithError() throws {
        mock = NonCustomReflectableMock()
    }
    
    func testNonCustomReflectableMockCausesVerifyStroblMocksUnusedToFailWithNonStroblMockMessage() {
        let expectedDescription = "failed - 'mock' does not appear to be a Strobl Mock. It does not conform to CustomReflectable."
        let options = XCTExpectedFailure.Options()
        options.issueMatcher = { issue in
            issue.type == .assertionFailure && issue.compactDescription == expectedDescription
        }
        
        // Test needs to be run to get failure.
        // It should result in the following message:
        //
        //      'mock' does not appear to be a Strobl Mock. It does not conform to CustomReflectable.
        //
        XCTExpectFailure("This text exercises code generated by @UsesStroblMocks and should fail", options: options)
        verifyStroblMocksUnused()
    }
    
}
