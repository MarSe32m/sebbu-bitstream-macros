//
//  BoundedArrayMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BoundedArrayMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@BoundedArray'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@BoundedArray")
        
        guard variableDecl.isArrayType() else {
            throw BitStreamCodingDiagnostic.custom("'@BoundedArray' can only be applied to arrays.").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 1)
        let maxCount = try get(arguments, name: "maxCount", position: 0, as: .integer)
        
        guard let intMaxCount = Int(maxCount), intMaxCount > 0, intMaxCount < 1 << 29 else {
            throw BitStreamCodingDiagnostic.custom("Parameter maxCount must be more than zero and less than 2^29").error(at: Syntax(variableDecl))
        }
        let initSyntax = "self.\(variableName) = try stream.read(maxCount: \(maxCount))"
        let encodeSyntax = "stream.append(\(variableName), maxCount: \(maxCount))"
        return (initSyntax, encodeSyntax)
    }
}
