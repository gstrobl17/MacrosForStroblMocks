import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum UsesStroblMocksMacrooError: Error, CustomStringConvertible {
    case onlyWorksDirectlyOnClassDefinitions(String)
    case onlyWorksOnClassDefinitions(String)
    
    var description: String {
        switch self {
        case .onlyWorksDirectlyOnClassDefinitions(let name):
            return "\(name) only works directly on class definitions"
        case .onlyWorksOnClassDefinitions(let name):
            return "\(name) only works on class definitions"
        }
    }
}

enum UsesStroblMocksMacroDiagnostic: DiagnosticMessage {
    case unexpectedSuperClass(String)
    case classContainsNoStroblMocks
    
    var severity: DiagnosticSeverity {
        switch self {
        case .unexpectedSuperClass: return .warning
        case .classContainsNoStroblMocks: return .warning
        }
    }
    
    var message: String {
        switch self {
        case .unexpectedSuperClass(let name):
            return "\(name) is expected to be used on a direct subclass of \(Constant.testSuperClass)"
        case .classContainsNoStroblMocks:
            return "No @\(Constant.stroblMock) definitions found"
        }
    }
    
    var diagnosticID: MessageID {
        switch self {
        case .unexpectedSuperClass:
            return MessageID(domain: Constant.macrosForStroblMocks, id: "UnexpectedSuperClass")
        case .classContainsNoStroblMocks:
            return MessageID(domain: Constant.macrosForStroblMocks, id: "ClassContainsNoStroblMocks")
        }
    }
}

public struct UsesStroblMocksMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration.is(ExtensionDeclSyntax.self) {
            throw UsesStroblMocksMacrooError.onlyWorksDirectlyOnClassDefinitions(node.trimmedDescription)
        }
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw UsesStroblMocksMacrooError.onlyWorksOnClassDefinitions(node.trimmedDescription)
        }
        
        // The macro is expected to be applied to a class directly subclassing XCTestCase.
        //  If it doesn't, supply a warning.
        if classDecl.inheritanceClause?.inheritedTypes.first?.trimmedDescription != Constant.testSuperClass {
            let subclassWarning = Diagnostic(node: classDecl, message: UsesStroblMocksMacroDiagnostic.unexpectedSuperClass(node.trimmedDescription))
            context.diagnose(subclassWarning)
        }
        
        // Find all properties that are annotated as a @StroblMock
        let stroblMocks = classDecl.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == Constant.stroblMock }}
        guard !stroblMocks.isEmpty else {
            let noStroblMocksWarning = Diagnostic(node: classDecl, message: UsesStroblMocksMacroDiagnostic.classContainsNoStroblMocks)
            context.diagnose(noStroblMocksWarning)
            return []
        }
        
        // Generate an enum with definitions for each Strobl mock
        let enumDecl = EnumDeclSyntax(name: TokenSyntax(stringLiteral: Constant.stroblMock)) {
            for varDecl in stroblMocks {
                let mockName = varDecl.bindings.first?.pattern.trimmedDescription ?? "??"
                DeclSyntax(stringLiteral: "case \(mockName)")
            }
        }
        
        // Generate a custom XCT Assertion to call to test for empty called methods/assigned parameters option sets in Strobl Mocks
        var functionString = """
            func verifyStroblMocksUnused(except excludedMocks: Set<StroblMock> = [], file: StaticString = #filePath, line: UInt = #line) {
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
                    XCTFail(message, file: file, line: line)
                }
            }
            """
        let funcDecl = DeclSyntax(stringLiteral: functionString)
        
        return [enumDecl.as(DeclSyntax.self)!, funcDecl]
    }
    
}

