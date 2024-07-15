import MacrosForStroblMocks


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
