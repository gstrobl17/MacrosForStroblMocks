//swiftlint:disable identifier_name single_test_class
import MacrosForStroblMocks
import Foundation
import XCTest

let dateFactory = DateFactory()
print(dateFactory.now)

@UsesStroblMocks
class ClassWithNoSubclass {
    var a = 5
}

@UsesStroblMocks
class ClassWithSubclassButNotXCTestCase: NSObject {
    var a = 5
}

@UsesStroblMocks
class TestClassWithNoStroblMockDefinitions: XCTestCase {
    var a = 5
}

@UsesStroblMocks
class TestClassWith1StroblMockDefinition: XCTestCase {
    @StroblMock
    var a = 5
}

//swiftlint:enable identifier_name single_test_class
