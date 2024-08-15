import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum UsesStroblMocksMacrooError: Error, CustomStringConvertible {
    case onlyWorksDirectlyOnClassOrStructDefinitions(String)
    
    var description: String {
        switch self {
        case .onlyWorksDirectlyOnClassOrStructDefinitions(let name):
            return "\(name) only works directly on class or struct definitions"
        }
    }
}

enum UsesStroblMocksMacroDiagnostic: DiagnosticMessage {
    case classOrStructContainsNoStroblMocks
    
    var severity: DiagnosticSeverity {
        switch self {
        case .classOrStructContainsNoStroblMocks: return .warning
        }
    }
    
    var message: String {
        switch self {
        case .classOrStructContainsNoStroblMocks:
            return "No @\(Constant.stroblMock) definitions found"
        }
    }
    
    var diagnosticID: MessageID {
        switch self {
        case .classOrStructContainsNoStroblMocks:
            return MessageID(domain: Constant.macrosForStroblMocks, id: "ClassOrStructContainsNoStroblMocks")
        }
    }
}

public struct UsesStroblMocksMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // @UsesStrobgMocks can't be put on an extension
        if declaration.is(ExtensionDeclSyntax.self) {
            throw UsesStroblMocksMacrooError.onlyWorksDirectlyOnClassOrStructDefinitions(node.trimmedDescription)
        }
        
        // Find all properties that are annotated as a @StroblMock
        let stroblMocks = findStroblMocks(in: declaration)
        guard !stroblMocks.isEmpty else {
            let noStroblMocksWarning = Diagnostic(node: declaration, message: UsesStroblMocksMacroDiagnostic.classOrStructContainsNoStroblMocks)
            context.diagnose(noStroblMocksWarning)
            return []
        }

        // Generate an enum with definitions for each Strobl mock
        let enumDecl = generateEnum(for: stroblMocks)

        // If the declaration is a class that subclasses XCTestCase, generate a custom XCT assertion
        if let classDecl = declaration.as(ClassDeclSyntax.self),
           classDecl.inheritanceClause?.inheritedTypes.first?.trimmedDescription == Constant.testSuperClass {

            // Generate a custom XCT Assertion to call to test for empty called methods/assigned parameters option sets in Strobl Mocks
            let funcDecl = generateCustomXCTAssertionFunctionDecl(for: stroblMocks)
            
            return [enumDecl.as(DeclSyntax.self)!, funcDecl]
        }
        
        // Look for @Test functions. If none are found, don't generate any output. We can be sure that
        //  Swift testing is being used or not.
        if containsTestFunctions(in: declaration) {
            
            // Generate Swift testing friendly "verify" function empty called methods/assigned parameters option sets in Strobl Mocks
            let funcDecl = generateVerifyFunctionDecl(for: stroblMocks)
            
            return [enumDecl.as(DeclSyntax.self)!, funcDecl]
        }

        // The declaration isn't an XCTestCase subclass or a containser of @Test funcs.
        return []
    }
    
    static func findStroblMocks(in declaration: some DeclGroupSyntax) -> [VariableDeclSyntax] {
        declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == Constant.stroblMock }}
    }

    static func generateEnum(for stroblMocks: [VariableDeclSyntax]) -> EnumDeclSyntax {
        // Generate an enum with definitions for each Strobl mock
        EnumDeclSyntax(name: TokenSyntax(stringLiteral: Constant.stroblMock)) {
            for varDecl in stroblMocks {
                let mockName = varDecl.bindings.first?.pattern.trimmedDescription ?? "??"
                DeclSyntax(stringLiteral: "case \(mockName)")
            }
        }
    }

    static func containsTestFunctions(in declaration: some DeclGroupSyntax) -> Bool {
        // Look for @Test func definitions that are members of the declaration
        let testFunctions = declaration.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter { $0.attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == Constant.testAnnotation }}
        guard testFunctions.isEmpty else { return true }
        
        // No @Test funcs found. Check in any sub-declarations
        var subDeclarations = [DeclGroupSyntax]()
        subDeclarations.append(contentsOf: declaration.memberBlock.members.compactMap { $0.decl.as(StructDeclSyntax.self) })
        subDeclarations.append(contentsOf: declaration.memberBlock.members.compactMap { $0.decl.as(ClassDeclSyntax.self) })
        subDeclarations.append(contentsOf: declaration.memberBlock.members.compactMap { $0.decl.as(EnumDeclSyntax.self) })
        guard !subDeclarations.isEmpty else { return false }
        for declaration in subDeclarations {
            guard !containsTestFunctions(in: declaration) else { return true }
        }
        return false
    }

    static func generateCustomXCTAssertionFunctionDecl(for stroblMocks: [VariableDeclSyntax]) -> DeclSyntax {
        generateCustomXCTAssertionFunctionDecl(
            for: stroblMocks,
            functionDefinition: "func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line)",
            failureCall: "XCTFail(message, file: file, line: line)"
        )
    }

    static func generateVerifyFunctionDecl(for stroblMocks: [VariableDeclSyntax]) -> DeclSyntax {
        generateCustomXCTAssertionFunctionDecl(
            for: stroblMocks,
            functionDefinition: "func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], sourceLocation: SourceLocation = #_sourceLocation)",
            failureCall: "Issue.record(Comment(rawValue: message), sourceLocation: sourceLocation)"
        )
    }

    static func generateCustomXCTAssertionFunctionDecl(
        for stroblMocks: [VariableDeclSyntax],
        functionDefinition: String,
        failureCall: String
    ) -> DeclSyntax {
        var functionString = """
            \(functionDefinition) {
                var issues = [String]()
            
                func evaluate(_ name: String, mock: Any) {
                    // The mock must conform to CustomReflectable.
                    guard let mock = mock as? any CustomReflectable else {
                        issues.append("'\\(name)' does not appear to be a Strobl Mock. It does not conform to CustomReflectable.")
                        return
                    }
            
                    // Look for four values in the mock: '\(Constant.calledMethods)', '\(Constant.assignedParameters)', '\(Constant.calledStaticMethods)', and '\(Constant.assignedStaticParameters)'.
                    // Either '\(Constant.calledMethods)' or '\(Constant.calledStaticMethods)' must exist. But all four values don't have to exist.
                    var aCalledMethodsPropertyFound = false
            
                    for (label, value) in mock.customMirror.children {
                        guard let label else { continue }
                        if label == "\(Constant.calledMethods)" || label == "\(Constant.calledStaticMethods)" { aCalledMethodsPropertyFound = true }
                        if label == "\(Constant.calledMethods)" || label == "\(Constant.assignedParameters)" || label == "\(Constant.calledStaticMethods)" || label == "\(Constant.assignedStaticParameters)" {
                            guard let value = value as? any CustomStringConvertible else {
                                issues.append("'\\(name)' does not appear to be a Strobl Mock. '\\(label)' is not CustomStringConvertible.")
                                continue
                            }
                            if value.description != "\(Constant.emptySet)" {
                                issues.append("'\\(name).\\(label)' == '\\(value)'")
                            }
                        }
                    }
            
                    if !aCalledMethodsPropertyFound {
                        issues.append("'\\(name)' does not appear to be a Strobl Mock. Neither '\(Constant.calledMethods)' or '\(Constant.calledStaticMethods)' properties were found.")
                    }
                }
            
            
            """
        for varDecl in stroblMocks {
            guard let patternBinding = varDecl.bindings.first else { continue }
            let variableName = patternBinding.pattern.trimmedDescription
            var unwrapClause = ""
            if let typeAnnotation = patternBinding.typeAnnotation,
                typeAnnotation.type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) || typeAnnotation.type.is(OptionalTypeSyntax.self) {
                unwrapClause = ", let \(variableName)"
            }
            functionString += """
                if !excludedMocks.contains(.\(variableName))\(unwrapClause) {
                    evaluate("\(variableName)", mock: \(variableName))
                }
            
            """
        }
        functionString += """
            
                if !issues.isEmpty {
                    if issues.count > 1 {
                        issues.insert("The following problems were identified:", at: 0)
                    }
                    let message = issues.joined(separator: \"\\n\\t\")
                    \(failureCall)
                }
            }
            """
        let funcDecl = DeclSyntax(stringLiteral: functionString)
        return funcDecl
    }
    
}

