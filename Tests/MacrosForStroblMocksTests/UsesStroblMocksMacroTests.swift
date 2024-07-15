//
//  UsesStroblMocksMacroTests.swift
//  
//
//  Created by Greg Strobl on 7/15/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class UsesStroblMocksMacroTests: XCTestCase {
    
    let expectedEvaluateFunctionDefinition = """
                    func evaluate(_ name: String, mock: Any) {
                        // The mock must conform to CustomReflectable.
                        guard let mock = mock as? CustomReflectable else {
                            issues.append("'\\(name)' does not appear to be a Strobl Mock. It does not conform to CustomReflectable.")
                            return
                        }
            
                        // Look for four values in the mock: 'calledMethods', 'assignedParameters', 'calledStaticMethods', and 'assignedStaticParameters'.
                        // Either 'calledMethods' or 'calledStaticMethods' must exist. But all four values don't have to exist.
                        var aCalledMethodsPropertyFound = false
            
                        for (label, value) in mock.customMirror.children {
                            guard let label else {
                                continue
                            }
                            if label == "calledMethods" || label == "calledStaticMethods" {
                                aCalledMethodsPropertyFound = true
                            }
                            if label == "calledMethods" || label == "assignedParameters" || label == "calledStaticMethods" || label == "assignedStaticParameters" {
                                guard let value = value as? CustomStringConvertible else {
                                    issues.append("'\\(name)' does not appear to be a Strobl Mock. '\\(label)' is not CustomStringConvertible.")
                                    continue
                                }
                                if value.description != "[]" {
                                    issues.append("'\\(name).\\(label)' == '\\(value)'")
                                }
                            }
                        }
            
                        if !aCalledMethodsPropertyFound {
                            issues.append("'\\(name)' does not appear to be a Strobl Mock. Neither 'calledMethods' or 'calledStaticMethods' properties were found.")
                        }
                    }
            """
    
    func testUsesStroblMocks_usedOnStruct(){
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            struct Foo {
            }
            """,
            expandedSource: """
            struct Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@UsesStroblMocks only works on class definitions", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_usedOnEnum(){
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            enum Foo {
            }
            """,
            expandedSource: """
            enum Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@UsesStroblMocks only works on class definitions", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_usedOnExtension(){
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            extension Foo {
            }
            """,
            expandedSource: """
            extension Foo {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@UsesStroblMocks only works directly on class definitions", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_usedOnProperty(){
#if canImport(MacrosForStroblMocksMacros)
        // Macro is never expanded in this scenario
        assertMacroExpansion(
            """
            class Foo {
                @UsesStroblMocks
                var variable: Int
            }
            """,
            expandedSource: """
            class Foo {
                var variable: Int
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_unsubclassedClass(){
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            class Tests {
                @StroblMock var mock1: Mock
                @StroblMock var mock2: Mock!
            }
            """,
            expandedSource: """
            class Tests {
                var mock1: Mock
                var mock2: Mock!
            
                enum StroblMock {
                    case mock1
                    case mock2
                }
            
                func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line) {
                    var issues = [String] ()
            
            \(expectedEvaluateFunctionDefinition)
            
                    if !excludedMocks.contains(.mock1) {
                        evaluate("mock1", mock: mock1)
                    }
                    if !excludedMocks.contains(.mock2), let mock2 {
                        evaluate("mock2", mock: mock2)
                    }
            
                    if !issues.isEmpty {
                        if issues.count > 1 {
                            issues.insert("The following problems were identified:", at: 0)
                        }
                        let message = issues.joined(separator: "\\n\\t")
                        XCTFail(message, file: file, line: line)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@UsesStroblMocks is expected to be used on a direct subclass of XCTestCase",
                    line: 1,
                    column: 1,
                    severity: .warning
                ),
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_subclassedClassButNotFromXCTTestCase() {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            class Tests: SomeClass {
                @StroblMock var mock1: Mock
                @StroblMock var mock2: Mock!
            }
            """,
            expandedSource: """
            class Tests: SomeClass {
                var mock1: Mock
                var mock2: Mock!
            
                enum StroblMock {
                    case mock1
                    case mock2
                }
            
                func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line) {
                    var issues = [String] ()
            
            \(expectedEvaluateFunctionDefinition)
            
                    if !excludedMocks.contains(.mock1) {
                        evaluate("mock1", mock: mock1)
                    }
                    if !excludedMocks.contains(.mock2), let mock2 {
                        evaluate("mock2", mock: mock2)
                    }
            
                    if !issues.isEmpty {
                        if issues.count > 1 {
                            issues.insert("The following problems were identified:", at: 0)
                        }
                        let message = issues.joined(separator: "\\n\\t")
                        XCTFail(message, file: file, line: line)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@UsesStroblMocks is expected to be used on a direct subclass of XCTestCase",
                    line: 1,
                    column: 1,
                    severity: .warning
                ),
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_subclassedClassButNotDirectlyFromXCTTestCase() {
        // NOTE: This is (probably) and invalid class declaration
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            class Tests: SomeClass, XCTestCase {
                @StroblMock var mock1: Mock
                @StroblMock var mock2: Mock!
            }
            """,
            expandedSource: """
            class Tests: SomeClass, XCTestCase {
                var mock1: Mock
                var mock2: Mock!
            
                enum StroblMock {
                    case mock1
                    case mock2
                }
            
                func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line) {
                    var issues = [String] ()
            
            \(expectedEvaluateFunctionDefinition)
            
                    if !excludedMocks.contains(.mock1) {
                        evaluate("mock1", mock: mock1)
                    }
                    if !excludedMocks.contains(.mock2), let mock2 {
                        evaluate("mock2", mock: mock2)
                    }
            
                    if !issues.isEmpty {
                        if issues.count > 1 {
                            issues.insert("The following problems were identified:", at: 0)
                        }
                        let message = issues.joined(separator: "\\n\\t")
                        XCTFail(message, file: file, line: line)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@UsesStroblMocks is expected to be used on a direct subclass of XCTestCase",
                    line: 1,
                    column: 1,
                    severity: .warning
                ),
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testUsesStroblMocks_noStroblMockDefinitions() {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            class Tests: XCTestCase {
                var mock1: Mock
                var mock2: Mock!
            }
            """,
            expandedSource: """
            class Tests: XCTestCase {
                var mock1: Mock
                var mock2: Mock!
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "No @StroblMock definitions found",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    
    func testUsesStroblMocks_threeStroblMockDefinitions() {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @UsesStroblMocks
            class Tests: XCTestCase {
                @StroblMock var mock1: Mock
                @StroblMock var mock2: Mock?
                @StroblMock var mock3: Mock!
            }
            """,
            expandedSource: """
            class Tests: XCTestCase {
                var mock1: Mock
                var mock2: Mock?
                var mock3: Mock!
            
                enum StroblMock {
                    case mock1
                    case mock2
                    case mock3
                }
            
                func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line) {
                    var issues = [String] ()
            
            \(expectedEvaluateFunctionDefinition)
            
                    if !excludedMocks.contains(.mock1) {
                        evaluate("mock1", mock: mock1)
                    }
                    if !excludedMocks.contains(.mock2), let mock2 {
                        evaluate("mock2", mock: mock2)
                    }
                    if !excludedMocks.contains(.mock3), let mock3 {
                        evaluate("mock3", mock: mock3)
                    }
            
                    if !issues.isEmpty {
                        if issues.count > 1 {
                            issues.insert("The following problems were identified:", at: 0)
                        }
                        let message = issues.joined(separator: "\\n\\t")
                        XCTFail(message, file: file, line: line)
                    }
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
}
