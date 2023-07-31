//
//  MemberAttributeMacro + Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 30.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension MemberAttributeMacro {
    static func arguments(from attribute: SwiftSyntax.AttributeSyntax, desiredAttributeCount: Int) throws -> [TupleExprElementSyntax] {
        guard case .argumentList(let argumentList) = attribute.argument else {
            let message = SimpleDiagnosticMessage(message: "Attribute has no arguments", diagnosticID: MessageID(domain: "", id: "no-arguments"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(attribute), position: attribute.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let arguments = argumentList.children(viewMode: .sourceAccurate).compactMap { $0.as(TupleExprElementSyntax.self) }
        if desiredAttributeCount == arguments.count { return arguments }
        let message = SimpleDiagnosticMessage(message: "Attribute must have \(desiredAttributeCount) arguments", diagnosticID: MessageID(domain: "", id: "no-arguments"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(attribute), position: attribute.position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
}
