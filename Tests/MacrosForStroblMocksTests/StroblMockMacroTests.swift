//
//  StroblMockMacroTests.swift
//  
//
//  Created by Greg Strobl on 7/14/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class StroblMockMacroTests: XCTestCase {

    func testStroblMock_macroAnnotatesStoredProperty() {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            class tests: XCTTestCase {
                @StroblMock
                var mock: Mock!
            }
            """,
            expandedSource: """
            class tests: XCTTestCase {
                var mock: Mock!
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testStroblMock_macroAnnotatesFunction(){
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            class Tests: XCTTestCase {
                @StroblMock
                func foo() -> Bool { true }
            }
            """,
            expandedSource: """
            class Tests: XCTTestCase {
                func foo() -> Bool { true }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@StroblMock only works on variables", line: 2, column: 5)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testStroblMock_macroAnnotatesClass()  {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            @StroblMock
            class Tests: XCTTestCase {
                func foo() -> Bool { true }
            }
            """,
            expandedSource: """
            class Tests: XCTTestCase {
                func foo() -> Bool { true }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@StroblMock only works on variables", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testStroblMock_macroComputedProperty() {
#if canImport(MacrosForStroblMocksMacros)
        assertMacroExpansion(
            """
            class Tests: XCTTestCase {
                @StroblMock
                var mock: Mock {
                    Mock()
                }
            }
            """,
            expandedSource: """
            class Tests: XCTTestCase {
                var mock: Mock {
                    Mock()
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@StroblMock only works on stored properties", line: 2, column: 5)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

}
