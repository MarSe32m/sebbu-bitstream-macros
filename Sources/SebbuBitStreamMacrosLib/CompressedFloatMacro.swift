//
//  CompressedFloatMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedFloatMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self), variableDecl.isStoredProperty else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresStoredProperty("'@CompressedFloat'").diagnose(at: Syntax(declaration))
            ])
        }
        try check(variable: variableDecl, attribute: "@CompressedFloat")
        guard variableDecl.isSimpleType(of: "Float") else {
            throw BitStreamCodingDiagnostic.custom("Float compression can only be applied to Float variables").error(at: Syntax(variableDecl))
        }
        return []
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        let variableName = variableDecl.variableName!
        let arguments = try arguments(from: attribute, desiredArgumentCount: 3)
        
        let minValue = try get(arguments, name: "min", position: 0, as: .float, .integer)
        let maxValue = try get(arguments, name: "max", position: 1, as: .float, .integer)
        let bits = try get(arguments, name: "bits", position: 2, as: .integer)
        
        guard let minFloat = Float(minValue), let maxFloat = Float(maxValue), minFloat < maxFloat else {
            throw BitStreamCodingDiagnostic.custom("The minimum value must be less than the maximum value").error(at: Syntax(variableDecl))
        }
        
        guard let intBits = Int(bits), intBits > 0, intBits < 32 else {
            throw BitStreamCodingDiagnostic.custom("Parameter bits must be more than zero and less than 32").error(at: Syntax(variableDecl))
        }
        
        let compressor = "FloatCompressor(minValue: \(minValue), maxValue: \(maxValue), bits: \(bits))"
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
