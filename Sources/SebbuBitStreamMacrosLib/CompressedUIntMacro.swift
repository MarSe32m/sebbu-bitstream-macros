//
//  CompressedUIntMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedUIntMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@CompressedUInt'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@CompressedUInt")
        guard variableDecl.isSimpleType(of: "UInt", "UInt64", "UInt32", "UInt16", "UInt8") else {
            throw BitStreamCodingDiagnostic.custom("Unsigned integer compression can only be applied to variables of type UInt, UInt64, UInt32, UInt16 or UInt8").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 2)
        
        let minValue = try get(arguments, name: "min", position: 0, as: .integer)
        let maxValue = try get(arguments, name: "max", position: 1, as: .integer)
        
        let (minAllowed, maxAllowed) =
            if variableDecl.isSimpleType(of: "UInt") {
                (0, UInt64(UInt.max))
            } else if variableDecl.isSimpleType(of: "UInt64") {
                (0, UInt64.max)
            } else if variableDecl.isSimpleType(of: "UInt32") {
                (0, UInt64(UInt32.max))
            } else if variableDecl.isSimpleType(of: "UInt16") {
                (0, UInt64(UInt16.max))
            } else if variableDecl.isSimpleType(of: "UInt8") {
                (0, UInt64(UInt8.max))
            } else {
                fatalError("Unreachable")
            }
        guard let minUInt = Int(minValue), let maxUInt = UInt(maxValue), minUInt < maxUInt else {
            throw BitStreamCodingDiagnostic.custom("The minimum value must be less than the maximum value").error(at: Syntax(variableDecl))
        }
        
        guard minUInt >= minAllowed else {
            throw BitStreamCodingDiagnostic.custom("The minimum value must be more than or equal to \(minAllowed)").error(at: Syntax(variableDecl))
        }
        
        guard maxUInt <= maxAllowed else {
            throw BitStreamCodingDiagnostic.custom("The maximum value must be less than or equal to \(maxAllowed)").error(at: Syntax(variableDecl))
        }
        
        let compressor = "UIntCompressor(minValue: \(minValue), maxValue: \(maxValue))"
        let compressorName = "__\(variableName)Compressor"
        let compressorVarDecl = "let \(compressorName) = \(compressor)"
        
        let initSyntax = """
                        \(compressorVarDecl)
                        self.\(variableName) = try \(compressorName).read(from: &stream)
                        """
        let encodeSyntax = """
                        \(compressorVarDecl)
                        \(compressorName).write(self.\(variableName), to: &stream)
                        """
        return (initSyntax, encodeSyntax)
    }
}
