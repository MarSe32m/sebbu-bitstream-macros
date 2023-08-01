//
//  CompressedIntMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedIntMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@CompressedInt'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@CompressedInt")
        guard variableDecl.isSimpleType(of: "Int", "Int64", "Int32", "Int16", "Int8") else {
            throw BitStreamCodingDiagnostic.custom("Integer compression can only be applied to variables of type Int, Int64, Int32, Int16 or Int8").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 2)
        
        let minValue = try get(arguments, name: "min", position: 0, as: .integer)
        let maxValue = try get(arguments, name: "max", position: 1, as: .integer)
        
        let (minAllowed, maxAllowed) =
            if variableDecl.isSimpleType(of: "Int") {
                (Int64(Int.min), Int64(Int.max))
            } else if variableDecl.isSimpleType(of: "Int64") {
                (Int64(Int64.min), Int64(Int64.max))
            } else if variableDecl.isSimpleType(of: "Int32") {
                (Int64(Int32.min), Int64(Int32.max))
            } else if variableDecl.isSimpleType(of: "Int16") {
                (Int64(Int16.min), Int64(Int16.max))
            } else if variableDecl.isSimpleType(of: "Int8") {
                (Int64(Int8.min), Int64(Int8.max))
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
        
        let compressor = "IntCompressor(minValue: \(minValue), maxValue: \(maxValue))"
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
