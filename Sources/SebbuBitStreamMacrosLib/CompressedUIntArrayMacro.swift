//
//  CompressedUIntArrayMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedUIntArrayMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@CompressedUIntArray'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@CompressedUIntArray")
        guard variableDecl.isArrayType(of: "UInt", "UInt64", "UInt32", "UInt16", "UInt8") else {
            throw BitStreamCodingDiagnostic.custom("Integer array compression can only be applied to array of type [UInt], [UInt64], [UInt32], [UInt16] or [UInt8]").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax,  _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 3)
        
        let minValue = try get(arguments, name: "min", position: 0, as: .integer)
        let maxValue = try get(arguments, name: "max", position: 1, as: .integer)
        let maxCount = try get(arguments, name: "maxCount", position: 2, as: .integer)
        
        let (minAllowed, maxAllowed) =
            if variableDecl.isArrayType(of: "UInt") {
                (0, UInt64(UInt.max))
            } else if variableDecl.isArrayType(of: "UInt64") {
                (0, UInt64.max)
            } else if variableDecl.isArrayType(of: "UInt32") {
                (0, UInt64(UInt32.max))
            } else if variableDecl.isArrayType(of: "UInt16") {
                (0, UInt64(UInt16.max))
            } else if variableDecl.isArrayType(of: "UInt8") {
                (0, UInt64(UInt8.max))
            } else {
                fatalError("Unreachable")
            }
        
        guard let minInt = Int(minValue), let maxInt = Int(maxValue), minInt < maxInt else {
            throw BitStreamCodingDiagnostic.custom("The minimum value must be less than the maximum value").error(at: Syntax(variableDecl))
        }
        
        guard minInt >= minAllowed else {
            throw BitStreamCodingDiagnostic.custom("The minimum value must be more than or equal to \(minAllowed)").error(at: Syntax(variableDecl))
        }
        
        guard maxInt <= maxAllowed else {
            throw BitStreamCodingDiagnostic.custom("The maximum value must be less than or equal to \(maxAllowed)").error(at: Syntax(variableDecl))
        }
        
        guard let intMaxCount = Int(maxCount), intMaxCount > 0, intMaxCount < 1 << 29 else {
            throw BitStreamCodingDiagnostic.custom("Parameter maxCount must be more than zero and less than 2^29").error(at: Syntax(variableDecl))
        }
        
        let compressor = "UIntCompressor(minValue: \(minValue), maxValue: \(maxValue))"
        let compressorName = "__\(variableName)Compressor"
        let compressorVarDecl = "let \(compressorName) = \(compressor)"
        let initSyntax = """
                        \(compressorVarDecl)
                        self.\(variableName) = try \(compressorName).read(maxCount: \(maxCount), from: &stream)
                        """
        let encodeSyntax = """
                        \(compressorVarDecl)
                        \(compressorName).write(self.\(variableName), maxCount: \(maxCount), to: &stream)
                        """
        return (initSyntax, encodeSyntax)
    }
}
