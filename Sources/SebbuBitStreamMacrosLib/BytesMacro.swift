//
//  BytesMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BytesMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@Bytes'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@Bytes")
        guard variableDecl.isArrayType(of: "UInt8") else {
            throw BitStreamCodingDiagnostic.custom("'@Bytes' can only be applied to byte arrays, i.e. [UInt8] or Array<UInt8>").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    private static func arguments(from attribute: SwiftSyntax.AttributeSyntax) throws -> [TupleExprElementSyntax] {
        // If there are no arguments, @Bytes was provided which is totally valid
        guard case .argumentList(let argumentList) = attribute.argument else {
            return []
        }
        return argumentList.children(viewMode: .sourceAccurate).compactMap { $0.as(TupleExprElementSyntax.self) }
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute)
        if arguments.count == 0 {
            let initSyntax = "self.\(variableName) = try stream.readBytes()"
            let encodeSyntax = "stream.appendBytes(\(variableName))"
            return (initSyntax, encodeSyntax)
        } else if arguments.count == 1 {
            let maxCount = try get(arguments, name: "maxCount", position: 0, as: .integer)
            
            guard let intMaxCount = Int(maxCount), intMaxCount > 0, intMaxCount < 1 << 29 else {
                throw BitStreamCodingDiagnostic.custom("Parameter maxCount must be more than zero and less than 2^29").error(at: Syntax(variableDecl))
            }
            let initSyntax = "self.\(variableName) = try stream.readBytes(maxCount: \(maxCount))"
            let encodeSyntax = "stream.appendBytes(\(variableName), maxCount: \(maxCount))"
            return (initSyntax, encodeSyntax)
        }
        throw BitStreamCodingDiagnostic.custom("Supply either maxCount parameter or no parameters.").error(at: Syntax(variableDecl))
    }
}
