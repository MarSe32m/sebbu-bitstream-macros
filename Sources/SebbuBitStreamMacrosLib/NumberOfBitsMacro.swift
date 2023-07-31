//
//  NumberOfBitsMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct NumberOfBitsMacro: MemberAttributeMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        []
    }
    
    private static func getBits(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[0].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        }
        let message = SimpleDiagnosticMessage(message: "bits must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "intLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        guard let variableName = variableDecl.variableName else {
            let message = SimpleDiagnosticMessage(message: "Variable has no name.", diagnosticID: MessageID(domain: "", id: "no-variable-name"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.variableType != nil else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Number of bits can only be applied to variables of type UInt, UInt64, UInt32, UInt16 or UInt8. Explicitly provide the type annotation.", diagnosticID: MessageID(domain: "", id: "annotation"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.isSimpleType(of: "UInt", "UInt64", "UInt32", "UInt16", "UInt8") else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Number of bits can only be applied to variables of type UInt, UInt64, UInt32, UInt16 or UInt8.", diagnosticID: MessageID(domain: "", id: "only-uint"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        let arguments = try arguments(from: attribute, desiredAttributeCount: 1)
        
        let bits = try getBits(arguments)
        
        let maxAllowedBits =
            if variableDecl.isSimpleType(of: "UInt") {
                UInt.bitWidth
            } else if variableDecl.isSimpleType(of: "UInt64") {
                UInt64.bitWidth
            } else if variableDecl.isSimpleType(of: "UInt32") {
                UInt32.bitWidth
            } else if variableDecl.isSimpleType(of: "UInt16") {
                UInt16.bitWidth
            } else if variableDecl.isSimpleType(of: "UInt8") {
                UInt8.bitWidth
            } else {
                fatalError("Unreachable")
            }
        
        guard let intBits = Int(bits), intBits > 0, intBits <= maxAllowedBits else {
            let message = SimpleDiagnosticMessage(message: "The number of bits must be more than 0 and less than \(maxAllowedBits)", diagnosticID: MessageID(domain: "", id: "min < max"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let initSyntax = "self.\(variableName) = try stream.read(numberOfBits: \(bits))"
        let encodeSyntax = "stream.append(\(variableName), numberOfBits: \(bits))"
        return (initSyntax, encodeSyntax)
    }
}
