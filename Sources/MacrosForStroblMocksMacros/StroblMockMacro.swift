import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum StroblMockMacroError: Error, CustomStringConvertible {
    case onlyWorksOnVariables(String)
    case onlyWorksOnStoredProperties(String)
    
    var description: String {
        switch self {
        case .onlyWorksOnVariables(let name):
            return "\(name) only works on variables"
        case .onlyWorksOnStoredProperties(let name):
            return "\(name) only works on stored properties"
        }
    }
}

// Implementation of the `@StroblMock` macro. This macro doesn't generate any extra code.
/// It is just used as a token for use by the `@UsesStroblMocks` macro which adds code generation to
/// an `XCTestCase` impelementation.
///
/// This macro should only be used on stored property definitions.
public struct StroblMockMacro: PeerMacro {
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw StroblMockMacroError.onlyWorksOnVariables(node.trimmedDescription)
        }
        guard varDecl.bindings.first?.accessorBlock == nil else {
            throw StroblMockMacroError.onlyWorksOnStoredProperties(node.trimmedDescription)
        }
        return []
    }
    
}
