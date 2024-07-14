import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacrosForStroblMocksPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StroblMockMacro.self,
    ]
}
