//
//  BytesMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BytesMacro: MemberAttributeMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        []
    }
    
    private static func getMaxCount(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[0].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        }
        let message = SimpleDiagnosticMessage(message: "maxCount must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "integerLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    private static func arguments(from attribute: SwiftSyntax.AttributeSyntax) throws -> [TupleExprElementSyntax] {
        // If there are no arguments, @Bytes was provided which is totally valid
        guard case .argumentList(let argumentList) = attribute.argument else {
            return []
        }
        return argumentList.children(viewMode: .sourceAccurate).compactMap { $0.as(TupleExprElementSyntax.self) }
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        guard let variableName = variableDecl.variableName else {
            let message = SimpleDiagnosticMessage(message: "Variable has no name.", diagnosticID: MessageID(domain: "", id: "no-variable-name"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.variableType != nil else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Explicitly provide the type annotation.", diagnosticID: MessageID(domain: "", id: "annotation"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.isArrayType(of: "UInt8") else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Bytes annotation can only be applied to byte arrays, i.e. [UInt8] or Array<UInt8>", diagnosticID: MessageID(domain: "", id: "only-arrays"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let arguments = try arguments(from: attribute)
        if arguments.count == 0 {
            let initSyntax = "self.\(variableName) = try stream.readBytes()"
            let encodeSyntax = "stream.appendBytes(\(variableName))"
            return (initSyntax, encodeSyntax)
        } else if arguments.count == 1 {
            let maxCount = try getMaxCount(arguments)
            
            guard let intMaxCount = Int(maxCount), intMaxCount > 0, intMaxCount < 1 << 29 else {
                let message = SimpleDiagnosticMessage(message: "maxCount must be more than zero and less than 2^29", diagnosticID: MessageID(domain: "", id: "maxCount < 1 << 29"), severity: .error)
                let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
                throw DiagnosticsError(diagnostics: [diagnostic])
            }
            let initSyntax = "self.\(variableName) = try stream.readBytes(maxCount: \(maxCount))"
            let encodeSyntax = "stream.appendBytes(\(variableName), maxCount: \(maxCount))"
            return (initSyntax, encodeSyntax)
        }
        let message = SimpleDiagnosticMessage(message: "Supply either maxCount parameter or no parameters", diagnosticID: MessageID(domain: "", id: "0 or 1 args"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
}
