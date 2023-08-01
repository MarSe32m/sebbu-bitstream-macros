//
//  NumberOfBitsMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct NumberOfBitsMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@NumberOfBits'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@NumberOfBits")
        guard variableDecl.isSimpleType(of: "UInt", "UInt64", "UInt32", "UInt16", "UInt8") else {
            throw BitStreamCodingDiagnostic.custom("@NumberOfBits can only be applied to variables of type UInt, UInt64, UInt32, UInt16 or UInt8").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 1)
        let bits = try get(arguments, name: "bits", position: 0, as: .integer)
        
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
            throw BitStreamCodingDiagnostic.custom("The number of btis must he more than 0 and less than \(maxAllowedBits)").error(at: Syntax(variableDecl))
        }
        let initSyntax = "self.\(variableName) = try stream.read(numberOfBits: \(bits))"
        let encodeSyntax = "stream.append(\(variableName), numberOfBits: \(bits))"
        return (initSyntax, encodeSyntax)
    }
}
